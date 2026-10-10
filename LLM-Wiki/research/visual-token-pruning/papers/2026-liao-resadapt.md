---
id: note-2026-liao-resadapt
type: paper-note
title: "ResAdapt: Adaptive Resolution for Efficient Multimodal Reasoning"
authors: [Huanxuan Liao, Zhongtao Jiang, Yupu Hao, Yuqiao Tan, Shizhu He, Jun Zhao, Kun Xu, Kang Liu]
year: 2026
venue: arXiv
source_id: paper-liao-2026-resadapt
reading_level: skimmed
verification: source-checked
tags: [paper-note, research, visual-token-pruning, adaptive-budget, dynamic-inference]
status: active
created: 2026-10-10
updated: 2026-10-10
---

# ResAdapt

来源：[arXiv 2603.28610v1](https://arxiv.org/html/2603.28610v1)。快读摘要、引言、Figure 2、§2–3、Table 1、§4.3–4.4、结论、附录 D.4/Table 7；未下载 PDF、核验代码或复现。主要研究视频 QA/时间 grounding。

**作者方法：** 编码前 allocator 读取冻结轻量视觉特征与 query，经浅层注意力交互输出 Beta 分布，映射为每帧 resize 尺度。原生 MLLM 接口保留，一次最终主干调用；训练可联合更新主干，不等于永远冻结。CAPO 以正确性区分成本奖励，另加时间相似性正则（§3、Figure 2）。

**结果与限制：** 主视频实验支持低预算取舍，但不能外推所有图像。Table 7 中 Qwen2.5-VL-7B 的 TextVQA 从全预算 82.9 降到 ResAdapt 30% Token 时的 69.6；ChartQA 85.9 使用 105% Token。§4.3 的视频计时依赖特定服务部署，不能当作 C5 单图时延。结论明确域外迁移不均匀，初次分配遗漏证据后同次调用无法救回。

**项目判断：** 与 C5 的低成本图文预览＋输入网格选择结构接近；建议先采用离散监督 allocator，视频时间正则不适用静态单图，连续 RL 留作后续。迁移仅为待验证假设。若准备复现，须升级 deep-read 并固定代码/成本口径。

关联：[[LLM-Wiki/research/visual-token-pruning/c5-per-sample-visual-allocation.md]]。
