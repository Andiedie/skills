#!/usr/bin/env node
import { spawn, spawnSync } from "node:child_process";
import {
  existsSync,
  mkdirSync,
  mkdtempSync,
  readdirSync,
  readFileSync,
  renameSync,
  rmSync,
  statSync,
  writeFileSync,
} from "node:fs";
import { homedir, tmpdir } from "node:os";
import { dirname, isAbsolute, join, relative, resolve, sep } from "node:path";
import { createHash } from "node:crypto";

const args = parseArgs(process.argv.slice(2));
const workspace = process.cwd();
const scope = args.scope ?? "global";
const strict = Boolean(args.strict);
const now = new Date().toISOString();
const limitations = [];
const commands = [];
const sourceInspectionConcurrency = 2;

if (!["global", "project"].includes(scope)) {
  fail(`Unsupported scope: ${scope}`);
}

const installedCommand = scope === "global"
  ? ["npx", ["--yes", "skills", "list", "-g", "--json"]]
  : ["npx", ["--yes", "skills", "list", "--json"]];
const lockPath = scope === "global"
  ? join(homedir(), ".agents", ".skill-lock.json")
  : join(workspace, ".agents", ".skill-lock.json");
const defaultLedgerPath = join(workspace, ".skill-audit", "known.json");
const usingCustomLedger = Boolean(args.ledger);
const ledgerPath = args.ledger
  ? resolve(workspace, args.ledger)
  : defaultLedgerPath;

const installedResult = run(installedCommand[0], installedCommand[1]);
if (installedResult.status !== 0) {
  fail("Could not read installed skills", { command: installedResult });
}

const installedList = parseJson(installedResult.stdout, "installed skills JSON");
const lockRead = readJson(lockPath);
const lock = lockRead.ok ? lockRead.value : null;
if (!lockRead.ok) {
  limitations.push({
    code: "lock-unavailable",
    message: `Could not read lock file at ${lockPath}: ${lockRead.error}`,
  });
}

const ledger = loadLedger(ledgerPath);
const gitExcludeResult = ensureLedgerIgnored(workspace, usingCustomLedger);

const lockSkills = lock?.skills && typeof lock.skills === "object" ? lock.skills : {};
const installedByName = new Map(installedList.map((skill) => [skill.name, skill]));
const audited = [];
const excluded = [];

for (const skill of installedList) {
  if (isCodexSidePath(skill.path)) {
    excluded.push({ name: skill.name, reason: "codex-side-skill" });
    continue;
  }

  const meta = lockSkills[skill.name];
  if (lock && !meta) {
    excluded.push({ name: skill.name, reason: "not-in-lock-file" });
    continue;
  }

  audited.push({
    name: skill.name,
    path: skill.path,
    scope: skill.scope,
    agents: skill.agents ?? [],
    lock: meta ?? null,
    source: meta?.source ?? null,
  });
}

for (const [name, meta] of Object.entries(lockSkills)) {
  if (!installedByName.has(name)) {
    limitations.push({
      code: "lock-entry-not-installed",
      message: `${name} is present in the lock file but not in npx skills list output.`,
      skill: name,
      source: meta.source,
    });
  }
}

const groups = groupBy(audited.filter((skill) => skill.source), (skill) => skill.source);
const sourceResults = [];
const events = {
  deleted: [],
  updated: [],
  new: [],
  unknown: [],
};
let unchangedCount = 0;

const inspectedSources = await mapWithConcurrency(Array.from(groups.entries()), sourceInspectionConcurrency, async ([source, skills]) => {
  const sourceUrl = skills.find((skill) => skill.lock?.sourceUrl)?.lock?.sourceUrl ?? null;
  const sourceResult = await inspectSource(source, sourceUrl, skills);
  return { source, skills, sourceResult };
});

