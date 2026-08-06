# `mattpocock/skills` v1.2.0 对 AND 的直接影响

> 调查问题：`grilling`、`research`、`prototype`、`tdd`、`code-review` 及相关 upstream workflow 变化，对当前 AND 的运行行为、依赖契约、路由、验证和调查资产管理造成哪些已验证影响或机会？
>
> 范围：只比较上游 `v1.1.0`→`v1.2.0` 与当前 AND 直接组合面；仓库级 metadata、plugin、文档治理留给 #107，最终采纳、删除与 Package 候选留给 #108/#109。

## 结论

上游变化对 AND 不是一次整体升级，而是四种不同结果：

1. **一个已验证运行漂移**：`grilling` 已从逐问等待改为按依赖 frontier 分轮，当前 `and-interview-contract` 仍把“一问一等”写成外部事实。两者同时安装时，访谈 cadence 指令直接矛盾。
2. **一个已验证依赖契约缺口**：AND 只验证五个外部 skill 的名称是否可用，安装命令也未绑定兼容版本；因此环境可以被报告为 ready，却装着与本地复制式假设不兼容的 `grilling`。
3. **多项已经对齐**：AND 已把 cadence 所有权交给 `grilling`、把 prototype/research 资产隔离到调查分支/工作树并留证、在进入 `tdd` 前约定 seam、给 `code-review` 固定点与完整 Spec。
4. **两项只应作为后续选择**：是否在不破坏单调查所有权/结算边界的前提下并行启动 research；是否让 prototype 一律保留为 primary source，而不再允许 `cleanup`。这两项不是 v1.2.0 已证明的 AND 缺陷。

因此，最小必要同步不是复制上游整套 workflow，而是删除 AND 对外部 cadence 的陈旧复述，并让依赖 readiness 能证明**语义兼容**。其余变化应按本地边界逐项采纳或拒绝。

## 影响矩阵

| 组合面 | v1.2.0 事实 | 当前 AND 事实 | 分类 | 已验证影响 |
| --- | --- | --- | --- | --- |
| `grilling` | 一轮询问全部已解锁 frontier 问题；轮后等待并重算 | 一方面声明 cadence 属于 `grilling`，另一方面写死 “one-question waits” | **已验证漂移** | 同一次访谈收到互斥节奏指令；恢复结构的单数 `Current unresolved question` 也偏向旧模型 |
| 依赖 readiness | 同名 skill 行为发生破坏性语义变化，但名称不变 | setup 只按名称检查；安装命令不固定 tag/兼容范围 | **已验证契约缺口** | “available” 不等于“compatible”；本次 `grilling` 漂移是可复现反例 |
| `research` 本体 | `SKILL.md` 在两个 tag 间无变化 | 每个 research investigation 调用 `research`，产出 Markdown 证据 | **已对齐 / 无实质影响** | 不需要为了 v1.2.0 修改 research 调用契约 |
| upstream `wayfinder` research | chart 后为全部 research tickets 并行启动 subagents，research 成为单票限制例外 | 每次 invocation 认领、解决、关闭并投影恰好一个 investigation | **后续判断机会** | 直接照搬会绕过 AND 的所有权、恢复、资产 disposition 与 map projection 原子边界 |
| `prototype` 证据 | 原型在脱离 main 的 throwaway branch 留作 primary source；logic prototype 改为单 HTML | research/prototype 使用专用 branch/worktree，resolution 必须带资产 link 和 `cleanup`/`promote-to-package` | **大体已对齐；有政策选择** | 隔离和留证已对齐；是否允许 cleanup 与上游“一律保留 primary source”存在有意差异 |
| `tdd` | 仅新增：seam 形状未定时参考 `codebase-design` 词汇 | Pack 已确认 highest practical seam；Implement 把 agreed seam 传给 `tdd` | **已对齐 / 无当前影响** | 正常 AND 路径不会到实现阶段才重新决定 seam；若发生，应退回拥有该决策的阶段 |
| `code-review` | 只把 “issue/PRD/spec” 收敛为 “issue/spec”；fixed point 和 Standards/Spec 双轴不变 | Implement 保留完整 fixed point，并把 Package Contract 与 PRD children 作为 Spec | **已对齐 / 无当前影响** | AND 的 PRD 是本地域模型；作为 Spec 输入并不依赖上游保留 `PRD` 词 |

## 1. `grilling`：唯一明确的运行时不兼容

### 上游事实

