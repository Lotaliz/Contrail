---
id: ai-safety-moderation-reading-list-2024-2026
type: synthesis
title: 安全四大顶会 AI 审核与防护系统阅读清单（2024—2026）
tags: [research]
project_id: ai-safety-systems-security-venues
sources: [paper-wu-2024-legilimens, paper-he-2024-yopo, paper-paudel-2024-contextual-soft-moderation, paper-paudel-2024-pixelmod, paper-guo-2024-ugcg-guard, paper-zhuang-2025-hmguard, paper-wang-2024-moderator, paper-qi-2025-safeguider, paper-luo-2025-unsafe-search, paper-kireev-2025-telegram-propaganda, paper-wang-2025-selfdefend, paper-zhang-2025-jbshield, paper-liu-2026-sentinel, paper-zhong-2026-rennervate, paper-pang-2026-dualsentinel, paper-he-2026-attriguard, paper-li-2026-ace, paper-syros-2026-saga, paper-qu-2024-unsafebench, paper-shen-2025-hatebench, paper-gao-2025-content-moderation-products, paper-wei-2026-character-platforms, paper-lipphardt-2026-global-moderation]
status: active
related: [ai-safety-systems-security-venues]
created: 2026-10-21
updated: 2026-10-21
---

# 安全四大顶会 AI 审核与防护系统阅读清单（2024—2026）

## 范围与证据强度

- 年份按正式会议年计：2024、2025、2026；检索截至2026-10-21。YOPO预印本为2023、UnsafeBench预印本为2024，但分别按S&P2024、CCS2025纳入。
- 四会：IEEE S&P、USENIX Security、ACM CCS、NDSS；只纳入主会论文，不把workshop、poster、Enigma受邀演讲或普通arXiv当作主会论文。
- 本清单供用户自行初筛，23篇按任务分组；本轮核验题名、会议归属、官方/作者摘要与公开入口，不声称逐篇精读或复现。新登记9篇维持discovered；既有论文阅读层级不变。
- “系统”分三种：直接内容审核/生成控制、运行时Guard及Agent安全控制、基准/真实平台测量。后两种不冒充传统敏感内容分类系统；纯模型检测器也不冒充完整部署系统。
- 不重复已精读的Qu2025 UnsafeConcepts论文；以新攻击为主要贡献者不进入系统主清单。HateBench含攻击研究，仅作为明确标注的测量补充。
- ★为结合用户Guard研究的个人阅读优先级，不是论文质量排名、会议奖项或实测性能排序。

## A. 直接内容审核与生成控制（10篇）

