# `mattpocock/skills` v1.2.0 事实盘点

> 调查范围：`v1.1.0` → `v1.2.0`。本文只回答上游实际发生了什么、变化属于什么性质，以及 release notes 与 tag/PR 事实是否一致；不评估 `Andiedie/skills` 是否采纳。

## 结论摘要

### 已确认事实

- `v1.1.0` 指向提交 [`d574778`](https://github.com/mattpocock/skills/commit/d574778f94cf620fcc8ce741584093bc650a61d3)，`v1.2.0` 指向提交 [`2ffb184`](https://github.com/mattpocock/skills/commit/2ffb184ffbb752faa664c0b204f3c9241b1428e9)；正式 [v1.2.0 release](https://github.com/mattpocock/skills/releases/tag/v1.2.0) 于 2026-08-05 12:37:40 UTC 发布，不是 prerelease。
- [tag compare](https://github.com/mattpocock/skills/compare/v1.1.0...v1.2.0) 包含 124 个提交、114 个变更路径、2,810 行新增和 1,475 行删除。按 rename detection 统计为 50 个新增路径、52 个修改路径、10 个删除路径、2 个重命名路径。
- 仓库中的 `SKILL.md` 总数由 38 降到 35，但 promoted（`engineering` + `productivity`）技能由 22 增到 25：Engineering 17→18、Productivity 5→7；Deprecated 4→0、Personal 2→0、In Progress 仍为 6 但成员发生替换、Misc 维持 4。[v1.1.0 tree](https://github.com/mattpocock/skills/tree/v1.1.0/skills) · [v1.2.0 tree](https://github.com/mattpocock/skills/tree/v1.2.0/skills)
- promoted 技能的调用构成由 13 个 user-invoked + 9 个 model-invoked，变为 14 个 user-invoked + 11 个 model-invoked。v1.2.0 的 Claude plugin manifest 明确列出全部 25 个 promoted 技能；35 个现存技能全部新增了 Codex `agents/openai.yaml`。[plugin manifest](https://github.com/mattpocock/skills/blob/v1.2.0/.claude-plugin/plugin.json) · [dual-harness invocation contract](https://github.com/mattpocock/skills/blob/v1.2.0/.agents/invocation.md)
- release notes 的 15 条语义变更覆盖了主要的对外分发、稳定技能新增/毕业/删除和核心行为变化；但它不是完整 changelog。tag 区间实际合入 36 个 PR merge（含 release PR），release notes 只链接了 11 个不同 PR 编号，省略了 beta 新技能、全套文档重写和若干一致性修复。

### 总体方向（基于上述事实的推断）

v1.2.0 不是单纯“多加几个 skill”，而是在把仓库从个人可复制的命令集合，收敛成一个有明确产品边界的、多 harness 分发的工作系统：

1. **产品化与分发**：用 Claude Code 官方 marketplace/plugin 提供受管、只读、自动更新的稳定集合，同时保留 skills.sh 作为可编辑复制路线，并为 Codex 补齐原生元数据。
2. **组合与调度**：用 frontier、phase boundary、subagent、decision ticket 等概念降低串行等待与上下文损耗，让 router 能决定何时继续、清空、handoff、委派或 compact。
3. **证据保真**：prototype 不再“用完即删”，而作为 runnable primary source 留在专用分支；research 由后台 agent 产出带来源的资产；文档避免缓存环境中可直接查到的事实。
4. **组合式收敛**：删除已被更深技能吸收的旧技能、移除个人专用 bucket、完成 `PRD`→`spec` 单一术语、将写作原则从“写 skill”上提到“写一切 agent 会读的文档”。
5. **人机边界显式化**：questionnaire 处理“答案在别人脑中”，wizard 处理“必须由人点击/授权”，wait-what 处理“当前消息没讲明白”；能由 agent 查明的事实则并行委派，不转问用户。

这五点是对变更组合的归纳，不是上游作者逐字声明。

## 数量与目录变化

| 维度 | v1.1.0 | v1.2.0 | 净变化 | 一手证据 |
| --- | ---: | ---: | ---: | --- |
| 全部 skills | 38 | 35 | -3 | [v1.1 skills](https://github.com/mattpocock/skills/tree/v1.1.0/skills) · [v1.2 skills](https://github.com/mattpocock/skills/tree/v1.2.0/skills) |
| Engineering | 17 | 18 | +1 | [v1.2 Engineering README](https://github.com/mattpocock/skills/blob/v1.2.0/skills/engineering/README.md) |
| Productivity | 5 | 7 | +2 | [v1.2 Productivity README](https://github.com/mattpocock/skills/blob/v1.2.0/skills/productivity/README.md) |
| In Progress | 6 | 6 | 0（成员变化） | [v1.1](https://github.com/mattpocock/skills/tree/v1.1.0/skills/in-progress) · [v1.2](https://github.com/mattpocock/skills/tree/v1.2.0/skills/in-progress) |
| Deprecated | 4 | 0 | -4 | [v1.2 Deprecated README](https://github.com/mattpocock/skills/blob/v1.2.0/skills/deprecated/README.md) |
| Personal | 2 | 0 | -2，bucket 删除 | [removal PR #752](https://github.com/mattpocock/skills/pull/752) |
| Promoted user-invoked | 13 | 14 | +1 | [invocation rules](https://github.com/mattpocock/skills/blob/v1.2.0/.agents/invocation.md) |
| Promoted model-invoked | 9 | 11 | +2 | [plugin manifest](https://github.com/mattpocock/skills/blob/v1.2.0/.claude-plugin/plugin.json) |

净变化可由逐项变更解释：新增 `to-questionnaire`、`wait-what`、beta `setup-ts-deep-modules`（+3），删除六个技能（-6）；`wizard` 的 bucket 移动和 `writing-great-skills` 的破坏性重命名都不改变总数。

## 实际增加了什么

### 1. 两个新 promoted 技能与一个 beta 技能

| 技能 | 状态与实际行为 | 性质 | 一手证据 |
| --- | --- | --- | --- |
| `to-questionnaire` | 新增为 in-progress，随后毕业到 Productivity；通过采访发送者，生成给真正决策者填写的 Markdown 问卷。最终为 user-invoked。 | 异步决策采集；把“不能由当前用户回答”变成可移交资产 | [最终源码](https://github.com/mattpocock/skills/blob/v1.2.0/skills/productivity/to-questionnaire/SKILL.md) · [初始 PR #572](https://github.com/mattpocock/skills/pull/572) · [毕业 PR #679](https://github.com/mattpocock/skills/pull/679) |
| `wait-what` | 新增 Productivity user-invoked skill，主体只有三条行为指令：重讲刚才内容、补足上下文、使用 ASD-STE100 plain English 与 `CONTEXT.md` 术语。 | 极小的会话内纠偏器；用名字/leading word 触发而非长规则 | [最终源码](https://github.com/mattpocock/skills/blob/v1.2.0/skills/productivity/wait-what/SKILL.md) · [PR #751](https://github.com/mattpocock/skills/pull/751) |
| `setup-ts-deep-modules` | 新增 In Progress user-invoked skill；安装 dependency-cruiser，以包根文件作为 entry points、子目录作为私有实现，要求 pass→故意 deep import fail→恢复 pass 的验证。未进入 plugin 或顶层 promoted 列表。 | beta 工程护栏；用可执行约束落实 deep-module 边界 | [最终源码](https://github.com/mattpocock/skills/blob/v1.2.0/skills/in-progress/setup-ts-deep-modules/SKILL.md) · [配置模板](https://github.com/mattpocock/skills/blob/v1.2.0/skills/in-progress/setup-ts-deep-modules/dependency-cruiser.config.cjs) · [PR #505](https://github.com/mattpocock/skills/pull/505) |

### 2. 双 harness 与插件分发基础设施

- 新增 35 个 `agents/openai.yaml`，与最终 35 个 `SKILL.md` 一一对应；Codex 获得 `display_name`、`short_description`，user-invoked skill 额外获得 `policy.allow_implicit_invocation: false`。Claude frontmatter 与 Codex policy 被定义为必须同步的同一调用语义。[PR #551](https://github.com/mattpocock/skills/pull/551) · [示例：ask-matt metadata](https://github.com/mattpocock/skills/blob/v1.2.0/skills/engineering/ask-matt/agents/openai.yaml) · [调用契约](https://github.com/mattpocock/skills/blob/v1.2.0/.agents/invocation.md)
- 新增 `AGENTS.md`，内容是指向 `CLAUDE.md` 的 symlink，因此两个 harness 读取同一份仓库指令，而非维护生成副本。[tag 中的 symlink](https://github.com/mattpocock/skills/blob/v1.2.0/AGENTS.md) · [PR #551](https://github.com/mattpocock/skills/pull/551)
- `.claude-plugin/plugin.json` 从只有 name + skill 列表扩展为带 version、作者、license、关键词和 25 个 promoted skill 的完整 manifest；新增 repo-local `.claude-plugin/marketplace.json`，并记录“为何先发 Claude plugin、暂不发 Codex plugin”的 ADR。[manifest](https://github.com/mattpocock/skills/blob/v1.2.0/.claude-plugin/plugin.json) · [fallback marketplace](https://github.com/mattpocock/skills/blob/v1.2.0/.claude-plugin/marketplace.json) · [ADR 0002](https://github.com/mattpocock/skills/blob/v1.2.0/.agents/adr/0002-ship-as-a-claude-code-plugin.md) · [PR #536](https://github.com/mattpocock/skills/pull/536)
- “已进入 Claude Code 官方 marketplace”不是只写在本仓库里的声明：Anthropic 官方 marketplace 的 [PR #4479](https://github.com/anthropics/claude-plugins-official/pull/4479) 在本 release 前已合入，当前官方 manifest 也包含 [`mattpocock-skills`](https://github.com/anthropics/claude-plugins-official/blob/36b00173da517876f9e574ef98f3564b0e86c25d/.claude-plugin/marketplace.json)。
- 新增 `.agents/install-block.md`，把安装分成互斥的两条路线：Claude plugin 是受管只读订阅；skills.sh 是用户拥有并可编辑的复制。README 按 Claude/Codex/tinkerer 分受众，promoted docs 页则删除重复安装命令，因为站点自身已有安装 widget。[canonical install block](https://github.com/mattpocock/skills/blob/v1.2.0/.agents/install-block.md) · [README](https://github.com/mattpocock/skills/blob/v1.2.0/README.md) · [PR #681](https://github.com/mattpocock/skills/pull/681) · [PR #749](https://github.com/mattpocock/skills/pull/749)

### 3. 新的辅助资产

- `ask-matt` 新增 `PHASE-BOUNDARIES.md`，提供 Continue → `/clear` → `/handoff` → subagent → `/compact` 的有序决策树；核心代价模型是能否保留当前 conversation 这一 primary source。[文件](https://github.com/mattpocock/skills/blob/v1.2.0/skills/engineering/ask-matt/PHASE-BOUNDARIES.md) · [PR #750](https://github.com/mattpocock/skills/pull/750)
- promoted 技能新增或重写对应 docs 页；最终 25 个 promoted skills 均有页面。写作规范新增统一页面结构、真实问题来源、可观察成功信号、branch 表格/列表与 AI Coding Dictionary 首次用词链接。[writing-docs contract](https://github.com/mattpocock/skills/blob/v1.2.0/.agents/writing-docs.md) · [PR #759](https://github.com/mattpocock/skills/pull/759) · [PR #761](https://github.com/mattpocock/skills/pull/761) · [PR #765](https://github.com/mattpocock/skills/pull/765)

## 实际删除了什么

### 1. 六个技能和整个 Personal bucket

release 所列删除与 tag diff 一致：

- `ubiquitous-language` 被 `domain-modeling` 吸收；
- `design-an-interface` 被 `codebase-design` 吸收，design-it-twice 技法仍在后者的参考资产中；
- `qa` 的用途由 `triage` + `to-tickets` 覆盖；
- `request-refactor-plan` 的用途由 `to-spec` + `improve-codebase-architecture` 覆盖；
- `edit-article` 与 `obsidian-vault` 是作者个人环境专用，因此连同 `personal/` bucket 删除。

一手证据：[PR #752](https://github.com/mattpocock/skills/pull/752) · [v1.1 deprecated tree](https://github.com/mattpocock/skills/tree/v1.1.0/skills/deprecated) · [v1.1 personal tree](https://github.com/mattpocock/skills/tree/v1.1.0/skills/personal) · [v1.2 deprecated README](https://github.com/mattpocock/skills/blob/v1.2.0/skills/deprecated/README.md)

这不是单纯清理文件：四个通用技能的“行为能力”被声明为保留在更深、更宽的替代技能中；两个个人技能则被判定为不应成为公共产品面。

### 2. 旧名称、旧术语与重复文档

- `writing-great-skills` 的目录、`GLOSSARY.md` 和 docs 页全部删除，替换为 `writing-for-agents`，没有 alias 或兼容入口。[破坏性改名 PR #650](https://github.com/mattpocock/skills/pull/650) · [新 SKILL](https://github.com/mattpocock/skills/blob/v1.2.0/skills/productivity/writing-for-agents/SKILL.md) · [新 mechanics reference](https://github.com/mattpocock/skills/blob/v1.2.0/skills/productivity/writing-for-agents/SKILL-MECHANICS.md)
- shipped text 中残留的 `PRD` 术语被清除，只保留 `spec`；changelog 中描述历史 rename 的 `PRD` 不删，因为那里是在记录历史事实。[PR #734](https://github.com/mattpocock/skills/pull/734) · [`to-spec`](https://github.com/mattpocock/skills/blob/v1.2.0/skills/engineering/to-spec/SKILL.md) · [`code-review`](https://github.com/mattpocock/skills/blob/v1.2.0/skills/engineering/code-review/SKILL.md)
- 25 个 docs 页中的重复 Quickstart/install blocks 和 source links 被删；安装事实移到 canonical install block/站点 widget，页面只保留帮助用户选择与判断效果的内容。[PR #757](https://github.com/mattpocock/skills/pull/757) · [writing-docs contract](https://github.com/mattpocock/skills/blob/v1.2.0/.agents/writing-docs.md)

## 实际修改了什么

### 1. 调用、访谈与并行调研

- `grilling` 从“一次一个问题”改为“按 frontier 分轮”：同一轮提出所有前置决策已解决的问题，每轮后重算 frontier；环境事实交给 subagent，只有依赖未完成事实的问题等待。问题格式固定为编号、标题、正文和单独的推荐行；适用范围从软件 plan 扩到任何 plan、decision 或 idea。[最终 SKILL](https://github.com/mattpocock/skills/blob/v1.2.0/skills/productivity/grilling/SKILL.md) · [通用化 PR #532](https://github.com/mattpocock/skills/pull/532) · [frontier PR #586](https://github.com/mattpocock/skills/pull/586)
- `grill-me`、`grill-with-docs`、`triage`、`loop-me` 的措辞同步为 round-by-round，而非保留旧的一问一答节奏。[`triage`](https://github.com/mattpocock/skills/blob/v1.2.0/skills/engineering/triage/SKILL.md) · [`loop-me`](https://github.com/mattpocock/skills/blob/v1.2.0/skills/in-progress/loop-me/SKILL.md)
- `wayfinder` 将普通“investigation ticket”明确命名为 **decision ticket**，强调它解决问题/决策而不是交付实现；chart map 后自动为 research tickets 并行启动 `/research` subagents，research 成为“一次 session 只解一个 ticket”的例外。[最终 SKILL](https://github.com/mattpocock/skills/blob/v1.2.0/skills/engineering/wayfinder/SKILL.md) · [命名 PR #534](https://github.com/mattpocock/skills/pull/534) · [research subagents PR #538](https://github.com/mattpocock/skills/pull/538)
- `ask-matt` 补齐 `grilling`、`resolving-merge-conflicts`、`to-questionnaire`、`wizard`、`wait-what` 等路线，并收紧 wayfinder：它是最重流程，只用于一轮 session 装不下的 fog；地图清晰后默认交给 `to-spec`，不直接 build。[最终 SKILL](https://github.com/mattpocock/skills/blob/v1.2.0/skills/engineering/ask-matt/SKILL.md) · [wayfinder routing PR #535](https://github.com/mattpocock/skills/pull/535) · [phase-boundary PR #750](https://github.com/mattpocock/skills/pull/750)

### 2. Prototype 从临时程序变成可保存的一手证据

- logic prototype 由 terminal app 改为单一 self-contained HTML/CSS/JS 文件，无 build、无 server，可双击并分享给非开发者；UI 要求包含 state panel、free play 与 tabbed guided walkthroughs。[LOGIC.md](https://github.com/mattpocock/skills/blob/v1.2.0/skills/engineering/prototype/LOGIC.md) · [UI.md](https://github.com/mattpocock/skills/blob/v1.2.0/skills/engineering/prototype/UI.md)
- “throwaway”被重新定义为实现约束，而不是删除承诺：prototype 保存在脱离 main 的 `prototype/<name>` 分支，implementation issue 留 context pointer；主干只吸收已验证决定和可复用 pure logic。[SKILL.md](https://github.com/mattpocock/skills/blob/v1.2.0/skills/engineering/prototype/SKILL.md) · [primary-source PR #488](https://github.com/mattpocock/skills/pull/488)

### 3. Skill 生命周期、范围与调用方式

- `wizard` 从 In Progress 移到 Engineering，且由 user-invoked 改为 model-invoked；description 变成精确触发器：infra provisioning、credentials/CI secrets、第三方 dashboard、一次性 migration/cutover，并明确排除 agent 可自行完成的步骤。[最终 SKILL](https://github.com/mattpocock/skills/blob/v1.2.0/skills/engineering/wizard/SKILL.md) · [毕业 PR #680](https://github.com/mattpocock/skills/pull/680) · [model-invoked PR #762](https://github.com/mattpocock/skills/pull/762)
- `writing-for-agents` 把范围从 skill 写作扩大到 skills、`AGENTS.md`/`CLAUDE.md` 及 context pointer 指向的任意 agent 文档；由 user-invoked 改为 model-invoked。原 glossary 合入主 SKILL，skill 独有 invocation mechanics 单独 progressive-disclose；新增 **cache**：环境本身可直接查询的事实不应在文档重复缓存。[最终 SKILL](https://github.com/mattpocock/skills/blob/v1.2.0/skills/productivity/writing-for-agents/SKILL.md) · [mechanics](https://github.com/mattpocock/skills/blob/v1.2.0/skills/productivity/writing-for-agents/SKILL-MECHANICS.md) · [cache PR #682](https://github.com/mattpocock/skills/pull/682)
- `improve-codebase-architecture` 在 Explore 前增加 YAGNI scope：用户指定区域优先，否则读近期 `git log` 找活跃 hot spots；不均匀扫描、避免优化无人修改的 dormant code。[最终 SKILL](https://github.com/mattpocock/skills/blob/v1.2.0/skills/engineering/improve-codebase-architecture/SKILL.md) · [PR #533](https://github.com/mattpocock/skills/pull/533)

### 4. Setup、tracker 与术语一致性

- setup 只在安装了 `triage` 时询问 triage labels，且改成推荐保留默认值的一问；external PR 是否为 request surface 不再是 setup 问题；domain docs 默认 single-context，只在检测到 monorepo 信号时提供 multi-context。[最终 setup SKILL](https://github.com/mattpocock/skills/blob/v1.2.0/skills/engineering/setup-matt-pocock-skills/SKILL.md) · [PR #502](https://github.com/mattpocock/skills/pull/502)
- local-markdown tracker 从单个 `tickets.md` 改为 `.scratch/<feature>/issues/<NN>-<slug>.md` 一票一文件；spec 固定为 `spec.md`；`to-tickets` 与 tracker template 同步。[`to-tickets`](https://github.com/mattpocock/skills/blob/v1.2.0/skills/engineering/to-tickets/SKILL.md) · [local tracker template](https://github.com/mattpocock/skills/blob/v1.2.0/skills/engineering/setup-matt-pocock-skills/issue-tracker-local.md) · [stray-tag fix PR #504](https://github.com/mattpocock/skills/pull/504)
- `tdd` 增加对 `codebase-design` 词汇源的显式 pointer；`resolving-merge-conflicts` 补进 plugin 和 READMEs，`implement` 补进 Engineering README，修复 promoted-bucket invariant。[`tdd`](https://github.com/mattpocock/skills/blob/v1.2.0/skills/engineering/tdd/SKILL.md) · [wiring PR #539](https://github.com/mattpocock/skills/pull/539)

### 5. 人类 docs 被系统性重写

tag diff 中所有 promoted docs 页均有新增或修改，不只是新技能补页。实际发生的规范变化包括：删除页面自己的安装命令和 source link；形成一致的 `What it does`、`When to reach for it`、`Common questions`、`It's working if`、`Where it fits` 结构；FAQ 数量按 wiki/issues/changelog 证据决定；成功信号必须可由读者从自己的工作观察；多分支选择改用表格/列表；AI Coding Dictionary 术语首次出现时链接权威词条。[writing-docs contract](https://github.com/mattpocock/skills/blob/v1.2.0/.agents/writing-docs.md) · [grill-me rewrite PR #755](https://github.com/mattpocock/skills/pull/755) · [WFA rewrite PR #758](https://github.com/mattpocock/skills/pull/758) · [page structure PR #759](https://github.com/mattpocock/skills/pull/759) · [full standardization PR #761](https://github.com/mattpocock/skills/pull/761) · [dictionary links PR #765](https://github.com/mattpocock/skills/pull/765)

## 变化维度与性质

| 维度 | 变化性质 | 代表事实 | 归纳出的方向 |
| --- | --- | --- | --- |
| Portfolio / lifecycle | 新增、毕业、重命名、吸收后删除、个人能力退出公共面 | questionnaire、wizard、wait-what、writing rename、删除六项、beta deep modules | 稳定集合要经过生命周期管理；“能力更多”不等于“入口更多” |
| Harness interoperability | 同一调用语义在 Claude/Codex 分别编码 | frontmatter + 35 个 OpenAI metadata + `AGENTS.md` symlink | 一份 skill source 服务多个 harness，不生成分叉副本 |
| Distribution | 新增受管 plugin，与可编辑复制并存但互斥 | official marketplace、25-skill manifest、canonical install block | 把安装模式视为产品选择：订阅更新或拥有副本 |
| Orchestration | 串行问答改为 frontier rounds；AFK facts 并行；phase boundaries 有显式树 | grilling、wayfinder research subagents、ask-matt | 提高并行度，同时保护上下文与决策依赖 |
| Evidence / provenance | 可运行探索和研究结果成为可定位资产 | prototype branch、research asset、context pointer | 结论与一手证据分离保存，主干保持干净但证据不丢 |
| Human/agent boundary | 针对“别人回答”“人必须操作”“用户没听懂”建立独立工具 | questionnaire、wizard、wait-what | 不把所有阻塞都塞进普通聊天或手写步骤 |
| Scope / complexity | YAGNI、cache、删除 absorbed skills、消除兼容 alias | architecture hot spots、WFA cache、六项删除、rename 无 alias | 用删除、收拢和权威来源降低长期概念面 |
| Ubiquitous language | 单一术语与 router vocabulary | PRD→spec、decision ticket、phase boundary、dictionary links | 共享词汇既服务人类理解，也作为模型 invocation/steering token |
| Human documentation | 从安装/源码镜像转为选择指南与可观察结果 | 25 页重写、FAQ、working signals | docs 不复述 agent runbook；它解决人的 cognitive load |

## Release notes 与 tag/PR 事实对照

### 一致之处

经 tag 源码与 PR 交叉核对，release notes 中以下主张均有对应事实：35 个 Codex metadata 与 `AGENTS.md` symlink；Claude plugin/官方 marketplace；`to-questionnaire` 和 `wizard` 毕业；`wait-what` 新增；prototype 的单文件 HTML 与分支留证；wayfinder decision ticket + research subagents；`writing-for-agents` 的破坏性 rename、model invocation 与 cache；architecture YAGNI；grilling rounds；删除六个 skills；setup/local tracker 改造；`PRD`→`spec` 清理。权威总览见 [release](https://github.com/mattpocock/skills/releases/tag/v1.2.0)、[CHANGELOG at v1.2.0](https://github.com/mattpocock/skills/blob/v1.2.0/CHANGELOG.md) 与 [tag compare](https://github.com/mattpocock/skills/compare/v1.1.0...v1.2.0)。

### 不是矛盾，但 release attribution 被压缩

- release 的 `to-questionnaire` 与 grilling rounds 都链接 release-branch PR [#593](https://github.com/mattpocock/skills/pull/593)，实际功能历史分别在 [#572](https://github.com/mattpocock/skills/pull/572)/[#679](https://github.com/mattpocock/skills/pull/679) 与 [#586](https://github.com/mattpocock/skills/pull/586)。
- release 的 prototype、wayfinder、writing rename/cache、ask-matt 等多条内容共同链接 changeset-condense PR [#763](https://github.com/mattpocock/skills/pull/763)；真正的功能 PR 分别包括 [#488](https://github.com/mattpocock/skills/pull/488)、[#534](https://github.com/mattpocock/skills/pull/534)、[#538](https://github.com/mattpocock/skills/pull/538)、[#650](https://github.com/mattpocock/skills/pull/650)、[#682](https://github.com/mattpocock/skills/pull/682)、[#750](https://github.com/mattpocock/skills/pull/750)。这是 changeset 在发版前被压缩重写，不代表 release 内容虚构。
- `to-questionnaire` 在两个 tag 之间经历“新增到 in-progress → 毕业”；因此最终 tag diff 看起来是直接新增稳定技能，而 release 按历史过程称为 graduate。两种说法都成立。

### Release notes 省略的实际变更

1. beta `setup-ts-deep-modules`（[#505](https://github.com/mattpocock/skills/pull/505)）；
2. promoted wiring 修复（[#539](https://github.com/mattpocock/skills/pull/539)）；
3. 25 个 promoted docs 的系统性重写与 docs governance（[#755](https://github.com/mattpocock/skills/pull/755)、[#757](https://github.com/mattpocock/skills/pull/757)、[#758](https://github.com/mattpocock/skills/pull/758)、[#759](https://github.com/mattpocock/skills/pull/759)、[#760](https://github.com/mattpocock/skills/pull/760)、[#761](https://github.com/mattpocock/skills/pull/761)、[#764](https://github.com/mattpocock/skills/pull/764)、[#765](https://github.com/mattpocock/skills/pull/765)）；
4. `to-tickets` stray `</content>` 修复（[#504](https://github.com/mattpocock/skills/pull/504)）和 `tdd` 对 `codebase-design` 的新增 pointer；
5. canonical install 文案、repo-local fallback marketplace 和文档不重复安装命令等内部维护规则，只被“发布 Claude plugin”部分概括覆盖。

这些省略与 [PR #763](https://github.com/mattpocock/skills/pull/763) 的提交目的“condense changesets and drop docs-only entries”一致；因此应把 release notes 理解为用户可感知的精选摘要，而不是 tag diff 的完整审计记录。

### 一处需要限定语境的字面差异

release 的删除条目说 `skills/in-progress/` “is unchanged”。若该句只指 [removal PR #752](https://github.com/mattpocock/skills/pull/752) 自身，它成立；若理解为整个 v1.1.0→v1.2.0 区间，则不成立：数量虽仍为 6，但 `wizard` 已移出并由 `setup-ts-deep-modules` 补入。tag tree 是直接证据：[v1.1 In Progress](https://github.com/mattpocock/skills/tree/v1.1.0/skills/in-progress) · [v1.2 In Progress](https://github.com/mattpocock/skills/tree/v1.2.0/skills/in-progress)。除此之外，未发现 release 对已发布稳定行为的实质性矛盾。

## 验证方法与边界

本调查只使用一手来源，并做了以下交叉核对：

- Git tags/commits：解析 annotated tag 指向、tag 时间和 `package.json` 版本；
- Git tree/diff：`git diff --shortstat`、`--name-status -M`、`--numstat`、`git ls-tree`，核对文件、bucket、skill 与 metadata 数量；
- Git history：`git log v1.1.0..v1.2.0` 与 merge commits，追溯功能到 origin PR；
- GitHub API：读取 release 元数据和正文、compare 元数据、PR 标题/body/files/commits；
- 上游源码：逐项读取 v1.2.0 的 `SKILL.md`、reference、manifest、README 与 repo contracts；
- 外部一手来源：Anthropic 官方 plugin marketplace PR/manifest，验证“official marketplace”主张。

边界：没有运行这些 skills 的行为实验，也没有判断其设计是否优于 v1.1.0；“总体方向”和维度归纳均明确标为推断。完整机械文件清单以 [GitHub tag compare](https://github.com/mattpocock/skills/compare/v1.1.0...v1.2.0) 为准，本文按语义 change set 聚合，避免把 35 个同构 metadata 文件和 25 个 docs 页逐文件重复罗列。
