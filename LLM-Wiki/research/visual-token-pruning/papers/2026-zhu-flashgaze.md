---
id: note-2026-zhu-flashgaze
type: paper-note
title: "FlashGaze: Training-Free Multi-Scale Patch Pruning for Efficient Video Understanding"
authors: [Ziye Zhu, Yanghao Zhou, Lixing Tan, Jialiang Kang, Shuxuan Li, Xiao Yang]
year: 2026
venue: arXiv
source_id: paper-arxiv-2610-04225
project: visual-token-pruning
reading_level: deep-read
verification: source-checked
relevance: high
priority: high
tags: [paper-note, research, visual-token-pruning, vision-language-model, efficient-inference]
status: active
created: 2026-10-10
updated: 2026-10-10
---

# FlashGaze：像素代价驱动的 ViT 前时空剪枝

## 原件与阅读范围

[arXiv 2610.04225v1](https://arxiv.org/abs/2610.04225v1)，CC BY 4.0；完整原件见 [[LLM-Wiki/raw/papers/2610.04225v1.html]]。精读 §1–5、算法1–2、表1–5、附录A–E。未运行代码、视频解码或模型；证据核验到论文原文，未标reproduced。

## 无训练的像素代价与预算求解

§3.2：第一帧完整保留、**豁免patch预算**，初始化逐空间位置的历史像素memory。随后每位置存最近一次保留patch；memory用于决定下一帧，不是独立的LLM可查询cache。每帧可Drop、Merge或Keep，在实际预算 $N_t\leq\mathcal B$ 下最小化像素误差之和加 $\lambda N_t$，所以不必用满上限。

§3.3：Drop cost由当前patch与memory像素差得到，在小block局部搜索位移以降低轻微相机运动影响；Merge cost把当前帧2×/4×缩小再放回，按覆盖的fine patch数缩放重建误差；Keep cost为0。三层quadtree中一个中/粗节点各有四个child，SCM枚举各child实际patch数分配，再与整块merge成一个patch的cost比较。最终对frame总count加惩罚并backtrack，得到符合预算的互不重叠动作。

选定patch在ViT前按1×/2×/4×尺度输入，位置embedding使用中心坐标。附录B：Qwen3-VL已有多尺度接口；NVILA对帧和位置embedding插值支持多尺度，无下游微调。它不使用问题/政策，也不以模型真实答案收益优化像素代价。

## 评测、主结果与可比范围

§4.1–4.2：Qwen3-VL-8B、NVILA-8B-Video；VideoMME/NExT-QA/MLVU/VideoMMMU/LongVideoBench/HLVid。主表分别50%/10%最终保留率；LongVideoBench与VideoMMMU最多768帧，HLVid为2K输入。同backbone比较ToMe、FastV、VisionZip、FlashVID、AutoGaze；NVILA的FastV因剪枝前context overflow省略。

表1，Qwen LongVideoBench FlashGaze66.7、20.7s，ToMe66.4、24.3s；VideoMMMU为67.0、20.4s；HLVid73.2、20.5s。表3在Qwen20%保留率时LongVideoBench66.7→65.5（约98.2%相对保留），峰值allocated显存106.4→58.2GiB，TTFT71.7→5.4s（约13.3×）。相同保留率HLVid71.6→68.2，性能退化不能被“保留98%”覆盖。

表2把输入从Qwen768帧/1792上限扩展到1536帧/3840后多项分数提升；这是允许更大输入的能力证据，不是与原模型同输入规模的纯算法精度增益。

## 真实计时与消融

附录C：single H200、batch1、BF16、PyTorch native SDPA，未使用FlashAttention；一次warmup、三次计时均值。TTFT包含pre-ViT视频处理/剪枝、ViT和LLM prefill，不包括完成全部输出的decode或并发排队。

附录D表5，LongVideoBench20%：原始pre-ViT/ViT/prefill为0.7/5.9/65.1s，FlashGaze为0.5/1.1/3.8s。AutoGaze视觉编码同样1.1s，但前处理7.3s，说明选择器成本可吃掉收益。原文另报256帧、1792输入时15×TTFT（图4），不能与表3的13×混为同工作点。大prefill收益发生在长视频、SDPA和大输入，不能外推到约400视觉token的短图Guard。

表4：30%最终率、768帧，pixel差较patch embedding/SigLIP/LPIPS质量更好且免额外feature模型。multi-scale greedy的HLVid70.6，DP71.7，cost3.3K→1.96K；同时改变候选尺度的random/single-scale对照不能单独证明DP最优性。图5/附录E的attention加权feature相似及动态区attention增加只是机制相关证据，尚未隔离其因果作用。

## 局限与项目判断

**阅读判断：** 像素不变不意味着政策无关；静态小文字、微小动作、镜头变换和长期历史访问都可能超出局部pixel proxy。第一帧全保留使很短视频的预算下界较高。正文没有提供这些场景的完整失败率、服务batch/并发或code运行核验；公开稿只承诺后续代码，不据此假定已可复现。

关联 [[LLM-Wiki/concepts/technology/vision-transformer-token-pruning-basics.md]]、[[LLM-Wiki/research/visual-token-pruning/papers/2026-guan-video-evidence-indexing.md|VEI]] 与 [[LLM-Wiki/research/visual-token-pruning/papers/2026-gao-quietprune.md|QuietPrune]]。本文为无需训练的编码前低成本对照；Cx可借鉴可选粒度、预算上限和选择器完整计时，不能直接使用时域Drop判定单图政策证据。TODO：单图pixel-scale基线、policy置换与静态细节压力测试、真实packed kernel及短输入E2E。本轮不新增concept、不修改主方案。