for (const { source, skills, sourceResult } of inspectedSources) {
  sourceResults.push(sourceResult.public);

  const installedNames = new Set(skills.map((skill) => skill.name));
  for (const available of sourceResult.available) {
    if (installedNames.has(available.name)) continue;
    if (shouldExcludeAvailable(source, available)) continue;
    events.new.push(makeEvent("new", {
      name: available.name,
      source,
      description: truncate(available.description),
      path: available.path ?? null,
      summary: `New available skill ${available.name} from ${source}.`,
      fingerprintInput: [source, available.name, available.description ?? "", available.path ?? ""],
    }));
  }

  for (const skill of skills) {
    const status = classifyInstalled(skill, sourceResult);
    if (status.kind === "unchanged") {
      unchangedCount += 1;
      continue;
    }

    if (status.kind === "deleted") {
      events.deleted.push(makeEvent("deleted", {
        name: skill.name,
        source,
        path: skill.lock?.skillPath ?? null,
        reason: status.reason,
        summary: `${skill.name} appears deleted or deprecated in ${source}: ${status.reason}.`,
        fingerprintInput: [source, skill.name, status.reason, skill.lock?.skillPath ?? ""],
      }));
      continue;
    }

    if (status.kind === "updated") {
      events.updated.push(makeEvent("updated", {
        name: skill.name,
        source,
        path: skill.lock?.skillPath ?? null,
        filesChanged: status.filesChanged,
        summary: `${skill.name} differs from upstream ${source}.`,
        fingerprintInput: [source, skill.name, status.upstreamHead ?? "", status.upstreamHash ?? ""],
      }));
      continue;
    }

    events.unknown.push({
      name: skill.name,
      source,
      reason: status.reason,
      path: skill.lock?.skillPath ?? null,
    });
  }
}

for (const skill of audited.filter((item) => !item.source)) {
  events.unknown.push({
    name: skill.name,
    source: null,
    reason: "missing-source-metadata",
    path: skill.lock?.skillPath ?? null,
  });
}

const ledgerResult = applyLedger(ledger, events, ledgerPath);
ledgerResult.gitExclude = gitExcludeResult;
const readme = inspectReadme(workspace, scope, audited);
const publicEvents = {
  deleted: events.deleted.map(publicEvent),
  updated: events.updated.filter((event) => event.reportable).map(publicEvent),
  new: events.new.filter((event) => event.reportable).map(publicEvent),
  unknown: events.unknown,
};

const output = {
  version: 1,
  generatedAt: now,
  scope,
  mode: strict ? "strict" : "quick",
  updateCheck: strict ? "checked" : "skipped",
  installed: {
    totalFromCommand: installedList.length,
    audited: audited.length,
    excluded,
    unchanged: unchangedCount,
  },
  sources: sourceResults,
  events: publicEvents,
  ledger: ledgerResult,
  readme,
  limitations,
  commands,
};

if (!strict) {
  output.limitations.push({
    code: "quick-mode-skips-content-diff",
    message: "Quick mode skips installed-vs-upstream content hashes and directory diffs. It may still fetch skill listings, retry failed listings, or run a shallow path scan when needed for classification.",
  });
}

process.stdout.write(JSON.stringify(output, null, 2));
process.stdout.write("\n");

function parseArgs(argv) {
  const parsed = {};
  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === "--json") {
      parsed.json = true;
    } else if (arg === "--strict") {
      parsed.strict = true;
    } else if (arg === "--scope") {
      parsed.scope = argv[index + 1];
      index += 1;
    } else if (arg.startsWith("--scope=")) {
      parsed.scope = arg.slice("--scope=".length);
    } else if (arg === "--ledger") {
      parsed.ledger = argv[index + 1];
      index += 1;
    } else if (arg.startsWith("--ledger=")) {
      parsed.ledger = arg.slice("--ledger=".length);
    }
  }
  return parsed;
}

function run(command, commandArgs, options = {}) {
  const result = spawnSync(command, commandArgs, {
    cwd: options.cwd ?? workspace,
    encoding: "utf8",
    env: {
      ...process.env,
      CI: "1",
      NO_COLOR: "1",
      TERM: "dumb",
    },
    maxBuffer: 1024 * 1024 * 20,
  });

  const record = {
    command: [command, ...commandArgs].join(" "),
    status: result.status,
  };
  commands.push(record);

  return {
    ...record,
    stdout: result.stdout ?? "",
    stderr: result.stderr ?? "",
    error: result.error?.message,
  };
}