| 标题与原文入口 | 来源 | 主题及系统边界 |
|---|---|---|
| ★ [Legilimens: Practical and Unified Content Moderation for Large Language Model Services](https://arxiv.org/abs/2408.15488) | ACM CCS 2024；官方接收表核验 | 从宿主LLM提取概念特征，统一审核输入与输出；重点是准确性和额外审核成本。 |
| [You Only Prompt Once: On the Capabilities of Prompt Learning on Large Language Models to Tackle Toxic Content](https://arxiv.org/abs/2308.05596) | IEEE S&P 2024；官方接收表核验 | 用LLM提示学习做毒性分类、毒性片段检测和去毒改写；偏审核方法而非完整服务架构。 |
| ★ [Enabling Contextual Soft Moderation on Social Media through Contrastive Textual Deviation](https://www.usenix.org/conference/usenixsecurity24/presentation/paudel-enabling) | USENIX Security 2024 | 在Lambretta软审核管线加入立场检测，区分支持错误信息与引用后反驳，降低语境误报。 |
| [PIXELMOD: Improving Soft Moderation of Visual Misleading Information on Twitter](https://www.usenix.org/conference/usenixsecurity24/presentation/paudel-pixelmod) | USENIX Security 2024 | 感知哈希、向量数据库和OCR结合，查找应补充误导性警告标签的图片；检索辅助审核，不是通用VLM裁判。 |
| [Moderating Illicit Online Image Promotion for Unsafe User Generated Content Games Using Large Vision-Language Models](https://www.usenix.org/conference/usenixsecurity24/presentation/guo-keyan) | USENIX Security 2024 | UGCG-Guard：VLM条件提示与情境推理，审核社交媒体上推广不安全用户生成游戏的图片，关注未成年人风险。 |
| [I know what you MEME! Understanding and Detecting Harmful Memes with Multimodal Large Language Models](https://www.ndss-symposium.org/ndss-paper/i-know-what-you-meme-understanding-and-detecting-harmful-memes-with-multimodal-large-language-models/) | NDSS 2025；HMGUARD | 用多模态结构化推理识别图文反差、组合构图、宣传技巧和隐含伤害意图。 |
| ★ [Moderator: Moderating Text-to-Image Diffusion Models through Fine-grained Context-based Policies](https://arxiv.org/abs/2408.07728) | ACM CCS 2024；官方接收表/作者版本核验 | 管理员编写细粒度情境政策，再用自生成样本与task vector修改生成模型权重；不是普通在线prompt改写。 |
| [SafeGuider: Robust and Practical Content Safety Control for Text-to-Image Models](https://academic-page.github.io/SafeGuider/) | ACM CCS 2025；作者正式项目页/BibTeX核验 | 从文本条件embedding识别风险，再以安全感知特征擦除beam search保留无害生成语义；非单纯全拒绝。 |
| [Unsafe LLM-Based Search: Quantitative Analysis and Mitigation of Safety Risks in AI Web Search](https://www.usenix.org/conference/usenixsecurity25/presentation/luo-zeren) | USENIX Security 2025 | 审核AI搜索回答与恶意URL；结合内容精炼和URL检测，处理正常提问也可能引用危险网站的风险。 |
| [Characterizing and Detecting Propaganda-Spreading Accounts on Telegram](https://www.usenix.org/conference/usenixsecurity25/presentation/kireev) | USENIX Security 2025 | 根据正常消息和宣传回复间的关系识别宣传账号，面向群组管理员；账号/传播活动检测，不等同单句毒性审核，也不预设是LLM方案。 |

软审核指增加警告或事实核查标签，不一定删除内容。生成控制改变“能否产出违规内容”，与对任意现成图片作Safe/Unsafe判断不同。

## B. 运行时Guard、输入清洗与Agent行为审核（8篇）

| 标题与原文入口 | 来源 | 主题及系统边界 |
|---|---|---|
| ★ [SelfDefend: LLMs Can Defend Themselves against Jailbreaking in a Practical Manner](https://www.usenix.org/conference/usenixsecurity25/presentation/wang-xunguang) | USENIX Security 2025 | shadow LLM并发审核意图，用checkpoint控制输出，并蒸馏专用防护模型；适合读部署成本与并发设计。 |
| [JBShield: Defending Large Language Models from Jailbreak Attacks through Activated Concept Analysis and Manipulation](https://www.usenix.org/conference/usenixsecurity25/presentation/zhang-shenyi) | USENIX Security 2025 | 检测有害/越狱概念激活并操控隐藏状态，兼顾识别与抑制；需要内部访问。 |
| ★ [Quantifying Large Language Model Attacks Through the Lens of Model Cognition](https://www.usenix.org/conference/usenixsecurity26/presentation/liu-xiuming) | USENIX Security 2026；Sentinel | 融合多层隐藏状态的轻量风险探针，研究生成前的内部安全信号；不是再跑完整生成式裁判。 |
| [Attention is All You Need to Defend Against Indirect Prompt Injection Attacks in LLMs](https://www.ndss-symposium.org/ndss-paper/attention-is-all-you-need-to-defend-against-indirect-prompt-injection-attacks-in-llms/) | NDSS 2026；Rennervate | 用attention做token级注入检测与清洗，过滤不可信外部内容中的指令；安全token清洗不等于加速型视觉token剪枝。 |
| [DualSentinel: A Lightweight Framework for Detecting Targeted Attacks in Black-box LLM via Dual Entropy Lull Pattern](https://www.usenix.org/conference/usenixsecurity26/presentation/pang-xiaoyi) | USENIX Security 2026 | 监测生成token概率熵的异常低稳态，再进行任务翻转复核；面向被强制输出指定payload的攻击，不是所有不安全语义。 |
| ★ [AttriGuard: Defeating Indirect Prompt Injection in LLM Agents via Causal Attribution of Tool Invocations](https://www.usenix.org/conference/usenixsecurity26/presentation/he-yu) | USENIX Security 2026 | 通过并行反事实重放审核工具调用是否受用户意图支持，而非由不可信观察控制；审核对象从内容变成动作。 |
| [ACE: A Security Architecture for LLM-Integrated App Systems](https://www.ndss-symposium.org/ndss-paper/ace-a-security-architecture-for-llm-integrated-app-systems/) | NDSS 2026 | 拆分可信抽象计划和具体应用计划，用静态信息流检查及能力屏障约束执行；偏确定性系统控制。 |
| [SAGA: A Security Architecture for Governing AI Agentic Systems](https://www.ndss-symposium.org/ndss-paper/saga-a-security-architecture-for-governing-ai-agentic-systems/) | NDSS 2026 | Provider管理Agent生命周期及用户策略，以密码学访问令牌控制Agent间交互；不是内容语义分类器。 |

## C. 审核基准与真实平台测量（5篇，非全为新系统）

| 标题与原文入口 | 来源 | 主题及研究类型 |
|---|---|---|
| [UnsafeBench: Benchmarking Image Safety Classifiers on Real-World and AI-Generated Images](https://arxiv.org/abs/2405.03486) | ACM CCS 2025；作者v3会议声明，正式DOI为10.1145/3719027.3765088 | 测真实/AI生成图像的审核差异，并提出PerspectiveVision；兼有基准与审核模型。复用既有2024预印本稳定ID，不新建同论文来源。 |
| [HateBench: Benchmarking Hate Speech Detectors on LLM-Generated Content and Hate Campaigns](https://www.usenix.org/conference/usenixsecurity25/presentation/shen) | USENIX Security 2025 | 测审核器对LLM生成仇恨内容的泛化，并含规避/活动研究；仅作测量补充，不归为新防护系统。 |
| ["I Cannot Write This Because It Violates Our Content Policy": Understanding Content Moderation Policies and User Experiences in Generative AI Products](https://www.usenix.org/conference/usenixsecurity25/presentation/gao-lan) | USENIX Security 2025 | 研究产品政策、执行、误拒与用户申诉体验；社会技术/用户研究，不是新检测算法。 |
| [Benchmarking and Understanding Safety Risks in AI Character Platforms](https://www.ndss-symposium.org/ndss-paper/benchmarking-and-understanding-safety-risks-in-ai-character-platforms/) | NDSS 2026 | 测角色扮演平台及角色属性对安全的影响，另有不安全角色预测器；主线是平台风险测量。 |
| [There is No War in Ba Sing Se: A Global Analysis of Content Moderation in Large Language Models](https://www.ndss-symposium.org/ndss-paper/there-is-no-war-in-ba-sing-se-a-global-analysis-of-content-moderation-in-large-language-models/) | NDSS 2026 | 比较地区、语言和部署方式引起的审核行为差异；公平性/信息可达性测量，不是新Guard系统。 |

## 检索覆盖与未完成项

- 复用既有2023—2026项目、唯一来源和论文笔记，增补2024—2026阅读入口；本轮不替换历史20篇核心集合计数，也不将23篇与其简单相加。
- 官方来源：S&P2024/2025/2026接收页；CCS2024/2026接收页；NDSS2026接收页与NDSS2025论文页；USENIX2024/2025/2026论文页及技术日程；作者arXiv/正式项目页补摘要和开放版本。
- 查询族：content moderation、soft moderation、toxic content、guard、unsafe、safety、policy、propaganda、agent；逐题核验，非仅标题关键词命中即收录。
- CCS2025官方接收页访问失败；SafeGuider用作者正式项目页/BibTeX核验，UnsafeBench用作者v3会议声明核验，出版商DOI抓取403。CCS2026按已公开接收页核查，未将未核定接收状态的arXiv候选纳入；这不意味着该会无相关研究。
- USENIX整页日程有超时，改用独立论文页；Telegram最终PDF因31.8MB大小限制不可抓取，本条只依据官方摘要，未提取或核定模型细节。
- 排除主会范围外的ICCV、AAAI、ACL及普通arXiv论文；排除攻击主导、密码学举报、普通安全人因且无AI/自动审核核心者。LLMGuardrail等纯属性steering工作未选入这份以审核/部署为主的精选清单，非否认其主会归属。
- 本轮不比较准确率/时延，不从摘要构造正式gap或motivation，不创建实验结果；后续是否精读由用户选择。

相关入口：[[LLM-Wiki/research/ai-safety-systems-security-venues/overview.md|项目概览]]、[[LLM-Wiki/research/ai-safety-systems-security-venues/reading-log.md|检索日志]]。
