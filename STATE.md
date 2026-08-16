# STATE — 驻场手册 (FDE 三月纲要)

> 每次会话开场先读本文件。完整纲要见 README.md，本周任务见 phase-01/week-01-tasks.md。

最后更新：2026-08-16

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
- [ ] Week 1 尚未正式开始执行（闪卡已经因为测试跑掉了 w1-01、w1-02，用户实际上周一开始前
      已经"看到"这两张，可以酌情跳过或当复习）

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

### 关于「为什么别的项目能发 Telegram」（2026-08-16 查证，别再重复排查）

用户提到 Telegram 上收到 `zenithOpsBot` 的推送，怀疑云端也能发。查证结论：**能不能发 Telegram
取决于「谁在发」，不取决于「发什么」。**

`zenithOpsBot` 属于 **Zenith Ops**——用户健身器材公司（Zenith Muscle Fitness）那套运营自动化，
跟 AuShow Radar / AUComplianceAI 都无关。核实过程：
- 两个仓库的全部历史（aushow 61 commits、aucompliance 49 commits）全文搜 `telegram`/`zenith`
  零匹配；michaelxu0814-ai 名下另外两个仓库（aus-ticketing 空仓、company-website）也没有。
- Gmail 里有完整的 Zenith Ops 通知流：发件人 `support@zenithmusclefitness.com`，主题前缀
  `[Zenith Ops]` / `[MC Monitor]` / `[Optimizer]`，固定节奏（每天 09:00 布里斯班、周日 18:00 周报）。
  自有域名 + 自有 SMTP + 自有调度 = 跑在用户自己的基础设施上（Mac 本地，或 `UEXU` 那个 GitHub 账号下）。
- 所以它出网不受限，直连 `api.telegram.org` 没问题；而 FDE 闪卡跑在 Claude 云端 routine 沙盒里，
  代理层白名单不含 Telegram（本会话再次实测 curl 仍是 403），这个限制绕不过去。

FDE 闪卡若要改用 Telegram，只能把「发送」这一步挪到有出网自由的地方，两条路：
- **A. 挂进 Zenith Ops**：复用现成的 token/chat_id/定时器，加个读 flashcards.json 的小脚本即可，
  最省事；但继承 Mac 的毛病——关机不跑、漏了不补（AuShow 也有这个问题）。闪卡漏一天无所谓。
- **B. 部署到 Railway**：小服务 + cron 自己推。不依赖 Mac 开机，且 Railway 本就在课程固定技术栈里，
  搭这个本身就能当练手项目（定时任务 / 外部 API / 部署 / 密钥管理，全是 FDE 要会的）。

两条都需要用户提供 bot token + chat_id。**建议用 @BotFather 新建一个专用 bot**，别跟公司运营
告警共用 zenithOpsBot，否则学习闪卡和生意告警混在一个会话里更乱。

**决策未定，等用户拍板；在此之前邮件方案继续跑，不要擅自改 routine。**

## 仓库

github.com/michaelxu0814-ai/FDE-Manual （**public**，已改公开以绕开云端写权限问题；
内容本身不敏感，个人学习项目）

## 关键约束（勿忘）

- 技术骨架固定，不随 phase 换：Python + Claude API + SQLite/Pandas + Streamlit + Railway/Vercel + Git + Claude Code
- 3 段模拟客户与用户现有工作（健身器材公司）完全脱钩，避免混淆
- 每天 1 小时深度 session 是核心学习场景；闪卡推送只是轻量巩固，前期先跑，量级可调
