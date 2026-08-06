# `mattpocock/skills` v1.2.0 仓库级工程思路与本仓库映射

> 调查范围：跨 harness 调用元数据、分发、技能生命周期、router/setup、文档权威与 YAGNI。直接依赖运行行为由 #106 覆盖；本调查只提供事实分类和 #108 的判断输入，不决定采纳或实施。

## 结论

v1.2.0 最值得参考的不是目录形状，而是三条治理思路：**同一调用语义在每个 harness 都有可验证编码；分发方式是明确产品选择；重复事实必须有单一权威或自动一致性验证**。

映射到当前仓库后，结果并非“全面跟随”：

1. **两个已验证漂移**：13 个 user-invoked skill 只有 Claude 侧的 `disable-model-invocation`，没有 Codex 侧 `policy.allow_implicit_invocation: false`；仓库两处 `AGENTS.md` 都没有本地 policy 要求的 `CLAUDE.md` adapter。
2. **核心结构大体已对齐**：20 个 `SKILL.md` 与 `skills.sh.json` 完全一致，CLI 能发现全部 20 项；AND 已有更明确的文档权威矩阵、渐进加载、窄 router 和 GitHub-only workflow contract。
3. **有价值但需后续选择**：canonical install source、调用/manifest/adapter 自动验证、删除高维护环境快照、hotspot-first YAGNI。
4. **不应直接照搬**：Claude marketplace plugin、上游 bucket 生命周期、巨大 `ask-matt` router 和多 tracker fallback 都服务于上游自己的产品边界，不是当前仓库已证明的缺口。

上游 tag 自身还有一个反例：`writing-for-agents` 已改名并改为 model-invoked，但同 tag 的 `agents/openai.yaml` 仍显示旧名称并禁止 implicit invocation。方向正确不代表手工同步可靠；应采纳可验证不变量，而不是复制文件集合。

## 映射矩阵

| 维度 | 上游 v1.2.0 | 当前仓库 `ca979c8` | 分类 |
| --- | --- | --- | --- |
| 跨 harness invocation | Claude frontmatter 与 Codex `openai.yaml` 成对表达 | 13 项只有 `disable-model-invocation`; 20 项均无 `openai.yaml` | **已验证漂移** |
| Agent instructions | `AGENTS.md` symlink 与 `CLAUDE.md` 共用一份内容 | 2 个 `AGENTS.md`、0 个 `CLAUDE.md`，违反本地 setup/normalize policy | **已验证漂移** |
| Skill discovery/manifest | plugin manifest 显式列 promoted 集合 | `skills.sh.json` 的 20 项与 20 个 SKILL 完全一致；CLI 发现 20 | **已对齐** |
| 分发 | Claude managed plugin 与 skills.sh editable copy 二选一 | 只承诺跨 harness 的 skills.sh 可编辑安装 | **产品选择，不是缺口** |
| 生命周期 | promoted/in-progress/misc 分层，吸收后删除六项并破坏性改名 | 所有 20 项公开分组，无 draft/deprecated 证据 | **不应机械照搬** |
| Router/setup | `ask-matt` 覆盖整个上游组合；setup 适配多 tracker | `ask-andie` 只路由 AND；setup/workflow contract 固定 GitHub native state | **已对齐于本地边界** |
| 文档权威 | canonical install block、cache/pruning、docs 不重复安装 | 已有权威矩阵；仍有重复安装命令和个人环境快照 | **局部简化机会** |
| YAGNI | 架构扫描先看用户范围或近期 hot spots | package instructions 已要求最小干预、删除 sediment、事实驱动 | **原则已对齐** |
| 自动验证 | 上游声明 invocation/plugin invariants，但 tag 内仍有漏同步 | 仅有两项 workflow contract tests；没有 metadata/manifest/adapter invariant test | **验证机会** |

## 1. 跨 harness 调用语义：真实缺口

