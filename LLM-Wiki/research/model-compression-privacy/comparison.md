---
id: model-compression-privacy-compleak-frontier-comparison
type: synthesis
title: CompLeak 的 MIA 前沿定位
tags: [research, membership-inference, model-compression]
project_id: model-compression-privacy
sources: [paper-li-2026-compleak, paper-du-2026-cmia-pmia, paper-lu-2026-icp-mia, paper-chen-2026-window-mia, paper-tong-2026-tokenizer-mia, paper-nguyen-2026-menta, paper-wang-2026-vidleaks, paper-zhang-2025-soft, paper-shang-2025-wemem, paper-li-2025-dhattack, paper-tan-2026-neural-activation-mia]
status: active
created: 2026-09-15
updated: 2026-09-15
---

# CompLeak 的 MIA 前沿定位

## 结论

CompLeak 是**模型压缩与多版本发布隐私风险这一子问题的前沿工作**，但不能代表 2026 年 MIA 攻击算法或防御技术的总体最前沿。

## 统一比较

| 工作 | 主要对象 | 关键前沿维度 | 攻击假设/信号 | 相对 CompLeak 的意义 |
|---|---|---|---|---|
| CompLeak | 压缩分类模型及多个版本 | 压缩生命周期、多版本差分 | 完整 posterior、真实标签、同分布影子数据、已知配置 | 新攻击面强；通用攻击现实性较弱 |
| CMIA/PMIA | 一般监督模型 | membership dependency、adaptive/non-adaptive | 条件影子训练或实例代理 | 更接近通用 MIA 算法前沿 |
| WBC | 微调 LLM | 局部多尺度记忆、低 FPR | 目标—参考模型窗口 loss | 更直接推进 LLM MIA 检测信号 |
| ICP-MIA | 微调 LLM | training-free 黑盒 probing | in-context optimization gap | 减少 CompLeak 的影子训练与完整 posterior 依赖 |
| Neural-Activation MIA | 开放权重 LLM | 动态 benchmark、跨层内部信号 | 神经元激活 | 代表白盒预训练数据检测方向 |
| DHAttack | label-only API | 少查询、隐蔽性 | 5–30 次标签查询 | 威胁模型比 CompLeak 更接近受限 API |
| MEntA | RAG | 五查询、无 surrogate、自然语言攻击 | 回答与候选文档的 entailment | 代表系统级、低成本 MIA 前沿 |
| Tokenizer MIA | LLM tokenizer | 新组件攻击面、预训练数据代理 | tokenizer 行为 | 与 CompLeak 同属生命周期/组件特定创新 |
| VidLeaks | 文生视频 | 稀疏空间与时间记忆 | 关键帧重构、生成稳定性 | 代表生成式多模态 MIA 前沿 |
| SOFT | LLM 微调 | 训练期防御 | 高影响样本选择与混淆 | CompLeak 没有可比的新防御 |
| WeMem | 迭代剪枝 | 压缩感知防御 | 抑制数据复用与固有可记忆性 | 在压缩隐私防御上比 CompLeak 更直接 |

## 分项评级

| 维度 | 对 CompLeak 的评价 |
|---|---|
| 压缩隐私问题定义 | 前沿；首次系统利用原模型/多个压缩版本的相关泄露 |
| 通用 MIA 攻击算法 | 不是总体 SOTA；NR 直接复用已有攻击，SR/MR 是特定多版本场景的特征聚合 |
| 现实黑盒能力 | 中等偏弱；依赖完整 posterior、标签、同分布影子数据和配置知识 |
| LLM/生成模型覆盖 | 有限；BERT/GPT-2 只做 SST-5 分类，作者明确排除难以 MIA 的大规模生成任务 |
| 防御贡献 | 非前沿；DP-SGD 是验证，辅助数据/PTQ/hard label 主要是讨论，没有新防御算法 |
| 安全系统贡献 | 较强；把“发布多少相关压缩版本”识别为部署策略与隐私边界问题 |

## 最准确的定位

CompLeak 代表的是 2025—2026 MIA 的一个重要趋势：**从通用置信度攻击转向 AI 生命周期中特定组件和多视图发布面的隐私审计**。它与 tokenizer、RAG、文生视频 MIA 属于同一类“新攻击面”前沿；若要代表攻击方法学最前沿，应同时参考 CMIA/PMIA、WBC、ICP-MIA、DHAttack 和 MEntA。若要代表防御前沿，则应参考 SOFT、WeMem 和具有明确隐私预算的差分隐私方法。