async function inspectSource(source, sourceUrl, skills) {
  const listResult = await listAvailableWithRetry(source);
  const list = listResult.final;

  const available = list.status === 0 ? parseAvailableSkills(list.stdout + "\n" + list.stderr) : [];
  const byName = new Map(available.map((skill) => [skill.name, skill]));
  const publicResult = {
    source,
    sourceUrl,
    availableCount: available.length,
    listed: list.status === 0,
    usedFullDepth: list.fullDepth,
    strictChecked: strict,
    listAttempts: listResult.attempts.map(publicCommandAttempt),
  };

  if (list.status !== 0) {
    limitations.push({
      code: "source-list-failed",
      source,
      message: `Could not list available skills for ${source} after ${listResult.attempts.length} attempts.`,
      attempts: listResult.attempts.map(summarizeCommandResult),
    });
  }

  if (!strict && list.status === 0 && source === "mattpocock/skills" && sourceUrl) {
    const pathResult = inspectSourcePaths(source, sourceUrl, available);
    publicResult.pathChecked = !pathResult.error;
    publicResult.pathCheckError = pathResult.error;
    return { public: publicResult, available: pathResult.available, byName: new Map(pathResult.available.map((skill) => [skill.name, skill])), strict: null };
  }

  if (!strict || !sourceUrl) {
    if (strict && !sourceUrl) {
      limitations.push({
        code: "strict-source-url-missing",
        source,
        message: `Cannot run strict source comparison for ${source} because sourceUrl is missing.`,
      });
    }
    return { public: publicResult, available, byName, strict: null };
  }

  const strictResult = inspectSourceStrict(source, sourceUrl, skills, available);
  publicResult.upstreamHead = strictResult.upstreamHead;
  publicResult.strictError = strictResult.error;
  return { public: publicResult, available: strictResult.available, byName: new Map(strictResult.available.map((skill) => [skill.name, skill])), strict: strictResult };
}

function inspectSourcePaths(source, sourceUrl, available) {
  const tempRoot = mkdtempSync(join(tmpdir(), "skill-audit-paths-"));
  try {
    const clone = run("git", ["clone", "--depth=1", sourceUrl, tempRoot]);
    if (clone.status !== 0) {
      limitations.push({
        code: "path-scan-clone-failed",
        source,
        message: `Could not clone ${sourceUrl} for path-sensitive exclusions.`,
        attempt: summarizeCommandResult(clone),
      });
      return { error: "clone-failed", available };
    }

    const skillDirs = scanSkillDirs(tempRoot);
    return {
      error: null,
      available: available.map((skill) => ({
        ...skill,
        path: skillDirs.get(skill.name)?.relativeSkillPath ?? skill.path ?? null,
      })),
    };
  } finally {
    rmSync(tempRoot, { recursive: true, force: true });
  }
}

async function listAvailableWithRetry(source) {
  const attempts = [];
  let result = await listAvailable(source, false);
  attempts.push(result);

  if (result.status === 0) {
    return { final: result, attempts };
  }

  result = await listAvailable(source, false);
  attempts.push(result);
  if (result.status === 0) {
    return { final: result, attempts };
  }

  result = await listAvailable(source, true);
  attempts.push(result);
  return { final: result, attempts };
}

async function listAvailable(source, fullDepth) {
  const commandArgs = ["--yes", "skills", "add", source, "--list"];
  if (fullDepth) commandArgs.push("--full-depth");
  const result = await runAsync("npx", commandArgs);
  return { ...result, fullDepth };
}

function runAsync(command, commandArgs, options = {}) {
  return new Promise((resolve) => {
    const child = spawn(command, commandArgs, {
      cwd: options.cwd ?? workspace,
      env: {
        ...process.env,
        CI: "1",
        NO_COLOR: "1",
        TERM: "dumb",
      },
      stdio: ["ignore", "pipe", "pipe"],
    });

    let stdout = "";
    let stderr = "";
    child.stdout.setEncoding("utf8");
    child.stderr.setEncoding("utf8");
    child.stdout.on("data", (chunk) => {
      stdout += chunk;
    });
    child.stderr.on("data", (chunk) => {
      stderr += chunk;
    });
    child.on("error", (error) => {
      const record = {
        command: [command, ...commandArgs].join(" "),
        status: null,
      };
      commands.push(record);
      resolve({ ...record, stdout, stderr, error: error.message });
    });
    child.on("close", (status) => {
      const record = {
        command: [command, ...commandArgs].join(" "),
        status,
      };
      commands.push(record);
      resolve({ ...record, stdout, stderr });
    });
  });
}

