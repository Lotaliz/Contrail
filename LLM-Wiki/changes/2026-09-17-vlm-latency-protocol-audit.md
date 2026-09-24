---
id: change-2026-09-17-vlm-latency-protocol-audit
type: change
title: "VLM 视觉 Token 压缩时延基线口径审计"
tags: [change, research, visual-token-pruning, efficient-inference]
date: 2026-09-17
change_type: Fixed
---

# 范围与结果

针对用户对前次时延基线的任务、batch 1/批处理、端到端与分类/生成口径追问，仅定向核验已列来源；不重新宣布 SOTA，不运行模型/实验，不执行 Git。复用现有 source_id，原始 PDF/实验文件不变。

- 新增 10 篇 skimmed/source-checked 定向笔记：VisionZip、SparseVILA、ZipVL、VFlowOpt、VScan、HAWK、V2Drop、STC、SIEVE、PACE；新增本 changes 记录。
- 修改现有 SOTA 综合页、reading-log、项目 overview、UniPruneBench/EvoPrune 笔记、sources.yaml 和 CHANGELOG；来源登记更新访问日期与可回溯的效率设置。
- ZipVL 的最大 batch decode throughput 不再当作固定 batch / batch 1 加速；V2Drop 的 LLM-only、full model 和整套 benchmark 分开；PACE 明确只报 TTFT；EvoPrune overall 与 TTFT 的完整 decode 边界标待核。
- GPU/batch 未明确的条目不反推设置；多帧、多 tiles、8 卡质量评测与离线预算估计 batch 均不当作推理请求 batch。准确率/F1 的任务指标不当作分类头推理证据。

# 证据与待人工确认

完整逐方法证据与来源定位见 [[LLM-Wiki/research/visual-token-pruning/autoregressive-vlm-pruning-sota-baselines.md]]；检索边界见 [[LLM-Wiki/research/visual-token-pruning/reading-log.md]] Q14。SparseVILA 的 ICCV 与后续 arXiv v1 输出/量化协议不拼接；STC 原文与 README 的阶段表使用 s，异常绝对量级仍待代码核验，不擅自改为 ms。

待确认：多数论文未明确请求 batch、完整 decode 长度及预处理边界；尚无本轮来源的统一线上并发服务 E2E 比较。所有建议的 batch/输出长度扫描均未执行。

# 校验

按 wiki-finalize 执行只读校验器：PASS，0 errors，2 warnings。两条均为此前已有、未改动内容：XGuard 原始分析指向缺失的 ghosted-layer-recovery README；2026-08-25 的旧设计变更记录未被 CHANGELOG 引用。未改写原始实验或替用户判断旧记录关系。
