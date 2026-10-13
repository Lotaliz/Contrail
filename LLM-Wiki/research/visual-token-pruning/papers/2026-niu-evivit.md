---
id: note-2026-niu-evivit
type: paper-note
title: "EviViT: Evidence-Adaptive Vision Transformers for Fine-Grained Perception"
authors: [Yaoxin Niu, Zhangquan Chen, Yang Zhang, Xiang An, Zhumei Wang, Chih-Ting Liao, Hongkun Cao, Ruqi Huang]
year: 2026
venue: arXiv
source_id: paper-arxiv-2609-37123
project: visual-token-pruning
reading_level: deep-read
verification: source-checked
relevance: high
priority: high
tags: [paper-note, research, visual-token-pruning, vision-language-model, efficient-inference]
status: active
created: 2026-10-10
updated: 2026-10-13
---

# EviViT：人类搜索监督的局部重读与稀疏融合

## 原件与阅读范围

用户显式选择本文。原文为 [arXiv 2609.37123v1](https://arxiv.org/abs/2609.37123v1)，CC BY 4.0；完整 HTML 原件见 [HTML 原文](https://arxiv.org/html/2609.37123v1)。精读 §3–5、表 1–5、附录 A 的模块与四阶段训练、表 6–10，以及 C 的位置/面积/监督控制。未运行代码或访问训练数据、权重，数字均为作者报告。

PDF 原件另见 [PDF 原文](https://arxiv.org/pdf/2609.37123v1)（23 页）；完整文件已解析，关键图表与 HTML 数字交叉核查，SHA256 登记在同一 source_id 的 local_artifacts。

## 从空间监督到实际执行

§3.1–3.2：研究组成员为 VisualProbe 的 1,144 个训练问题记录 cursor、dwell、zoom、reset、final box。证据图以全部访问、最后 reset 后分支、末次 zoom、最终框的 0.25/0.35/0.25/0.15 混合，peak-normalize 后形成空间目标；放弃分支作弱负证据。不是仅用最终框或自然语言 rationale，也不是免额外标注方案。

PTEA 在视觉塔中间读取全局 token 和问题 embedding，使用固定随机投影、可学习 192 维投影、一层文本 Transformer，按 patch 对齐问题 token；将视觉/文字交互、最大相似度、entropy 和坐标输入局部卷积，输出 evidence density。map loss 为 soft CE、0.2 cosine 和 0.1 abandoned-map 惩罚；另训练 context 分支。

planner 通过 residual suppression 保留一或两个非冗余 decisive 区域，再从掩除后的 context density 选一个补充区域，默认是**两个或三个局部视图**。129 参数的 ContextNeed 从两图统计量预测 10–25% 局部预算给 context，剩余按证据质量分配；H-Safe 用有界 MLP 调整框中心/大小，监督包括 Smooth-L1、GIoU、覆盖、面积和identity。“Safe”在此是几何变换约束，不是内容安全保证。

区域从原图重新读取，沿同一冻结 ViT 运行至插入层。Sparse Bridge 令 local token 与源坐标匹配的 global $3\times3$ 邻域交互，反向消息仅写入有 local children 的 global token；输出投影零初始化、residual RMS 有界，初始路径为 identity。两路继续经过剩余 ViT、merger 和 LLM。它使用中间层重读与融合，不是视觉塔前一次性剪枝。

## 训练与可迁移边界

附录 A.1–A.2：Qwen3-VL-4B/8B 分别在视觉 block 16/18 插入，另为 Qwen3.5-4B/9B 分别训练附件；仅共享视觉块、宽度、merger 和坐标接口的后训练 descendant 可直接复用。不是一套权重可移植任意 backbone。

先以 trace-only 五折选 PTEA 层位与三 epoch，再冻结 evidence/alignment 训练 context，接着拟合 ContextNeed/H-Safe，最后固定 routing 以答案 CE+0.01 identity penalty 训练 Bridge；视觉塔、merger、LLM 始终冻结。附录 A 的 1.046 A100 GPU-hours 只覆盖审计的 4B feature extraction、PTEA 和选定 Bridge pass，排除 H-Safe 校准及历史架构搜索，不能作为完整开发成本。

## 主要结果与相反证据

§4 表 1：九个 foundation/descendant 的细粒度 benchmark 平均均提高，Qwen3-VL-4B/8B 七项平均为 60.26→65.86、61.77→67.86。评测含 VisualProbe、V*、HR-4K/8K、ZoomBench；本地配对固定 prompt/checkpoint/decoding，答案由无图、无方法名的冻结 Qwen3-VL-8B judge 语义评分。闭源或他文公布的混合来源平均仅作描述，不能当完全同协议排序。

表 2：8B 在 4K ceiling 时，global 为 62.83、3.83K realized token，EviViT 为 68.87、3.62K；胜过 global 20K 档的 68.27。ceiling 与 realized count 不同，附件的 native soft capacity 也不是固定总预算；matched sweep 才逐样本受 paired global ceiling 约束（附录 A.2）。

**更少 token 并不等于更快：** 表 3 用每设置 64 个 isolated requests；8B 4K median E2E 为 1.087→1.105 s，16K 为 1.088→1.091 s，1K 为 0.696→0.892 s。4B 三档均更慢。它主要体现精度/证据利用改善，不能概括为加速方法；公开表未充分说明完整服务并发与计时硬件协议。表 4 也有 Qwen3-VL-4B Visual-CoT -2.01 和 Qwen3.5-9B MMBench -0.37 的退化。

## 证据与位置的控制实验

- 附录 A.3 表 7：仅打乱 PTEA 看到的问题、保持回答模型的正确问题和其他模块固定，VisualProbe 下降 4.47/3.31 个百分点；支持 query-conditioned selection，其他 benchmark 效果较不均匀。
- 表 8、附录 C.2：用 native multi-image 接口固定 706 个样本的 crop 数量、顺序、尺寸、角色、token grid，只随机平移中心或借另一图中心；pooled accuracy 66.57→57.08/56.94。该位置控制隔离于 learned Bridge，证据强于仅展示 attention 热图。
- 表 14、附录 C.3：实际 deployed crop 的 union area 12.39%，目标覆盖均值 73.69%，所有 target 达 90% 的样本为 64.52%；同布局随机平移的面积仍 12.39%，覆盖仅 18.47%。top-eight proposals 的 70.43% 全目标高覆盖不等于实际部署的两/三 crop 覆盖。
- 表 5、附录 C.4：matched final-box 与 full-trace 的 VP-Hard 为 52.83→56.60，但同时改变 evidence/context 监督配方，不能把全部收益归给某一种 dwell cue。附录表 6 中 8B 的 Boxes-only 八任务平均 63.94 高于 full 63.40，也不是各模块均单调增益。

## 项目判断与待验证项

与 [[LLM-Wiki/research/visual-token-pruning/papers/2026-guan-video-evidence-indexing.md|VEI]] 相比，它在视觉编码内部一次完成重读/融合，不需要反复 LLM crop 调用；与 [[LLM-Wiki/research/visual-token-pruning/papers/2026-gao-quietprune.md|QuietPrune]] 相比，它依赖人类搜索监督并付出局部重新编码成本。关联 [[LLM-Wiki/concepts/methods/multimodal-token-pruning.md]]。

**本项目判断：** 对 C5 最有价值的是“只打乱 selector 政策”和“固定布局/面积/预算的像素位置控制”，以及焦点证据与补充 context 的区分。默认多框、约千 token 以上和通用 VQA 结果不能直接证明单局部框或安全 recall，也不能外推到旧 C5 的 5% 工作点。2026-10-10 的[[LLM-Wiki/research/visual-token-pruning/c5-per-sample-visual-allocation.md|当前方案]]已不锚定 5%，应按实际全局/单局部 token 配置检验迁移。

作者公开说明代码含聚合结果和脚本，但不含模型权重、human-search traces、benchmark images 或 QA 训练数据；本轮未核验代码发布状态。TODO：替代人工 trace 的路线收益/像素监督、单框覆盖失败、small text 清晰度、policy flip 和真实部署开销。本轮不创建新 concept 或把单篇效果提升写入正式 motivation。