async function mapWithConcurrency(items, concurrency, mapper) {
  const results = new Array(items.length);
  let nextIndex = 0;
  const workers = Array.from({ length: Math.min(concurrency, items.length) }, async () => {
    while (nextIndex < items.length) {
      const currentIndex = nextIndex;
      nextIndex += 1;
      results[currentIndex] = await mapper(items[currentIndex], currentIndex);
    }
  });
  await Promise.all(workers);
  return results;
}

function inspectSourceStrict(source, sourceUrl, skills, available) {
  const tempRoot = mkdtempSync(join(tmpdir(), "skill-audit-"));
  try {
    const clone = run("git", ["clone", "--depth=1", sourceUrl, tempRoot]);
    if (clone.status !== 0) {
      limitations.push({
        code: "strict-clone-failed",
        source,
        message: `Could not clone ${sourceUrl}.`,
        attempt: summarizeCommandResult(clone),
      });
      return { error: "clone-failed", available, skillDirs: new Map() };
    }

    const head = run("git", ["rev-parse", "HEAD"], { cwd: tempRoot });
    const upstreamHead = head.status === 0 ? head.stdout.trim() : null;
    const skillDirs = scanSkillDirs(tempRoot);
    const availableWithPaths = available.map((skill) => ({
      ...skill,
      path: skillDirs.get(skill.name)?.relativeSkillPath ?? skill.path ?? null,
    }));

    for (const skill of skills) {
      const lockedDir = skill.lock?.skillPath ? dirname(skill.lock.skillPath) : null;
      if (!lockedDir) continue;
      const absolute = join(tempRoot, lockedDir);
      if (!existsSync(absolute)) continue;
      const upstreamState = hashDirState(absolute);
      const installedState = existsSync(skill.path) ? hashDirState(skill.path) : null;
      const availableEntry = availableWithPaths.find((item) => item.name === skill.name);
      if (availableEntry) {
        availableEntry.upstreamHash = upstreamState.hash;
      }
      skill.strict = {
        upstreamHead,
        upstreamHash: upstreamState.hash,
        installedHash: installedState?.hash ?? null,
        filesChanged: installedState ? diffFileHashes(upstreamState.files, installedState.files) : [],
        upstreamExists: true,
      };
    }

    return {
      upstreamHead,
      available: availableWithPaths,
      skillDirs,
      error: null,
    };
  } finally {
    rmSync(tempRoot, { recursive: true, force: true });
  }
}

function classifyInstalled(skill, sourceResult) {
  if (isMattDeprecatedPath(skill.lock?.skillPath)) {
    return { kind: "deleted", reason: "locked-path-is-deprecated" };
  }

  if (strict) {
    if (!sourceResult.strict || sourceResult.strict.error) {
      return { kind: "unknown", reason: sourceResult.strict?.error ?? "strict-source-check-unavailable" };
    }

    if (skill.strict?.upstreamExists) {
      if (!skill.strict.installedHash) {
        return { kind: "unknown", reason: "installed-path-missing" };
      }

      if (skill.strict.installedHash && skill.strict.installedHash !== skill.strict.upstreamHash) {
        return {
          kind: "updated",
          upstreamHead: skill.strict.upstreamHead,
          upstreamHash: skill.strict.upstreamHash,
          filesChanged: skill.strict.filesChanged,
        };
      }
      return { kind: "unchanged" };
    }

    if (skill.lock?.skillPath) {
      return {
        kind: "deleted",
        reason: "locked-upstream-path-missing",
      };
    }

    return { kind: "unknown", reason: "missing-locked-upstream-path" };
  }

  if (!sourceResult.public.listed) {
    return { kind: "unknown", reason: "source-list-failed" };
  }

  if (!sourceResult.byName.has(skill.name)) {
    return { kind: "deleted", reason: "absent-from-available-list" };
  }

  return { kind: "unchanged" };
}

