# STATE — 驻场手册 (FDE 三月纲要)

> 每次会话开场先读本文件。完整纲要见 README.md，本周任务见 phase-01/week-01-tasks.md。

最后更新：2026-08-18

## 这是什么

用户（GM，健身器材公司，零代码基础）的 3 个月 FDE（AI 落地方向）能力养成计划。
目标：3 个月后能独立接住一个客户的 AI 落地需求，走完摸底→判断→搭建→验收→交付，
不靠人手把手指导。纲要设计过程见对话记录，已发布 Artifact：
https://claude.ai/code/artifact/bc6e384e-4c69-4b40-9043-1baa80085681

## 进度

- [x] 2026-08-16 纲要确认（五步方法论 + 固定技术骨架 Python/Claude API/SQLite+Pandas/Streamlit/Railway/Git + 三段模拟客户）
- [x] 2026-08-16 Phase 01 Week 1 任务拆解 + 首批闪卡完成
- [x] 2026-08-16 推送机制搭建完成并测试通过——**邮件闪卡**（不是 Telegram，见下方说明），
      routine `trig_01WqFq2oP9jkSELV75hLiNpu`，工作日 10:03/13:03/16:03 布里斯班时间
- [x] 2026-08-18 Week 1 Day 1（环境搭建）实操完成——用户在自己 Mac 上建了 `fde-week1`
      项目文件夹 + venv 虚拟环境，装了 `anthropic` 包并验证 import 成功。过程中让用户
      自己讲了一遍"为什么要用虚拟环境"，讲得基本到位（隔离 + 干净），补充了"不同项目
      依赖版本冲突"这个具体场景。（闪卡进度 w1-01~w1-06 已经因为测试提前推送过，跟这里
      的实操进度是两条独立的线，不用对齐）
- [ ] Week 1 Day 2（第一次调用 Claude API）尚未开始——下次会话从这里接着走：去
      console.anthropic.com 申请 API key（用户自己做，Claude Code 代劳不了）、写最短脚本
      发一句话给模型并打印回复、API key 存环境变量不要写死在代码里

## 推送机制（最终方案，与最初设计不同，勿被 automation/routine-design.md 的旧草稿带偏）

**渠道是邮件，不是 Telegram。** 排查过程：
1. Telegram：云端 routine 沙盒的出网白名单不含 api.telegram.org，curl 直接 403，排除。
2. `PushNotification` / Remote Control：查证后确认 Remote Control 推送要求本地 Mac 开着
   活跃会话，云端 routine 独立触发时永远推不到手机，排除。
3. 最终用 **Gmail**（MCP 连接器，云端环境默认自动带上，不受出网白名单限制）发邮件到
   michaelxu0814@gmail.com。

**进度不写回仓库。** 一开始设计是 routine 读写 `phase-01/progress.json` 并 git commit/push，
但云端环境对 `michaelxu0814-ai/FDE-Manual` 只有读权限、没有写权限（git push 和 GitHub API
写入 `create_or_update_file`/`push_files` 全部 403 "Resource not accessible by integration"）。
把仓库改成 public 只解决了读（clone 不需要认证），写权限这条路排查后确认走不通——大概率是
Claude 的 GitHub App 装在这台机器本地 `gh` 用的账号（UEXU 或另一个）上，没授权到
michaelxu0814-ai 这个账号 / 这个仓库，且这个授权环节需要账号本人在网页里操作，本 session
无法代劳，也没找到具体入口（尝试过 github.com/settings/installations 未果）。

改成**无状态设计**：routine 每次触发都用 Gmail 搜索工具查"FDE闪卡 · Week N"开头的已发邮件，
从邮件主题反推哪些卡片 id 已经发过，不依赖仓库里任何可写状态。`phase-01/progress.json` 和
`phase-01/flashcards.json` 里 `week_complete_notified` 字段等设计已经作废，仓库现在纯只读，
`progress.json` 文件留着但 routine 不会碰它，不用管它是否准确。

routine 当前 prompt 的真实版本以 `RemoteTrigger action:get trigger_id:trig_01WqFq2oP9jkSELV75hLiNpu`
查到的为准，不要看 automation/routine-design.md 的旧草稿（那是排查前的设计，已过时，
没有回头更新，下次有空再补一份准确版）。

## 仓库

github.com/michaelxu0814-ai/FDE-Manual （**public**，已改公开以绕开云端写权限问题；
内容本身不敏感，个人学习项目）

## 关键约束（勿忘）

- 技术骨架固定，不随 phase 换：Python + Claude API + SQLite/Pandas + Streamlit + Railway/Vercel + Git + Claude Code
- 3 段模拟客户与用户现有工作（健身器材公司）完全脱钩，避免混淆
- 每天 1 小时深度 session 是核心学习场景；闪卡推送只是轻量巩固，前期先跑，量级可调

## 教学规则 · 主动延展（2026-08-18 用户提出，此后每天必做）

**问题**：用户处在"不知道自己不知道什么"的阶段。Day 1 那天他碰巧知道 Docker、也碰巧
知道虚拟环境不止 venv 一种，所以问出了口；但绝大多数盲区他提不出问题，靠他发问来
补全知识边界这条路本身不成立。

**规则**：每天 session 结束前，必须主动给一段「延展 · 你没问但该知道的」，不等用户问。
内容不是把当天技术点讲更深，而是**画出这个技术点周围的地图**：同类工具还有哪些、上下游
是什么、行业里真实怎么用、以及**哪些现在不用管**（这条同样重要，防止焦虑和跑偏）。

**每条延展固定四要素**，缺一不可：
1. 它是什么（一句话，大白话）
2. 跟今天学的东西什么关系（同类替代品？上一层？下一层？）
3. 什么场景下你会真的碰到它
4. **现在需不需要管**（大部分答案是"不用，知道有这么个东西就行"）

**量级**：每天 2–4 条，宁可少而准。这是"知道有这么个东西"级别的地图，不是新的学习任务，
不占用当天 1 小时深度实操的预算。

**已写进 `phase-01/week-01-tasks.md` 每天末尾**。Week 2 及以后的任务文件同样照此格式写。

## 工作规约 · 动作级卡点（2026-08-18 用户提出，见 CONVENTIONS.md）

用户当天追问"pip 装包前的安全检查，是谁去扫一眼？不是应该在安装前就约定好吗"——
一针见血：Day 1 延展里写了这条纪律，但装 `anthropic` 时 Claude 凭既有知识直接装了，
用户也没查，**没有任何一方真的执行过**。纪律没绑到具体动作上就是空话。

于是新建 `CONVENTIONS.md`，把有风险的动作都变成执行前的强制卡点：
1. **装任何包之前**——先给来源核查卡（包名/维护者/判断依据是官方文档还是既有知识/风险
   等级/连带依赖），停下等用户点头再装。风险中或高时必须实际查 pypi.org，不许凭记忆。
2. **密钥进文件之前**——`.gitignore` 先于 `.env`，提交前扫一遍有没有密钥字符串。
3. **执行前必须解释**——不许一口气跑完再统一解释。

`automation/local-claude-md-template.md` 是同一套规矩的压缩版，给用户复制到自己电脑上
每个项目的 `CLAUDE.md` 里，这样本地 Claude Code 会自动遵守，不用每次口头叮嘱。

**下次会话注意**：Day 2 装包/存 key 时，要真的走这套流程，别又变成写在文档里没执行。
