---
id: note-2026-shi-small-objects-safe-zoom
type: paper-note
title: "Why VLMs Miss Small Objects, and When Zooming In Is Safe"
authors: [Junzhe Shi, Yuan Gan, Shida Jiang]
year: 2026
venue: arXiv
source_id: paper-arxiv-2610-09313
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

# 小目标与安全放大：信息、token几何和单次枚举容量

## 原件与阅读范围

[arXiv 2610.09313v1](https://arxiv.org/abs/2610.09313v1)，arXiv perpetual non-exclusive license；完整原件见 [HTML 原文](https://arxiv.org/html/2610.09313v1)。精读 §1、§3–6、Limitations，主要表1–4，附录A的接口界/crop dominance/覆盖证明，B的预注册偏离、C的几何、H/I/K的错误与成本。本轮未逐行验证全部信息论和自适应搜索证明，也未调用商业模型，结论依作者测量与明确假设；不标reproduced。

另保存 [完整 PDF](https://arxiv.org/pdf/2610.09313v1)（44页），全页解析并视觉核查第20页表3和图6；预算、召回和native/插值crop控制与HTML一致，PDF哈希登记于同一来源。

## 两类瓶颈与假设

§1、§3：$S$为目标每侧跨越的视觉token数，$L$为单次调用需要覆盖/枚举的内容；目标框的尺度$m$是宽高几何均值，$S=ms/t$，其中$s$为实际缩放、$t$为token像素步长。整图预算$N$满足 $S\leq m\sqrt{N/(WH)}$，预算翻倍仅使上限乘$\sqrt2$。固定grid则 $S=mg/\max(W,H)$，单纯整图插值放大不增加其grid。

Proposition1与附录A：只依发送后图像生成的overlay/插值不会增加Shannon信息，但有限计算模型的可用信息仍可能改善；从native原图重新裁取可带入低清图已丢的细节。**token-limited和information-limited不是同一情况**，也不是仅由物体大小唯一决定。

Assumption1：R（同区域更高有效分辨率不减检测）、M（同尺度减少上下文不减检测）、I（增加原始信息不减检测）。它们是模型+调用协议在指定分布上的行为假设，不是VLM自动满足的规律。Theorem1要求每crop的S不低于整图、完整目标及matching margin位于至少一个view内部；满足覆盖与R/M才保证**期望hit recall**不降。“Safe”是检测意义，不是内容安全、F1、每个样本或Guard误报保证。

Theorem3将coverage缺口、R/M缺陷、merge漏失分开，给出 $\mathcal R_d\geq\mathcal R_w-\psi-\bar\epsilon-\zeta$；不是只要加crop就有保证。Proposition6还需新增FP不超过 $(n+FP_w)/TP_w$ 倍新增TP，F1才不降。信息论content界依独立均匀目标位置等条件；§3.5硬recognition threshold与graded curve的自适应搜索界也有独立假设，实测detection curve只给全响应TV上界函数的下界，不能将实测frontier称认证界。

## 数据与控制协议

§4表1：REDP-X40为40张工程图、1028实例，6张tuning、34张test/660实例；另有REDP-10、FloorPlanCAD的FPC-300（339test）/嵌套FPC-sheets、150张FSC-147和156个controlled图。商业模型版本为作者在2026年9–10月的快照；Qwen3-VL-235B-A22B等通过固定provider接口。参数不代表本地Qwen小模型。

预测中心和标注做最大一对一matching，容差$m/2$；配置用strict F1，假设测试用hit recall。重复按图平均，paired bootstrap4000次，有共享原图时cluster；注册首轮和agent控制做Holm校正，其余区间未统一多重校正。六份预注册及失败假设在附录B保留，不能把post hoc分组当预注册。

## 主要证据与反例

- §5.1表2：12张controlled图、8模型、5类配对，40个预测ordering无显著违例（24显著支持）；不等于证明所有图分布单调。其他实验post hoc的89对中61显著支持、4违例，均在OpenAI高像素/重采样路径。GPT-5.6 reasoning的高分辨率full-sheet F1为0.33，而default为0.89。
- §5.2：固定同一像素、仅改变Gemini3.8视觉预算，8px符号recall0.44→0.54→0.71；隔离了更多tokens与更多source pixels。recognition curve随模型改变，很多新模型可在小于一个token每侧时识别，故“目标必须至少一个token”不是普遍下界。
- §5.1/5.4：44px tile recipe在大符号图上可能降低S，19/21格点估计recall变差、12显著；Corollary1 rule用$S=\max(S^*,S_w)$与重叠避免该问题。表3八个模型/数据格无显著recall下降、四个提升，最多+0.28；这是有限实验支持，未证明零损失。
- §5.3：FPC-sheets对固定首块加外部context，GPT-5.6 F1下降0.22；保持S≥1的子组仍下降0.23，但S未严格固定到相同值。packed-tile实验GPT在相同S下k=8recall下降0.31；Claude同时被resize，不能只归因于content容量。
- §5.4图6：matched reasoning下overview crop→插值放大→native crop逐步控制。GPT-5.6主要从插值提高S得益（+0.11F1），native再加仅0.01；Claude主要从native pixels得益（+0.09）。模型不同，不能保证原像素读取或增加token对每个模型均同等有用。
- §5.5：坐标frame/scale/format会改变评测，Gemini/Qwen agent计数接近而crop回全图定位失败。部分frame修正规则是事后且无标签的方法选择，不应当作原注册成绩。

## 成本、局限与对 Cx 的作用

附录I表15：tile/propose-verify每图13–146次调用；附录K中GPT-5.6 agent约29.3K input/2.9K output，tile16.8K/0.5K；Claude agent11.3K/1.4K，tile20.6K/2.3K。此文追求枚举召回与可审计定位，不是单调用或更快服务方案，未给完整wall-clock优势。

Limitations：R/M分布迁移需重测；hard threshold和token量化观察者并不普遍成立；crop FP不单调；商业版本漂移与坐标偏离影响结果。REDP-10不公开，label audit由原标注者执行，只查遗漏，不提供独立语义一致性验证。

关联 [[LLM-Wiki/concepts/methods/multimodal-token-pruning.md]]、[[LLM-Wiki/research/visual-token-pruning/papers/2026-niu-evivit.md|EviViT]]、[[LLM-Wiki/research/visual-token-pruning/qwen3-vl-resolution-budget-notes.md|本地分辨率边界]] 与 [[LLM-Wiki/research/visual-token-pruning/cx-global-local-importance-plan.md|Cx]]。

**本项目判断：** 可借鉴同pixels变token、同token几何变context、native crop对插值crop的分离控制。当前小图/至多一个局部框/0–8–16局部token并不覆盖全图，也不满足工程图枚举理论的前提；无法直接拿该定理保证政策Guard召回。局部预算应按原生网格、目标尺度、框context和真实路线收益核验，保留全局补充信息。TODO：政策相关目标的有效像素与S、crop边界证据、低清已不可见目标的selector漏失。暂不创建新concept或转写motivation。
