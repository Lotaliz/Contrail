---
id: visual-token-merging-landscape
type: synthesis
title: "视觉 Token 合并方法、时延与分类精度比较"
tags: [research, visual-token-pruning, token-merging, vision-language-model, efficient-inference]
project_id: visual-token-pruning
sources: [paper-bolya-2023-tome, paper-chang-2023-stvit, paper-chen-2023-diffrate, paper-wei-2023-tps, paper-kim-2024-tofu, paper-tran-2024-pitome, paper-lee-2024-dtem, paper-shang-2024-prumerge, paper-yang-2025-visionzip, paper-yang-2025-libra-merging, paper-islam-2025-adaptmerge]
status: active
created: 2026-09-14
updated: 2026-09-14
---

# 范围与结论

本页比较图像/视频 ViT 与 VLM 中以聚合方式缩短 token 序列的方法，截止 2026-09-14。分类精度主要指 ImageNet Top-1；VLM 方法通常只报告 VQA/推理指标，不能与 ImageNet 分类方法直接排序。论文间硬件、batch、分辨率和训练口径不同，因此只在同论文同主干的表格内判断优劣。

没有跨设置的统一冠军。免训练且重视真实吞吐时，ToMe 是最稳妥的基线；相同计算量下保分类精度，PiToMe 和训练后的 DTEM 通常优于原始 ToMe；允许联合搜索剪枝和合并比例时，DiffRate 给出很强的速度—精度点；允许重训视觉架构时，STViT 报告的吞吐提升和精度保持最突出，但不属于即插即用方法。

# 主要机制家族

| 家族 | 代表方法 | 如何保留被压缩信息 | 训练与适用边界 |
|---|---|---|---|
| 固定池化/空间合并 | average pooling、patch merging | 邻域平均或线性投影 | 最快、规则 shape；不看内容，细节易低通化 |
| 聚类/语义凝聚 | Token Pooling、STViT | 多 token 聚成 cluster center/semantic token | 聚类可能昂贵；STViT 需训练但适配全局与窗口 ViT |
| 快速成对匹配 | ToMe | 二分软匹配相似 token，按 token mass 加权平均 | 免训练、匹配开销低，是默认通用基线 |
| 保护独特信息的匹配 | PiToMe | energy score 优先合并大相似簇，保留孤立 token | 免训练精度更强；额外评分可能削弱纯时延优势 |
| 学习专用合并空间 | DTEM | decoupled embedding 专门决定分组，原 token 负责推理 | 需模块训练或端到端训练；精度优于 ToMe，吞吐略有开销 |
| 剪枝后信息回灌 | TPS、PruMerge | 先选中心，再把被删 token 按近邻/相似度写入中心 | 高压缩下比纯删稳；属于 pruning+merging 混合 |
| 按局部线性性质混合 | ToFu | 适合插值的层合并，敏感层剪枝；MLERP 保特征范数 | 可免训练或训练；复杂度高于纯 ToMe |
| 学习层级预算 | DiffRate | 同时决定每层 pruning 与 merging 比例 | 约 3 epoch 搜索；固定预算便于 batch，属于混合方案 |
| VLM 重要性—冗余联合 | VisionZip、Libra-Merging、AdaptMerge | dominant token 保留，context token 聚合，可加入文本相关性 | 多数视觉塔后方法只省 LLM prefill；塔内合并才省视觉编码 |

# 有可比证据的速度—精度点

| 方法与设置 | 作者报告的分类质量 | 作者报告的效率 | 判断 |
|---|---:|---:|---|
| ToMe，SWAG ViT-L/16@512、ViT-H/14@518，off-the-shelf | Top-1 仅降约 0.2–0.3 pp | 吞吐约 $2\times$ | 最强的免训练真实吞吐证据之一；优势主要在大模型/高分辨率 |
| ToMe，训练 DeiT-S/16 | 79.80→79.36，降 0.44 pp | 930→1550 im/s，约 $1.67\times$，V100 | 简单、快速；小模型在更激进速度点会明显掉点 |
| PiToMe，ViT-MAE-H 等 off-the-shelf 汇总 | 40%–60% FLOPs 区间平均降约 0.5 pp；比较方法约降 2.6 pp | 节省 40%–60% FLOPs | 同预算保精度强，但没有统一硬件下的决定性 latency 冠军证据 |
| DTEM，DeiT-S，约 37.2% FLOPs reduction | 79.85；同表 ToMe 79.68 | 1991 im/s；同表 ToMe 1917，3090/batch 128/fp32 | 该点同时略胜 ToMe 精度与吞吐；更激进点吞吐可略低于 ToMe |
| DiffRate，MAE ViT-H | 仅降 0.16 pp | 40% FLOPs reduction，约 $1.5\times$ throughput | 很强的整体折中，但来自 pruning+merging 与预算搜索 |
| STViT，DeiT-T/S/B，16 semantic tokens | 作者报告 Top-1 不降 | 约 58% FLOPs reduction，吞吐提升 101%–110%，V100/batch 128 | 报告点突出；需训练并改变 tokenization，非插件口径 |
| TPS，DeiT-T/S 压到约 35% 原计算预算 | 比纯剪枝基线高 1–6 pp | DeiT-S throughput 可超过 DeiT-T | 高压缩鲁棒性强；摘要不足以支持绝对时延排名 |

# 如何选择

- **不训练、快速验证：** ToMe，并在目标硬件测 batch=1 时延。
- **不训练但更重视精度：** PiToMe；若 energy 计算抵消收益则退回 ToMe。
- **可训练小模块：** DTEM；它在相近吞吐下通常给出更好 Top-1，并能跨 reduction rate 使用。
- **可离线搜索预算：** DiffRate；适合固定 shape 和批处理，但应标为混合基线。
- **允许重训视觉编码器：** STViT；适合追求最大视觉塔吞吐，需另测密集任务、小目标与 OCR。
- **VLM/多模态安全：** 比较 ToMe、PruMerge+/VisionZip 类视觉塔后合并，以及 AdaptMerge/QuietPrune 类视觉塔内压缩；前者不省视觉塔，后者才可能同时降低视觉编码与 LLM prefill。

# 证据边界

- 合并保留的是摘要而非无损原 token；相反语义、OCR 字符和小目标可能在平均后抵消。
- 排序、全对全相似度、聚类和动态 shape 可能吃掉 FLOPs 收益，必须报告 merger-inclusive latency。
- batch=128 throughput 不能替代 batch=1 P50/P95 latency；不同 GPU 表格不能横向宣布冠军。
- 图像分类最宽容，Top-1 不掉不代表检测、分割、OCR 或安全证据不掉。

关联：[[LLM-Wiki/research/visual-token-pruning/comparison.md]]；[[LLM-Wiki/concepts/technology/vision-transformer-token-pruning-basics.md]]。
