# STATE — 驻场手册 (FDE 三月纲要)

> 每次会话开场先读本文件。完整纲要见 README.md，本周任务见 phase-01/week-01-tasks.md。

最后更新：2026-08-20

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
- [x] 2026-08-20 Week 1 Day 2（第一次调用 Claude API）**完成**：
      - [x] API key 已申请，存进 `fde-week1/.env`（单行 `ANTHROPIC_API_KEY=...`，1 行已核实）
      - [x] `.gitignore` 先建后写 key，顺序正确；已扩成 `.env*` 通配
      - [x] `python-dotenv` 走了 CONVENTIONS.md 卡点 1——**这次真的查了 pypi.org**
            （1.2.3 / 2026-08-16 发布 / theskumar 维护 / BSD-3 / Trusted Publishing / 无依赖），
            出卡等用户点头后才装。规矩第一次真正生效
      - [x] 写好 `hello_claude.py`（load_dotenv + `anthropic.Anthropic()` 空构造 + 
            `messages.create(model="claude-opus-5", max_tokens=1000)` + 遍历 content 打印 text）
      - [x] **脚本跑通了**——`python3 hello_claude.py` 打印出模型回复（"我是 Claude，
            由 Anthropic 开发的 AI 助手…"）。Day 2 核心目标达成
      - [x] `.env.save` 已清除，`.gitignore` 已加 `.env*`（用户跑了两遍，所以文件里有两行
            `.env*`，Git 不在乎重复，无需处理）
- **Day 2 的第二个教训（比第一个更值钱）**：`.env*` 那条修复措施——发现了、讨论了、
  给了命令、用户也认可了——**然后没被执行，流程继续往下走了**，直到看用户贴的终端截图
  才发现 `.env.save` 还在。**"谁去扫一眼"的下一句是"扫完谁去确认真的改了"。交付里最
  常见的事故不是没发现问题，是发现了、说好要改、然后没人回头确认改没改。** 这直接
  催生了当天的执行清单设计（每条动作必须配「怎么证明做完了」一栏）。
- **下次会话从 Day 3 开始**：不写新代码，逐行拆解 `hello_claude.py`，搞懂五个问题——
  这本质上是不是一次 HTTP 请求 / `role` 的 user 与 assistant / `system` 参数与 user 消息
  的区别 / `model` 与 `max_tokens` 各控制什么 / token 是什么、为什么按 token 计费。
  产出不是代码，是用户能不看答案口头讲一遍。
- **Day 2 中途抓到的真实安全问题（教学素材，值得记住）**：`ls -a` 发现 `.env.save`——
  nano 被中断时留下的应急备份，里面同样有 key，但当时 `.gitignore` 只写了 `.env`，
  覆盖不到它。当时还没 `git init` 所以没实际泄露。处理：`.gitignore` 改用 `.env*` 通配 +
  `rm .env.save`。**给用户点明的道理：照着清单做完 ≠ 安全，清单是人写的、人想不到的
  就不在清单上；这个洞是 `ls -a`「去看现场」抓出来的，不是任何一条纪律抓出来的——
  这就是五步方法论里「验收 Harden」存在的理由。**
- **Day 2 踩过的坑**：新开终端窗口没激活 venv → `pip: command not found`。借机给了
  `command not found` 四步排错链（拼写→环境激活了吗→真装过吗→`which`）和开工三连
  （`cd ~/fde-week1` / `source venv/bin/activate` / `pwd`）。

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

## ⚠️ 2026-08-29 课程方向重大调整（先读这段）

用户的批评：**"像在高速公路上学骑自行车"**——课程在教手敲 venv、逐行拆 API 参数，
而他要的是"你开跑车，告诉我怎么给你指令"。**这个批评是对的，原设计方向错了。**

原 Day 1–7 的设计把"学编程"当成了"学交付"。真实 FDE 不是自己写每一行，是**指挥 AI
写、然后判断写得对不对**。三天下来用户学会了 `cd`/`source`/`echo`，却没学会一句能让
Claude 产出交付物的指令。

**新主线：`PLAYBOOK.md`（指挥手册）**——五步循环每步的可复制指令模板、下指令五条通则、
卡住时的四句话、安全卡点。核心是"说要什么和怎么算好，不说怎么做"。

**保留的一点分歧（已跟用户讲明）**：用户不需要会写代码，但需要看得懂产出、判断得出
好坏——因为 AI 犯错时看起来和正确时一模一样。所以原理不是不学，是**换时机**：
不预习，在需要判断对错时现学。这跟用户说的"先给 123 再解释原理"是一致的。

**Week 1 Day 3–7 的原计划（手敲脚本学语法）作废。** 接下来直接用 PLAYBOOK 的方式
推进 Phase 01 的电商客服助手项目，用户下指令、判断产出，边做边补原理。

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

## 教学规则 · 每天补执行清单（2026-08-20 用户提出）

用户要求"把每次课程总结成步骤清单，按步骤执行就不会出错"。**照做，但加了一栏**——
因为 Day 2 恰好暴露了清单的两种失效方式，它们需要不同的解法：

1. `.env.save` 泄露隐患 —— **清单上根本没这条**（人想不到的事不会写进清单）
   → 解法：每天的清单里固定留一步"**去看现场**"（`ls -a` 这类），实际看有什么，
     而不只核对预期中的东西
2. `.gitignore` 改 `.env*` —— **清单上有、说好了、但没执行，也没人回头确认**
   → 解法：每条动作**必须配一栏「怎么证明做完了」**，写清楚看到什么才算过。
     "我记得我做了"不算证明

清单文件：`phase-01/week-01-checklist.md`（三栏：动作 / 命令 / 怎么证明做完了）。
**每天上完课把当天的补进去**，Week 2 起每周一个 `week-0X-checklist.md`。

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
