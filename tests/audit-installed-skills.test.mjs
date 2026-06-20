import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import { chmodSync, cpSync, mkdirSync, mkdtempSync, readFileSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import test from "node:test";

const repoRoot = dirname(dirname(fileURLToPath(import.meta.url)));
const auditScript = join(repoRoot, "skills", "audit-installed-skills", "bin", "audit-installed-skills.mjs");

test("strict audit reports a missing installed skill path instead of unchanged", () => {
  const fixture = createStrictFixture({ installedPathExists: false });

  const result = runAudit(fixture.workspace, fixture.binDir, [
    "--scope",
    "project",
    "--strict",
    "--json",
    "--ledger",
    join(fixture.root, "known.json"),
  ]);

  assert.equal(result.status, 0, result.stderr);
  const output = JSON.parse(result.stdout);
  assert.equal(output.installed.unchanged, 0);
  assert.deepEqual(output.events.unknown, [
    {
      name: "demo",
      source: "local/source",
      reason: "installed-path-missing",
      path: "skills/demo/SKILL.md",
    },
  ]);
});

test("default ledger ignore works when the workspace is a git worktree", () => {
  const fixture = createWorktreeFixture();

  const result = runAudit(fixture.worktree, fixture.binDir, [
    "--scope",
    "project",
    "--json",
  ]);

  assert.equal(result.status, 0, result.stderr);
  const output = JSON.parse(result.stdout);
  assert.notEqual(output.ledger.gitExclude.status, "write-failed");
  assert.equal(output.limitations.some((item) => item.code === "git-exclude-write-failed"), false);
});

test("strict clone failures include the failed command details", () => {
  const fixture = createStrictFixture({
    installedPathExists: true,
    sourceUrl: join(mkdtempSync(join(tmpdir(), "audit-missing-source-")), "missing-upstream"),
  });

  const result = runAudit(fixture.workspace, fixture.binDir, [
    "--scope",
    "project",
    "--strict",
    "--json",
    "--ledger",
    join(fixture.root, "known.json"),
  ]);

  assert.equal(result.status, 0, result.stderr);
  const output = JSON.parse(result.stdout);
  const cloneFailure = output.limitations.find((item) => item.code === "strict-clone-failed");
  assert.ok(cloneFailure);
  assert.match(cloneFailure.attempt.command, /^git clone --depth=1 /);
  assert.notEqual(cloneFailure.attempt.status, 0);
  assert.match(cloneFailure.attempt.stderrSnippet, /repository|does not exist|not appear/i);
});

test("strict audit reports changed files when installed content differs from upstream", () => {
  const fixture = createStrictFixture({ installedPathExists: true });
  writeFileSync(join(fixture.installedPath, "SKILL.md"), [
    "---",
    "name: demo",
    "description: Locally changed demo skill.",
    "---",
    "",
    "# Demo",
    "",
  ].join("\n"));

  const result = runAudit(fixture.workspace, fixture.binDir, [
    "--scope",
    "project",
    "--strict",
    "--json",
    "--ledger",
    join(fixture.root, "known.json"),
  ]);

  assert.equal(result.status, 0, result.stderr);
  const output = JSON.parse(result.stdout);
  assert.equal(output.events.updated.length, 1);
  assert.deepEqual(output.events.updated[0].filesChanged, [
    { path: "SKILL.md", kind: "modified" },
  ]);
});

function createStrictFixture({ installedPathExists, sourceUrl } = {}) {
  const root = mkdtempSync(join(tmpdir(), "audit-installed-skills-test-"));
  const workspace = join(root, "workspace");
  const upstream = join(root, "upstream");
  const binDir = join(root, "bin");
  const installedPath = join(workspace, ".agents", "skills", "demo");

  mkdirSync(join(workspace, ".agents"), { recursive: true });
  mkdirSync(join(upstream, "skills", "demo"), { recursive: true });
  mkdirSync(binDir, { recursive: true });

  writeFileSync(join(upstream, "skills", "demo", "SKILL.md"), [
    "---",
    "name: demo",
    "description: Demo skill for audit tests.",
    "---",
    "",
    "# Demo",
    "",
  ].join("\n"));

  run("git", ["init", "--quiet"], { cwd: upstream });
  run("git", ["add", "skills/demo/SKILL.md"], { cwd: upstream });
  run("git", ["-c", "user.email=audit@example.com", "-c", "user.name=Audit Test", "commit", "--quiet", "-m", "init"], { cwd: upstream });

  if (installedPathExists) {
    mkdirSync(installedPath, { recursive: true });
    cpSync(join(upstream, "skills", "demo", "SKILL.md"), join(installedPath, "SKILL.md"));
  }

  writeFileSync(join(workspace, ".agents", ".skill-lock.json"), JSON.stringify({
    version: 1,
    skills: {
      demo: {
        source: "local/source",
        sourceUrl: sourceUrl ?? upstream,
        skillPath: "skills/demo/SKILL.md",
      },
    },
  }, null, 2));

  writeExecutable(join(binDir, "npx"), [
    "#!/bin/sh",
    "if [ \"$1\" = \"--yes\" ] && [ \"$2\" = \"skills\" ] && [ \"$3\" = \"list\" ]; then",
    `  printf '[{\"name\":\"demo\",\"path\":\"${installedPath}\",\"scope\":\"project\",\"agents\":[\"codex\"]}]\\n'`,
    "  exit 0",
    "fi",
    "if [ \"$1\" = \"--yes\" ] && [ \"$2\" = \"skills\" ] && [ \"$3\" = \"add\" ]; then",
    "  printf '|\\n|  Available Skills\\n|\\n|    demo\\n|\\n|      Demo skill for audit tests.\\n|\\n|  Use --skill <name> to install specific skills\\n'",
    "  exit 0",
    "fi",
    "exit 2",
    "",
  ].join("\n"));

  return { root, workspace, binDir, installedPath };
}

function createWorktreeFixture() {
  const root = mkdtempSync(join(tmpdir(), "audit-installed-skills-test-"));
  const main = join(root, "main");
  const worktree = join(root, "worktree");
  const binDir = join(root, "bin");

  mkdirSync(main, { recursive: true });
  mkdirSync(binDir, { recursive: true });
  run("git", ["init", "--quiet"], { cwd: main });
  writeFileSync(join(main, "README.md"), "# Main\n");
  run("git", ["add", "README.md"], { cwd: main });
  run("git", ["-c", "user.email=audit@example.com", "-c", "user.name=Audit Test", "commit", "--quiet", "-m", "init"], { cwd: main });
  run("git", ["worktree", "add", "--quiet", worktree], { cwd: main });

  mkdirSync(join(worktree, ".agents"), { recursive: true });
  writeFileSync(join(worktree, ".agents", ".skill-lock.json"), JSON.stringify({
    version: 1,
    skills: {},
  }, null, 2));
  writeListOnlyNpxStub(binDir);

  return { root, worktree, binDir };
}

function runAudit(cwd, binDir, args) {
  return spawnSync(process.execPath, [auditScript, ...args], {
    cwd,
    encoding: "utf8",
    env: {
      ...process.env,
      PATH: `${binDir}:${process.env.PATH}`,
    },
  });
}

function run(command, args, options) {
  const result = spawnSync(command, args, { ...options, encoding: "utf8" });
  assert.equal(result.status, 0, `${command} ${args.join(" ")}\n${result.stderr}`);
  return result;
}

function writeExecutable(path, text) {
  writeFileSync(path, text);
  chmodSync(path, 0o755);
}

function writeListOnlyNpxStub(binDir) {
  writeExecutable(join(binDir, "npx"), [
    "#!/bin/sh",
    "if [ \"$1\" = \"--yes\" ] && [ \"$2\" = \"skills\" ] && [ \"$3\" = \"list\" ]; then",
    "  printf '[]\\n'",
    "  exit 0",
    "fi",
    "exit 2",
    "",
  ].join("\n"));
}
