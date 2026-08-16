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

### 关于「为什么别的项目能发 Telegram」（2026-08-16 查证）

用户提到 Telegram 上收到 `zenithOpsBot` 的推送，问云端能不能照做。**核心结论：能不能发
Telegram 取决于「谁在发」，不取决于「发什么」。** FDE 闪卡跑在 Claude 云端 routine 沙盒里，
代理层白名单不含 `api.telegram.org`（本会话再次实测 curl 仍是 403），这条绕不过去。

**已确证：`zenithOpsBot` 不属于 AuShow Radar / AUComplianceAI。**
- 两仓库全部历史（aushow 61 commits、aucompliance 49 commits）全文搜 `telegram`/`zenith` 零匹配；
  michaelxu0814-ai 名下另两个仓库（aus-ticketing 空仓、company-website）也没有。
- 它属于 **Zenith Ops**——用户健身器材公司（Zenith Muscle Fitness）的运营自动化系统。

**Zenith Ops 架构（据 Google Drive 上的完整备份，快照 2026-05-03）：**
- 跑在 **Windows**：`C:\Users\micha\Documents\ZenithMuscle-Ops\`（不是 Mac）
- **PM2** 托管：`ecosystem.config.cjs`，进程名 `zenith-ops`，入口 `agents/scheduler.js`，autorestart
- 开机自启：Windows 任务计划程序 `ZenithMuscleOps-AutoStart` → `start-zenith-ops.bat`
- 定时靠**进程内 cron**（`agents/scheduler.js` 统管：每小时邮件序列、每日 09:30 广告守卫、
  每周日 22:00 Optimizer 等）
- Gmail 里有完整通知流佐证：发件人 `support@zenithmusclefitness.com`，主题前缀
  `[Zenith Ops]` / `[MC Monitor]` / `[Optimizer]`

**⚠️ 但 Telegram 的具体实现没查到，且已知查不到的原因：**
快照时点（5 月初）Zenith Ops **完全没有 Telegram**——`.env` 和 `.env.template` 里告警渠道只有
`ALERT_EMAIL` + Zoho SMTP 和一个空的 `SLACK_WEBHOOK_URL`，无任何 `TELEGRAM_*` 变量；
`CLAUDE.md`（4/21，18KB，Phase 1–14 写得极细）通篇零处提 Telegram，通知 Owner 一律发邮件。
全 Drive 搜 `telegram` 只命中 Claude Code 官方插件市场缓存里的 telegram 插件目录（和
discord/linear/playwright 一起整包备份的），**那是插件仓库快照，不是 Zenith Ops 在用它的证据**。

即：**能远程接触到的一切都停在 2026-05，Telegram 是 5 月之后加的，加在看不到的地方。**
GitHub 上没有这个项目，ListAgents 也够不到那台 Windows。再往下就是猜测，已停止。

**下次要闭环，让用户在那台 Windows 上跑：**
```
cd /d C:\Users\micha\Documents\ZenithMuscle-Ops
findstr /sil "telegram" *.js *.cjs *.json .env agents\* scripts\* configs\*
pm2 list
```
三种结果分别对应：(a) `.env` 有 `TELEGRAM_BOT_TOKEN` + 代码里有 `api.telegram.org` → 自写直连
Bot API，最好抄；(b) 有第二个 pm2 进程或 `.mcp.json`/`--channels` → 走 Claude Code telegram
插件（MCP + Bun，需常驻 Claude 会话，较重）；(c) 都没有 → 推送不在 Zenith Ops 里，得另找。

**FDE 闪卡改用 Telegram 的两条路（等上面查清再定）：**
- **A. 挂进 Zenith Ops**：复用现成 token/chat_id/调度器，加个读 flashcards.json 的小脚本。最省事，
  但继承「那台机器关机就不跑、漏了不补」的毛病。闪卡漏一天无所谓。
- **B. 部署到 Railway**：小服务 + cron 自己推，不依赖任何本地机器。Railway 本就在课程固定技术栈里，
  搭这个本身可当练手项目（定时任务 / 外部 API / 部署 / 密钥管理，全是 FDE 要会的）。

两条都需要 bot token + chat_id。**建议 @BotFather 新建专用 bot**，别和公司运营告警共用
zenithOpsBot，否则学习闪卡和生意告警混在一起更乱。

**决策未定，等用户拍板；在此之前邮件方案继续跑，不要擅自改 routine。**

### ⚠️ 安全问题（2026-08-16 排查中顺带发现，未处理）

Google Drive 上的 ZenithMuscle-Ops 备份里，`.env` 和 `.env.template` **明文存着一批仍在使用的
凭据**：Anthropic API key、Shopify Admin token 及 client secret、Google Ads developer token /
client secret / refresh token、Zoho 邮箱密码、Pinterest token。`.env.template` 本应是可分享的
模板，却填着真实的 Anthropic key 和 Shopify token。

**成因**：2026-05-03 的一次搬家式整目录上传（大概率 Windows → Mac 迁移）。My Drive 根目录下
`.claude` / `.claude-mem` / `.config` / `ZenithMuscle-Ops` 四个文件夹创建时间都是那一天，是把
`C:\Users\micha\` 下的目录整包传上去的（`.claude/projects/c--Users-micha-Documents-ZenithMuscle-Ops`
这个命名格式可佐证）。一次性上传，非持续同步。根因是**防护只覆盖了 Git（.gitignore），没覆盖备份
通路**——`.env` 对"选中文件夹→上传"毫无抵抗力。

**暴露面（已核查权限）**：`ZenithMuscle-Ops` 文件夹和 `.env` 文件的权限均为
**仅 michaelxu0814@gmail.com (owner)**，未共享、无公开链接。所以不是已发生的泄露，是风险敞口。
但敞口真实：(1) Google 账号成了所有密钥的单点故障；(2) 任何拿到 Drive 授权的第三方应用都能读到
——本次排查就是通过 Drive 连接器读出 `.env` 原文的；(3) 备份不会自己过期。

已告知用户尽快轮换（优先级：Anthropic key → Shopify token/secret → Zoho 邮箱密码 →
Google Ads refresh token/secret → Pinterest token），换完需在 Windows 上更新 `.env` 并
`pm2 restart zenith-ops`，否则系统开始报 401。另建议删除 Drive 上的副本（用户未确认，
**不要擅自删除**）、密钥改存密码管理器、`.env.template` 只留变量名、Google 账号开 2FA 并清理
第三方 Drive 授权。

**本仓库未记录任何凭据值，也不要往这里抄。**

> 这个案例可以直接用作课程里「密钥管理」一节的教学素材——"防护只覆盖一条通路"是行业中最常见的
> 密钥泄露成因之一，比教科书例子实在。

## 仓库

github.com/michaelxu0814-ai/FDE-Manual （**public**，已改公开以绕开云端写权限问题；
内容本身不敏感，个人学习项目）

## 关键约束（勿忘）

- 技术骨架固定，不随 phase 换：Python + Claude API + SQLite/Pandas + Streamlit + Railway/Vercel + Git + Claude Code
- 3 段模拟客户与用户现有工作（健身器材公司）完全脱钩，避免混淆
- 每天 1 小时深度 session 是核心学习场景；闪卡推送只是轻量巩固，前期先跑，量级可调