function parseAvailableSkills(output) {
  const lines = stripAnsi(output).replace(/\r/g, "").split("\n");
  const skills = [];
  let inAvailable = false;
  let current = null;

  for (const line of lines) {
    if (line.includes("Available Skills")) {
      inAvailable = true;
      continue;
    }
    if (!inAvailable) continue;

    const text = line.trim();
    if (!text) continue;
    if (text.includes("Use --skill")) break;

    const skillMatch = line.match(/^\s*[│|]\s{4}([A-Za-z0-9][A-Za-z0-9_.:-]*)\s*$/);
    if (skillMatch) {
      current = { name: skillMatch[1], description: "" };
      skills.push(current);
      continue;
    }

    const descriptionMatch = line.match(/^\s*[│|]\s{6,}(.+?)\s*$/);
    if (current && !current.description && descriptionMatch) {
      current.description = truncate(descriptionMatch[1].trim());
    }
  }

  return skills;
}

function scanSkillDirs(root) {
  const dirs = new Map();
  for (const file of walk(root)) {
    if (!file.endsWith(`${sep}SKILL.md`)) continue;
    const relativeSkillPath = relative(root, file).split(sep).join("/");
    const frontmatter = readSkillFrontmatter(file);
    if (!frontmatter.name) continue;
    dirs.set(frontmatter.name, {
      relativeSkillPath,
      description: frontmatter.description ?? "",
    });
  }
  return dirs;
}

function walk(root) {
  const files = [];
  const entries = readdirSync(root, { withFileTypes: true });
  for (const entry of entries) {
    if (entry.name === ".git" || entry.name === "node_modules") continue;
    const absolute = join(root, entry.name);
    if (entry.isDirectory()) {
      files.push(...walk(absolute));
    } else if (entry.isFile()) {
      files.push(absolute);
    }
  }
  return files;
}

