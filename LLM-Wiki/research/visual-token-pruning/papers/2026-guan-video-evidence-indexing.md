---
id: note-2026-guan-video-evidence-indexing
type: paper-note
title: "Video Evidence Indexing: Learning Where to Look from Video Previews for Token-Budgeted Long-Video Question Answering"
authors: [Haowen Guan, Shengzhi Li, Shichao Pei]
year: 2026
venue: arXiv
source_id: paper-arxiv-2610-00757
project: visual-token-pruning
reading_level: deep-read
verification: source-checked
relevance: high
priority: high
tags: [paper-note, research, visual-token-pruning, vision-language-model, knowledge-distillation, efficient-inference]
status: active
created: 2026-10-10
updated: 2026-10-10
---

# VEI：低清预览引导高分辨率证据预算

## 原件与阅读边界

用户显式选择本文精读。原文为 [arXiv 2610.00757v1](https://arxiv.org/abs/2610.00757v1)，CC BY 4.0；完整 HTML 原件见 [[LLM-Wiki/raw/papers/2610.00757v1.html]]。核对 §3–5、表 1–6/9–10、附录 A/C–H 的选择、训练、成本及失败分析。未执行代码或训练，所有结果为作者报告。本文含 on-policy 自蒸馏，但还设计了推理期证据索引与目标级预算机制；此次阅读由用户 selected 决定直接授权。

PDF 原件另见 [[LLM-Wiki/raw/papers/2610.00757v1.pdf]]（21 页）；完整文件已解析，关键图表与 HTML 数字交叉核查，SHA256 登记在同一 source_id 的 local_artifacts。

## 推理和训练流程

§3：先以约 1 fps 构造低分辨率 Video Preview，每帧视觉上限为 1、6、12 或 24 token，超过 context limit 才降低采样率。第一轮调用根据问题、选项和预览生成自然语言 observation targets，再为每个目标生成 timestamp list。将有效时间戳去重合并，过多时均匀下采样，不足时均匀补足到 $K$ 帧；第二轮调用把预览和重新读取的高分辨率 Evidence Set 一起用于答案生成。

回答调用的视觉输入上限为 $n\tau_{lo}+K\tau_{hi}\le B$，默认 $K=32,\tau_{hi}=128$。这个式子约束回答输入，不是两次模型调用的完整计算成本。目标预算隐式由时间戳列表长度/EOS 决定，最终仍经固定帧数补齐规则，不能将其理解为任意动态总预算。

§3.3：冻结同 backbone teacher，给予 24-token/frame 预览及正确答案、可选题型；student 随机用四档预览生成自己的 indexing trace。teacher 在 student 的相同历史前缀上提供全词表分布，student 最小化平均 reverse KL $\mathrm{KL}(s_\ell\|t_\ell)$，只监督索引 trace，不监督最终回答生成；teacher 和采样 token 均停止梯度。训练为 LoRA rank 64/alpha 128，1,500 步、batch 8、学习率 $10^{-4}$，四张 H100 约 40 小时，MLVU <20 分钟的视频包含 2,044 道选择题和 495 道短答题（§4.1、表 10）。推理时没有正确答案特权输入。

## 结果、消融与成本

主 backbone Qwen3-VL-8B，VideoMME 无字幕、LVBench、MLVU 502 道选择题；另评测 LLaVA-OneVision-2-8B 与 Penguin-VL-8B。推理 deterministic、thinking disabled、最多生成 1,024 token，每种设置仅单次评测。

- 表 1：24-token 预览、50K context limit 时，uniform / training-free VEI / self-distilled VEI 平均为 59.4 / 63.6 / 66.9；256K full-context 为 65.4。102.2% 是相对平均准确率，不是每个子任务均超过 full-context。
- 同表：1-token 预览下 training-free VEI 的 47.2 低于 uniform 的 52.1；蒸馏后为 55.9。极低清预览会损害选帧，不能把免训练版本视为普遍有效。
- 表 4、附录 A 表 6：只生成 targets 的 EL 收益小或负；将目标绑定独立时间戳列表的 BP 才稳定增加收益。配对选择数量相近的子集也支持该组合，但这些子集与全测试集不同。
- 表 5：24-token/frame、5 秒容忍的 LVBench evidence recall 为 31.2→35.8，hit rate 为 48.8→53.3；hit 时正确率仍仅 69.5。证据区间命中是相关性指标，不能证明答案因果使用了所选像素。
- 表 9：移除高分辨率 Evidence Set 使 training-free 的平均成绩下降 5.0–11.1 个百分点，支持重新读取细节的作用；但少了输入 token，与精确匹配信息量的因果干预不同。

附录 C 的约 $87.8→$19.1 是按 token 数和固定有效费率估计的 4,751 道题成本，不是实测硬件延迟。作者明确说明两次调用的端到端时延、缓存和内存尚待测量；50K/256K 是配置 context width，不能直接解释为 5.12× 服务加速。

## 失败条件与项目判断

附录 E/H：可能定位到事件但错过后续结果、找到视觉片段却误读语义、集中于无关时段，或不命中标注窗口却答对。完成视频离线处理不等于因果在线 streaming；固定 Evidence Set 可能漏掉长事件，低清预览可能完全看不见小证据。teacher 是经验上界参考，不是 oracle；蒸馏后的同一 checkpoint 同时用于索引与回答，QA 改善未分离回答行为变化。代码和权重在本文版本中仍为计划发布，未核验外部实现。

**本项目判断：** 可借鉴“低成本全局覆盖→明确证据需求→把需求转成可执行局部观测”的链条，尤其是目标说明只有真实改变像素选择才有价值。与 [[LLM-Wiki/research/visual-token-pruning/papers/2026-peng-countercredit.md|CounterCredit]] 的区别是没有同成本随机 crop 的证据价值扣除；与 [[LLM-Wiki/concepts/methods/multimodal-token-pruning.md]] 的关系是输入获取粒度的预算近邻。C5 的单局部框、政策翻转和安全召回均不在本文实验范围，迁移为待验证假设。

TODO：索引与回答分项计时、匹配随机位置/面积、像素替换、target 对路线的实际作用和同图政策配对；不由本文单独新增正式 gap 或 concept。