在 [`v1.1.0` 的 `grilling`](https://github.com/mattpocock/skills/blob/v1.1.0/skills/productivity/grilling/SKILL.md) 中，规则是一次只问一个问题、每题等待反馈。到 [`v1.2.0`](https://github.com/mattpocock/skills/blob/v1.2.0/skills/productivity/grilling/SKILL.md)，规则变为：

- 将决策建模为 design tree；
- 当前 prerequisites 已解决的所有问题组成 frontier；
- 同一轮把整个 frontier 编号提出，并逐题给出推荐；
- 等用户回答整轮后重算 frontier；
- 环境事实交给 subagent，不让不相关的 frontier 问题一起等待。

这是行为语义替换，不是文案润色。[PR #586](https://github.com/mattpocock/skills/pull/586) 是该变化的一手变更记录，[tag compare](https://github.com/mattpocock/skills/compare/v1.1.0...v1.2.0) 给出最终发布边界。

### 当前 AND 事实

当前 [`and-interview-contract`](https://github.com/Andiedie/skills/blob/f50491f8ab4c5f8fad26a3f2f766c4effb07c6ed/skills/ai-native-development/and-interview-contract/SKILL.md) 的总边界是正确的：它明确说 `grilling` 拥有 cadence，AND 只拥有证据、恢复和工作流同步。但同一文件又断言 “The one-question waits required by grilling”，把 v1.1.0 的行为复制成了本地硬约束；恢复模板也只提供 `## Current unresolved question`。

[`and-clarify`](https://github.com/Andiedie/skills/blob/f50491f8ab4c5f8fad26a3f2f766c4effb07c6ed/skills/ai-native-development/and-clarify/SKILL.md) 与 [`and-wayfind`](https://github.com/Andiedie/skills/blob/f50491f8ab4c5f8fad26a3f2f766c4effb07c6ed/skills/ai-native-development/and-wayfind/SKILL.md) 都已把 question order/cadence 交给外部 skill，因此它们的职责边界无需推倒重建。

### 影响

当 v1.2.0 `grilling` 与当前 AND 同时生效时，一个要求“整轮 frontier”，另一个声称外部要求“一次一个”。这是真实冲突，不依赖偏好判断。最小改进方向是让 interview contract 对 cadence 中立，以“当前轮次/当前未解决 frontier”保存恢复状态；不要在 AND 中再次复制上游提问算法。是否采用这一改动属于后续 #108 的采纳决定。

## 2. `research` 与并行：区分方法并行和工作流越界

[`research/SKILL.md` 在 tag 间没有行为 diff](https://github.com/mattpocock/skills/compare/v1.1.0...v1.2.0)，v1.2.0 只为它新增 Codex metadata；所以当前 AND 调用 research、要求一手来源和单一 Markdown 资产没有同步缺口。

变化发生在 upstream [`wayfinder`](https://github.com/mattpocock/skills/blob/v1.2.0/skills/engineering/wayfinder/SKILL.md)：chart map 后立即为所有 research tickets 启动 subagents，并把 research 设为“一次 session 一票”的例外。[PR #538](https://github.com/mattpocock/skills/pull/538) 记录了这项编排变化。

当前 AND 的“一次一个 investigation”不是性能偶然，而是工作流原子边界：选择与认领、方法执行、resolution、close、map projection、恢复清理属于同一个有所有者的调查。多个后台 agent 可以在**同一已认领调查内部**帮助查事实；但一个 invocation 同时结算多张调查票，会让每票的 ownership、publication recovery、asset disposition 和并发投影失去现有保证。

可参考的不是“放宽单票不变量”，而是以后评估能否由多个独立 invocation/actor 各自认领 research investigation，再并行运行并独立结算。没有这样的独立所有权和恢复证据前，直接同步 upstream wayfinder 行为会增加而不是减少复杂度。

## 3. `prototype`：证据模型已对齐，保留策略尚可选择

上游 [`prototype`](https://github.com/mattpocock/skills/blob/v1.2.0/skills/engineering/prototype/SKILL.md) 的核心变化是把 throwaway 从“完成后删除”重新定义为低成本实现约束：原型留在脱离 main 的 branch，implementation issue 指向它，主干只吸收验证后的决定。logic 原型同时改成非开发者可双击运行的单一 HTML。[PR #488](https://github.com/mattpocock/skills/pull/488) 提供该 primary-source 决策的变更记录。

当前 AND 已有更明确的调查资产治理：

- prototype/research 必须在专用 investigation branch/worktree；
- resolution 同时保存结论、资产链接和 disposition；
- 只有 Package Contract 选择 promotion 后，资产才成为交付输入；主干不被探索代码污染。

这与上游的隔离、context pointer、结论与证据分离基本同向。单 HTML 是外部 `prototype` 自己负责的 artifact shape，AND 无需复制其实现规则。

唯一未决差异是生命周期：上游要求原型作为 primary source 保留；AND 允许在 durable answer 已保存后选择 `cleanup`。两者都自洽，现有证据不能证明必须把 AND 改成永久保留。#108 可在“审计价值、分支垃圾、Package 是否依赖交互证据”之间做一次明确选择。

## 4. `tdd` 与 `code-review`：不因术语变化制造工作

上游 [`tdd`](https://github.com/mattpocock/skills/blob/v1.2.0/skills/engineering/tdd/SKILL.md) 只新增一个 pointer：若 public interface/seam 的形状仍在讨论，参考 `codebase-design` 的词汇。当前 AND 的 [`and-pack`](https://github.com/Andiedie/skills/blob/f50491f8ab4c5f8fad26a3f2f766c4effb07c6ed/skills/ai-native-development/and-pack/SKILL.md) 在发布 Package 前已经要求确认最高可行 verification seam；[`and-implement`](https://github.com/Andiedie/skills/blob/f50491f8ab4c5f8fad26a3f2f766c4effb07c6ed/skills/ai-native-development/and-implement/SKILL.md) 再把 agreed seam 作为 `tdd` 输入。这正好避免在实现中临时发明测试边界。

上游 [`code-review`](https://github.com/mattpocock/skills/blob/v1.2.0/skills/engineering/code-review/SKILL.md) 的运行机制没有变化，只把 PRD 专用词删成通用 `spec`。[PR #734](https://github.com/mattpocock/skills/pull/734) 是术语收敛记录。AND 把完整 Package Contract 和每个 acceptance-bearing PRD child 作为 Spec 提供，符合上游接口；没有理由删除 AND 内部用于表达父交付与切片关系的 PRD 概念。

因此，这两项的正确结论是“已对齐/无实质影响”，不是为了表面同词而重命名或新增依赖。

## 5. 依赖 readiness：名称存在不再足以证明可运行

当前 [`setup-and`](https://github.com/Andiedie/skills/blob/f50491f8ab4c5f8fad26a3f2f766c4effb07c6ed/skills/ai-native-development/setup-and/SKILL.md) 只从 session skill list 或列表命令确认七个名称存在；[`docs/skills.md`](https://github.com/Andiedie/skills/blob/f50491f8ab4c5f8fad26a3f2f766c4effb07c6ed/skills/ai-native-development/docs/skills.md) 的外部安装命令也没有 tag、版本范围或兼容声明。

这套检查能回答“缺不缺 skill”，不能回答“该同名 skill 的语义是否满足 AND 假设”。`grilling` 在保持名称不变时更换 cadence，而本地仍复制旧语义，已经构成具体反例：setup 可报告 ready，运行时仍冲突。

此前 [#2 的完成记录](https://github.com/Andiedie/skills/issues/2#issuecomment-4911233227) 解决的是缺失技能时可诊断、可失败，不是版本/语义兼容；[#22 的决策记录](https://github.com/Andiedie/skills/issues/22#issuecomment-4932788920) 则已确立“按上游 tag 实际内容判断、只改已验证行为缺口”的原则。本调查没有足够证据直接选择 pin、vendor、最低版本、能力探针或移除复制式假设中的哪一种；它只证明单纯名称检查已不能覆盖当前契约风险。

## 可以带入 #108 的候选，不是本调查的决定

1. **应修候选**：把 `and-interview-contract` 的逐问假设改成 cadence-neutral 的 round/frontier 恢复表达；保留“`grilling` owns cadence”的单一权威。
2. **应补契约候选**：为五个外部依赖声明并验证兼容语义；优先考虑删除本地复制式假设，其次才是版本 pin 或额外探针。
3. **可评估候选**：以独立调查所有权为前提并行 research，而不是一个 invocation 多票结算。
4. **可选择候选**：prototype 默认 `promote-to-package`/保留 primary source，还是继续允许显式 `cleanup`。
5. **拒绝同步候选**：不因 `tdd` pointer、`code-review` 的 PRD→spec 文案或 logic prototype 的 HTML 形态，在 AND 中重复上游实现规则。

这些候选只有在 #108 经证据和用户选择收敛后，才可进入 Package。当前调查不修改运行 skill、依赖安装或仓库文档。

## 方法与证据边界

本调查使用的事实来源均为一手来源：

- 上游 `v1.1.0`、`v1.2.0` tags 及其 Git tree/diff；
- 上游最终 `SKILL.md` 与对应功能 PR；
- 当前仓库提交 `f50491f8ab4c5f8fad26a3f2f766c4effb07c6ed` 的 AND skills/docs；
- 当前仓库 #2、#22 的历史决策与完成记录。

没有运行完整 HITL 行为实验，也没有安装或升级本机 skills。结论中的“已验证漂移”只指源码契约可直接证明的矛盾；并行研究和原型保留策略被明确保留为后续判断，不伪装成已决定改动。仓库级 Codex metadata、Claude plugin、portfolio/docs governance 不在本调查范围内，由 #107 处理。