function readSkillFrontmatter(file) {
  const text = readFileSync(file, "utf8");
  const match = text.match(/^---\n([\s\S]*?)\n---/);
  if (!match) return {};
  const frontmatter = {};
  for (const line of match[1].split("\n")) {
    const separator = line.indexOf(":");
    if (separator === -1) continue;
    const key = line.slice(0, separator).trim();
    const value = line.slice(separator + 1).trim();
    frontmatter[key] = value.replace(/^["']|["']$/g, "");
  }
  return frontmatter;
}

function shouldExcludeAvailable(source, skill) {
  if (source !== "mattpocock/skills") return false;
  const path = skill.path ?? "";
  return path.includes("skills/in-progress/") || path.includes("skills/deprecated/");
}

function isMattDeprecatedPath(path) {
  return typeof path === "string" && path.includes("skills/deprecated/");
}

function isCodexSidePath(path) {
  if (!path) return false;
  return path.includes(`${sep}.codex${sep}`) || path.includes("/.codex/");
}

function makeEvent(kind, data) {
  const fingerprint = sha256([kind, ...data.fingerprintInput].join("\0"));
  return {
    kind,
    name: data.name,
    source: data.source,
    description: data.description,
    path: data.path,
    reason: data.reason,
    filesChanged: data.filesChanged,
    summary: data.summary,
    fingerprint,
    known: false,
    reportable: true,
  };
}

function publicEvent(event) {
  const cleaned = { ...event };
  delete cleaned.fingerprint;
  return cleaned;
}

function loadLedger(path) {
  if (!existsSync(path)) {
    return {
      path,
      writable: true,
      status: "missing",
      value: { version: 1, events: {} },
    };
  }

  const read = readJson(path);
  if (!read.ok || !read.value || typeof read.value !== "object" || !read.value.events) {
    return {
      path,
      writable: false,
      status: "read-only",
      reason: read.error ?? "ledger is malformed",
      value: { version: 1, events: {} },
    };
  }

  return {
    path,
    writable: true,
    status: "loaded",
    value: read.value,
  };
}

function applyLedger(ledger, eventGroups, path) {
  const next = {
    version: 1,
    events: {
      ...(ledger.value.events ?? {}),
    },
  };
  let recorded = 0;
  let suppressed = 0;

  for (const kind of ["new", "updated", "deleted"]) {
    for (const event of eventGroups[kind]) {
      const key = `${scope}|${event.source}|${event.name}|${kind}`;
      const previous = ledger.value.events?.[key];
      const known = previous?.fingerprint === event.fingerprint;
      event.known = known;
      event.reportable = kind === "deleted" ? true : !known;
      if (known && kind !== "deleted") suppressed += 1;

      if (ledger.writable) {
        next.events[key] = {
          fingerprint: event.fingerprint,
          firstReportedAt: known ? previous.firstReportedAt : now,
          lastSeenAt: now,
          summary: event.summary,
        };
        recorded += 1;
      }
    }
  }

  if (!ledger.writable) {
    limitations.push({
      code: "ledger-read-only",
      message: `Known-event ledger was not written: ${ledger.reason}`,
    });
    return {
      path,
      status: "read-only",
      reason: ledger.reason,
      recorded: 0,
      suppressedKnownEvents: suppressed,
    };
  }

  try {
    mkdirSync(dirname(path), { recursive: true });
    const tempPath = join(dirname(path), `.known.${process.pid}.tmp`);
    writeFileSync(tempPath, `${JSON.stringify(next, null, 2)}\n`);
    JSON.parse(readFileSync(tempPath, "utf8"));
    renameSync(tempPath, path);
    return {
      path,
      status: "written",
      recorded,
      suppressedKnownEvents: suppressed,
    };
  } catch (error) {
    limitations.push({
      code: "ledger-write-failed",
      message: `Known-event ledger could not be written: ${error.message}`,
    });
    return {
      path,
      status: "write-failed",
      reason: error.message,
      recorded: 0,
      suppressedKnownEvents: suppressed,
    };
  }
}

function ensureLedgerIgnored(cwd, usingCustomLedgerPath) {
  if (usingCustomLedgerPath) {
    return { status: "skipped-custom-ledger" };
  }

  const gitPath = run("git", ["rev-parse", "--git-path", "info/exclude"], { cwd });
  if (gitPath.status !== 0) {
    return { status: "skipped-not-git-repo", reason: snippet(gitPath.stderr) ?? gitPath.error };
  }

  const rawExcludePath = gitPath.stdout.trim();
  const excludePath = isAbsolute(rawExcludePath) ? rawExcludePath : join(cwd, rawExcludePath);
  try {
    mkdirSync(dirname(excludePath), { recursive: true });
    const current = existsSync(excludePath) ? readFileSync(excludePath, "utf8") : "";
    if (current.split("\n").some((line) => line.trim() === ".skill-audit/")) {
      return { status: "already-ignored", path: excludePath };
    }

    const prefix = current.endsWith("\n") || current.length === 0 ? "" : "\n";
    writeFileSync(excludePath, `${current}${prefix}.skill-audit/\n`);
    return { status: "written", path: excludePath };
  } catch (error) {
    limitations.push({
      code: "git-exclude-write-failed",
      message: `Could not add .skill-audit/ to .git/info/exclude: ${error.message}`,
    });
    return { status: "write-failed", path: excludePath, reason: error.message };
  }
}

function inspectReadme(cwd, auditScope, skills) {
  if (auditScope !== "global") {
    return { status: "skipped", reason: "project-scope-audit" };
  }

  const path = join(cwd, "README.md");
  if (!existsSync(path)) {
    return { status: "missing", path };
  }

  const text = readFileSync(path, "utf8");
  const expected = groupBy(skills.filter((skill) => skill.source), (skill) => skill.source);
  const rows = parseReadmeSnapshotRows(text);
  const differences = [];

  for (const [source, sourceSkills] of expected) {
    const row = findReadmeRow(rows, source);
    const expectedSkills = sourceSkills.map((skill) => skill.name).sort();
    if (!row) {
      differences.push({ source, kind: "missing-row", expectedSkills });
      continue;
    }

    const actualSkills = Array.from(row.skills).sort();
    if (expectedSkills.join("\0") !== actualSkills.join("\0")) {
      differences.push({
        source,
        kind: "skill-list-drift",
        expectedSkills,
        actualSkills,
      });
    }
  }

  for (const row of rows) {
    if (!isManagedReadmeRow(row)) continue;
    const rowMatchesInstalledSource = Array.from(expected.keys()).some((source) => readmeRowMatchesSource(row, source));
    if (rowMatchesInstalledSource) continue;
    differences.push({
      source: row.sourceKey,
      kind: "extra-row",
      actualSkills: Array.from(row.skills).sort(),
      sourceCell: row.sourceCell,
    });
  }

  return {
    status: differences.length === 0 ? "fresh" : "stale",
    path,
    differences,
  };
}

function parseReadmeSnapshotRows(text) {
  const rows = [];
  let inSnapshotTable = false;

  for (const line of text.split("\n")) {
    if (line.trim() === "| Source | Skills |") {
      inSnapshotTable = true;
      continue;
    }
    if (!inSnapshotTable) continue;
    if (!line.startsWith("|")) break;

    const cells = line.split("|").slice(1, -1).map((cell) => cell.trim());
    if (cells.length < 2 || cells[0] === "---") continue;

    rows.push({
      sourceCell: cells[0],
      sourceKey: extractReadmeSourceKey(cells[0]),
      skills: new Set(Array.from(cells[1].matchAll(/`([^`]+)`/g)).map((match) => match[1])),
    });
  }

  return rows;
}

function findReadmeRow(rows, source) {
  return rows.find((row) => readmeRowMatchesSource(row, source)) ?? null;
}

function readmeRowMatchesSource(row, source) {
  return row.sourceCell.includes(source);
}

function isManagedReadmeRow(row) {
  return Boolean(row.sourceKey);
}

function extractReadmeSourceKey(sourceCell) {
  const markdownLink = sourceCell.match(/^\[([^\]]+)\]\(/);
  if (markdownLink && markdownLink[1].includes("/")) return markdownLink[1];
  if (/^[A-Za-z0-9_.-]+\/[A-Za-z0-9_.-]+$/.test(sourceCell)) return sourceCell;
  return null;
}

function hashDirState(path) {
  const hash = createHash("sha256");
  const files = new Map();
  for (const file of walk(path).sort()) {
    const stat = statSync(file);
    if (!stat.isFile()) continue;
    const rel = relative(path, file).split(sep).join("/");
    if (rel === ".DS_Store") continue;
    const content = readFileSync(file);
    files.set(rel, sha256(content));
    hash.update(rel);
    hash.update("\0");
    hash.update(content);
    hash.update("\0");
  }
  return { hash: hash.digest("hex"), files };
}

function diffFileHashes(upstreamFiles, installedFiles) {
  const changes = [];

  for (const [path, upstreamHash] of upstreamFiles) {
    if (!installedFiles.has(path)) {
      changes.push({ path, kind: "deleted" });
      continue;
    }

    if (installedFiles.get(path) !== upstreamHash) {
      changes.push({ path, kind: "modified" });
    }
  }

  for (const path of installedFiles.keys()) {
    if (!upstreamFiles.has(path)) {
      changes.push({ path, kind: "added" });
    }
  }

  return changes.sort((left, right) => left.path.localeCompare(right.path) || left.kind.localeCompare(right.kind));
}

function groupBy(items, keyFn) {
  const map = new Map();
  for (const item of items) {
    const key = keyFn(item);
    if (!map.has(key)) map.set(key, []);
    map.get(key).push(item);
  }
  return map;
}

function readJson(path) {
  try {
    return { ok: true, value: JSON.parse(readFileSync(path, "utf8")) };
  } catch (error) {
    return { ok: false, error: error.message };
  }
}

function parseJson(text, label) {
  try {
    return JSON.parse(text);
  } catch (error) {
    fail(`Could not parse ${label}: ${error.message}`);
  }
}

function stripAnsi(text) {
  return text.replace(/\u001b\[[0-9;?]*[ -/]*[@-~]/g, "");
}

function sha256(text) {
  return createHash("sha256").update(text).digest("hex");
}

function truncate(text, maxLength = 260) {
  if (!text || text.length <= maxLength) return text ?? "";
  return `${text.slice(0, maxLength - 1).trimEnd()}...`;
}

function publicCommandAttempt(result) {
  return {
    command: result.command,
    status: result.status,
    fullDepth: result.fullDepth,
  };
}

function summarizeCommandResult(result) {
  return {
    command: result.command,
    status: result.status,
    fullDepth: result.fullDepth,
    error: result.error,
    stderrSnippet: snippet(result.stderr),
    stdoutSnippet: result.status === 0 ? undefined : snippet(result.stdout),
  };
}

function snippet(text, maxLength = 600) {
  const clean = stripAnsi(text ?? "").replace(/\s+/g, " ").trim();
  if (!clean) return undefined;
  return truncate(clean, maxLength);
}

function fail(message, extra = {}) {
  process.stdout.write(JSON.stringify({
    version: 1,
    generatedAt: now,
    scope,
    mode: strict ? "strict" : "quick",
    error: message,
    ...extra,
  }, null, 2));
  process.stdout.write("\n");
  process.exit(1);
}
