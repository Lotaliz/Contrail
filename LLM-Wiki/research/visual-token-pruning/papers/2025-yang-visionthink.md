---
id: note-2025-yang-visionthink
type: paper-note
title: "VisionThink: Smart and Efficient Vision Language Model via Reinforcement Learning"
authors: [Senqiao Yang, Junyi Li, Xin Lai, Jinming Wu, Wei Li, Zejun Ma, Bei Yu, Hengshuang Zhao, Jiaya Jia]
year: 2025
venue: NeurIPS 2025
source_id: paper-yang-2025-visionthink
reading_level: skimmed
verification: source-checked
tags: [paper-note, research, visual-token-pruning, adaptive-budget, dynamic-inference]
status: active
created: 2026-10-10
updated: 2026-10-20
---

# VisionThink

2026-10-16：按用户选择登记为待补实验基线；[NeurIPS 2025 正式题录](https://proceedings.neurips.cc/paper_files/paper/2025/hash/88be023075a5a3ff3dc3b5d26623fa22-Abstract-Conference.html)已核对会议和完整作者。下文仍为此前 v1 快读，不表示本轮重读全文、适配或复现；待补项目见 [[LLM-Wiki/research/visual-token-pruning/autoregressive-vlm-pruning-sota-baselines.md|基线清单]]。

来源：[arXiv 2507.13348v1](https://arxiv.org/html/2507.13348v1)。复用已有 source_id，快读摘要、引言、总览图、§3、Table 2、Figure 4、结论/§6.2；未下载新 PDF、核验代码或复现。HTML 许可为 CC BY-SA 4.0，修正来源登记旧值。

**作者方法：** Qwen2.5-VL-7B 先看缩小图，可通过特殊输出请求原高清图；以多轮 GRPO、正确性/格式与效率奖励训练。研究限制为 2× 空间分辨率升级、最多两轮，使用 vLLM；不是一次图文预览后一次最终 Guard 的结构。

**数据监督先例：** §3.5 分别对高低分辨率做 8 次 rollout，以两者均正确区分低清可解，以高低正确次数差至少 6 筛出高清必要样本。这是作者训练数据筛选，不意味着 C5 必须采用生成采样或同一阈值。

**结果边界：** Table 2 为多任务结果，ChartQA 使用作者特殊 judge 评测。Figure 4 中 DocVQA 加速明显，但 ChartQA 因高频升级出现时延劣势；Token 下降不保证多次调用更快。

**项目判断：** 可作逐样本升级基线，或借鉴“实际高清救回”标签构造。低预算分类熵不能保证发现证据遗漏，级联需独立计时。主线优先现有 C5 预览上的监督配置头；若复现 RL，须升级 deep-read。

关联：[[LLM-Wiki/changes/2026-10-20-resolution-plan-and-superseded-ideas-cleanup.md|c5-per-sample-visual-allocation（历史方案，已删除）]]。