上游新增 [`agents/openai.yaml`](https://github.com/mattpocock/skills/tree/v1.2.0/skills) 并用 [invocation contract](https://github.com/mattpocock/skills/blob/v1.2.0/.agents/invocation.md) 明确区分：

- user-invoked：Claude Code 用 `disable-model-invocation: true`，Codex 用 `policy.allow_implicit_invocation: false`；
- model-invoked：两侧都省略禁止项；
- 两侧必须同步，否则同一 skill 在不同 harness 有不同可达性。

[PR #551](https://github.com/mattpocock/skills/pull/551) 为全部现存 skills 加入 Codex metadata 和共享 Agent 入口。当前仓库则公开声称可安装到 Codex 与 Claude Code，但 [tree at `ca979c8`](https://github.com/Andiedie/skills/tree/ca979c8db790d7d5c9bb0b4605663e56e921f8cc/skills) 中 20 个 skill 都没有 `agents/openai.yaml`；其中 13 个明确带 `disable-model-invocation: true`。

这不是 UI 美化差异。当前用户触发边界只在 Claude frontmatter 表达，Codex 侧没有对称 policy；最小 Package 候选应至少恢复这 13 项的 Codex invocation 语义。是否同时为全部 20 项补齐 display metadata，由 #108 在一致性与维护面之间判断。

上游也证明了手工维护会失败：[`writing-for-agents/SKILL.md`](https://github.com/mattpocock/skills/blob/v1.2.0/skills/productivity/writing-for-agents/SKILL.md) 已是新名称且描述具备 model-invoked trigger，同行的 [`agents/openai.yaml`](https://github.com/mattpocock/skills/blob/v1.2.0/skills/productivity/writing-for-agents/agents/openai.yaml) 却仍显示 `Writing Great Skills` 并设置 `allow_implicit_invocation: false`。因此应配验证，不应只批量生成一次。

## 2. Agent instruction 入口：借鉴目标，不照搬方向

上游 v1.2.0 的 [`AGENTS.md`](https://github.com/mattpocock/skills/blob/v1.2.0/AGENTS.md) 是指向 `CLAUDE.md` 的 symlink，目标是让两个 harness 读取同一份共享规则。

当前仓库选择相反但同样合理的权威方向：[`normalize-agent-instructions`](https://github.com/Andiedie/skills/blob/ca979c8db790d7d5c9bb0b4605663e56e921f8cc/skills/normalize-agent-instructions/SKILL.md) 与 [`setup-and`](https://github.com/Andiedie/skills/blob/ca979c8db790d7d5c9bb0b4605663e56e921f8cc/skills/ai-native-development/setup-and/SKILL.md) 都以 `AGENTS.md` 为共享权威，由 sibling `CLAUDE.md` 导入 `@AGENTS.md`。

实际 tree 有根目录和 `skills/ai-native-development/` 两个 tracked `AGENTS.md`，但没有任何 `CLAUDE.md`。这直接违反本仓库自己的当前 policy，也使 Claude 入口不能由仓库文件证明。正确适配是补本地规定的两个 adapter，而不是复制上游“AGENTS 指向 CLAUDE”的反向 symlink。

## 3. 分发：plugin 是产品路线，不是成熟度徽章

上游通过 [Claude plugin manifest](https://github.com/mattpocock/skills/blob/v1.2.0/.claude-plugin/plugin.json) 显式选择 25 个 promoted skills，并进入 Claude Code 官方 marketplace；同时保留 skills.sh 作为 Codex 与其他 agents 的可编辑复制路线。[distribution ADR](https://github.com/mattpocock/skills/blob/v1.2.0/.agents/adr/0002-ship-as-a-claude-code-plugin.md) 把两者定义为不同产品：managed/read-only subscription 与 user-owned/editable copy。[canonical install block](https://github.com/mattpocock/skills/blob/v1.2.0/.agents/install-block.md) 还明确要求不要双装。

当前仓库的 [README](https://github.com/Andiedie/skills/blob/ca979c8db790d7d5c9bb0b4605663e56e921f8cc/README.md) 与 [`skills.sh.json`](https://github.com/Andiedie/skills/blob/ca979c8db790d7d5c9bb0b4605663e56e921f8cc/skills.sh.json) 只承诺 skills.sh 路线。实测 `npx --yes skills add . --list` 发现全部 20 项，manifest 集合与实际 SKILL 集合无差异。

仓库没有“需要受管自动更新 bundle”、稳定/实验集合隔离或 marketplace 用户需求的证据。新增 plugin 会引入第二套 manifest、版本和发布面；在产品选择出现前，不应把缺 plugin 定性为技术债。

## 4. 生命周期与删减：学习判据，不复制 bucket

上游 v1.2.0 将 promoted skills 从 22 增至 25，同时总 SKILL 数从 38 降到 35；六个被吸收或个人环境专用的 skills 删除，`writing-great-skills` 无兼容 alias 地改为 `writing-for-agents`。[removal PR #752](https://github.com/mattpocock/skills/pull/752) · [rename PR #650](https://github.com/mattpocock/skills/pull/650)

可复用判据是：公共 surface 只保留独立价值，能力被更深入口吸收后删除，破坏性迁移完成后不留旧入口。当前仓库没有 draft/deprecated bucket，也没有证据表明 20 项中存在被吸收技能；`Personal Utilities` 下的 `codex-executor`、`progress-title` 是可复用行为，不等同于上游删除的作者私有环境脚本。因此不能按上游 bucket 名称机械删除。

README 中的 `writing-great-skills` 位于明确标注 “2026-07-11 personal environment snapshot” 的表格；它不是当前 runtime requirement，也与实际 manifest 无关，不能断言为错误 rename。它更像 [`writing-for-agents` 所定义的 environment cache](https://github.com/mattpocock/skills/blob/v1.2.0/skills/productivity/writing-for-agents/SKILL.md)：环境可直接查询，快照会持续产生维护成本。删除整个个人环境快照、保留查询方法，是 #108 可评估的简化项。

## 5. Router 与 setup：当前窄边界更适合 AND

上游 [`ask-matt`](https://github.com/mattpocock/skills/blob/v1.2.0/skills/engineering/ask-matt/SKILL.md) 需要路由一个包含工程、教学、访谈和会话工具的宽 portfolio；新增 [`PHASE-BOUNDARIES.md`](https://github.com/mattpocock/skills/blob/v1.2.0/skills/engineering/ask-matt/PHASE-BOUNDARIES.md) 来决定 continue、clear、handoff、subagent、compact。其 setup 还要生成不同 issue tracker 的本地操作文档。

当前 [`ask-andie`](https://github.com/Andiedie/skills/blob/ca979c8db790d7d5c9bb0b4605663e56e921f8cc/skills/ai-native-development/ask-andie/SKILL.md) 只做 AND 位置判断并返回一个 next route；[`and-workflow-contract`](https://github.com/Andiedie/skills/blob/ca979c8db790d7d5c9bb0b4605663e56e921f8cc/skills/ai-native-development/and-workflow-contract/SKILL.md) 已把跨 session 权威放在 GitHub Issues、receipts 和 native relationships，而不是 conversation handoff。它们是更窄、更深的本地接口。

因此不应把上游的 portfolio routes、phase-boundary tree 或 local-markdown tracker fallback 塞进 `ask-andie`/`setup-and`。只有在真实多 tracker 或会话级 router 需求出现后，才重新评估这些入口。

## 6. 文档权威与 YAGNI：原则已对齐，仍可删缓存

上游 `writing-for-agents` 将文档重复环境事实定义为 cache，要求单一权威、渐进披露、删除 sediment；[`improve-codebase-architecture`](https://github.com/mattpocock/skills/blob/v1.2.0/skills/engineering/improve-codebase-architecture/SKILL.md) 则先按用户范围或近期 git hot spots 缩小扫描，避免优化无人修改的代码。[cache PR #682](https://github.com/mattpocock/skills/pull/682) · [YAGNI PR #533](https://github.com/mattpocock/skills/pull/533)

当前 package [`AGENTS.md`](https://github.com/Andiedie/skills/blob/ca979c8db790d7d5c9bb0b4605663e56e921f8cc/skills/ai-native-development/AGENTS.md) 已有按读者划分的权威矩阵、单一规范源、conditional reference、最小干预和删除 sediment 规则；workflow contract 也将条件机制拆到直接引用。这部分不需要再引入新的写作或架构 skill。

剩余机会是缩小缓存面：根 README 与 [`docs/skills.md`](https://github.com/Andiedie/skills/blob/ca979c8db790d7d5c9bb0b4605663e56e921f8cc/skills/ai-native-development/docs/skills.md) 各维护一次外部依赖安装命令，个人环境 snapshot 又复制可查询清单。可让根 README 成为唯一安装权威、skills guide 只链接；个人清单则删除或移出长期文档。它们是简化候选，不是已证明的 runtime bug。

## 7. 可以带入 #108 的候选

### 已有证据支持修复

1. 为 13 个 user-invoked skills 补齐 Codex `allow_implicit_invocation: false`；决定是否顺带为全部 20 项建立统一 `agents/openai.yaml`。
2. 按本仓库自己的 policy，为根目录和 `skills/ai-native-development/` 添加 `CLAUDE.md` adapter，不采用上游反向 symlink。
3. 若新增 metadata/adapter，同包加入最小 invariant check：SKILL↔manifest 集合、Claude↔Codex invocation parity、Agent instruction pair。上游 tag 内 metadata 漏同步证明这不是假想风险。

### 值得简化但需要判断

4. 让根 README 成为 canonical install source，删除 `docs/skills.md` 的重复命令。
5. 删除可由本地命令重建的个人环境 snapshot，只保留查询方式。

### 当前证据支持不做

6. 不新增 Claude/Codex plugin，不引入 promoted/in-progress bucket，不扩大 `ask-andie`，不加入多 tracker fallback。
7. 不仅因上游删除 Personal bucket 就删除本仓库的可复用 utilities；不把 dated `writing-great-skills` snapshot 当 runtime rename bug。

## 方法与边界

调查基于上游 `v1.1.0` (`d574778`) 与 `v1.2.0` (`2ffb184`) 的 Git tree/diff、tag 内源码/manifest/ADR 与对应 PR，以及当前仓库 `ca979c8` 的 tracked tree、GitHub 源码和本地 CLI discovery。静态集合核验结果为 20 SKILL、20 manifest entries、13 user-invoked、0 `openai.yaml`、2 `AGENTS.md`、0 `CLAUDE.md`。

没有安装或升级 skills，没有运行 marketplace/plugin 发布实验，也没有评估 v1.2.0 之后的上游修复。关于“总体工程思路”的表述是基于这些文件组合的推断；是否进入 Package 由 #108/#109 决定。
