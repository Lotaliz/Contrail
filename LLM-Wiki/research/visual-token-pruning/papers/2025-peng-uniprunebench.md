---
id: note-2025-peng-uniprunebench
type: paper-note
title: "Can Visual Input Be Compressed? A Visual Input Token Compression Benchmark for Large Multimodal Models"
authors: ["Tianfan Peng", "Yuntao Du", "Pengzhou Ji", "Shijie Dong", "Kailin Jiang", "Mingchuan Ma", "Yijun Tian", "Jinhe Bi", "Qian Li", "Wei Du", "Feng Xiao", "Lizhen Cui"]
year: 2025
venue: "arXiv preprint (v2)"
source_id: paper-peng-2025-uniprunebench
project: visual-token-pruning
reading_level: deep-read
verification: source-checked
relevance: high
priority: high
tags: [paper-note, visual-token-pruning, efficient-inference, benchmark]
status: active
related: [autoregressive-vlm-pruning-sota-baselines]
created: 2026-09-16
updated: 2026-09-17
---

# UniPruneBench

## 书目信息与收录

来源：[arXiv:2511.02650v2](https://arxiv.org/abs/2511.02650)。本轮精读方法分类、Tables 1–5、运行时间协议与结论；未运行代码。它是当前把多种视觉 token 压缩方法放到相同模型、预算、评测框架和硬件下比较的重要基准，因此作为论文自报结果的校准证据。

## 研究问题与协议

论文指出既有工作在模型、数据、prompt、token 保留率和系统指标上高度碎片化。UniPruneBench 覆盖 LLaVA-v1.5、InternVL3 和 Qwen2.5-VL 五个模型、十个数据集、十种压缩算法，并按 ViT-only、LLM-only 与 hybrid 分类。时延实验使用 A100-40GB、batch 1、三次运行，在 MME 上统一剪除 88.9% 视觉 token；分别记录 total、prefill 和方法本身的 GPU 时间。

## 主要数据

- InternVL3-8B Vanilla 九任务均值 70.02。保留 11.1% token 时，GPrune 为 63.31，DivPrune 为 64.04，FastV 为 62.26；DivPrune 是该预算下的精度最高者。
- 同一时延协议中，Vanilla total/prefill 为 761/320 s；GPrune 为 454/167 s（1.68×/1.92×），DivPrune 为 469/185 s（1.62×/1.73×），FastV 为 497/212 s（1.53×/1.51×）。剪枝子程序时间均低于 0.5 s，但 compact、kernel 与序列长度收益仍包含在实际测量中。
- LLaVA-v1.5-7B 保留 22.2% token 时，SparseVLM 九任务均值 53.5，略高于 Vanilla 53.2；保留 11.1% 时 DivPrune 47.0 为最高，而 FastV 仅 37.5。
- Qwen2.5-VL-7B 在相同保留率下整体退化更明显；这与 InternVL3/LLaVA 的排名差异共同证明方法效果依赖架构和预算。

## 主要结论与边界

作者证据支持四点：随机剪枝仍是强基线；没有跨场景普遍最优方法；OCR 对压缩最脆弱；剪枝率是主要退化因素。Table 5 还显示，把两个现成阶段机械串接并不优于最强单阶段方法。

这篇论文是预印本，且系统时延表只覆盖 InternVL3-8B、MME 和单一极限预算；它不能代替多输出长度、真实 serving 并发、视频和安全 Guard 的 profiling。论文平均分混合不同原始量纲，适合内部同表排名，不适合与其他论文的“平均保持率”直接做绝对比较。

## 对当前研究的启发

2026-09-17 计时口径复核：§4.1/4.3 明确所有本表运行 batch=1、单 A100-40GB、3 次重复。761→454 s 是完成整套 MME yes/no 自回归答案评测的累计时间，不是单请求时延；prefill 是 decode 前对混合视觉/文本序列前向并形成 KV，不应误读为 ViT-only。未核到固定输出 token 长度或固定 batch>1 曲线。来源：[arXiv v2 §4.3](https://arxiv.org/html/2511.02650v2)。

Appendix B 补充环境为 Python 3.12、PyTorch 2.5.1、Transformers 4.54.0、CUDA 12.4。依赖 attention 的方法通过单次 eager forward 取得 attention，存临时文件再由 prune routine 加载；其获取/复用开销是否全部纳入在线方法计时尚待代码审计，不能把子程序小计当作普遍 serving 净开销。GPrune/DivPrune 的结果仍按论文表的离线测量陈述，不外推服务层。

任何新剪枝方案都应至少报告 Random、固定网格/池化、输入降采样、FastV、DivPrune/SparseVLM；同时拆出 encoder、selector/compact、prefill、decode 与 end-to-end。短标签安全 Guard 应优先优化 TTFT/总请求时延，并单列 OCR、小目标、空间定位和 harmful-to-safe flip，而不是只报宏平均。
