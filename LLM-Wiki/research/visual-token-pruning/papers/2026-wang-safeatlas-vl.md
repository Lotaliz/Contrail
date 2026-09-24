---
id: note-2026-wang-safeatlas-vl
type: paper-note
title: "SafeAtlas-VL：训练集安全样本、图文关联与单模态标签捷径核验"
authors: ["Zongrui Wang", "Xiangyang Zhu", "Sicheng Wang", "Han Wang", "Dingyi Rong", "Zeyu Zhang", "Chunyi Li", "Yue Shi", "Kaiwei Zhang", "Zicheng Zhang", "Yuan Tian", "Qi Jia", "Yan Teng", "Wei Sun", "Ning Liu", "Guangtao Zhai"]
year: 2026
venue: "arXiv"
source_id: paper-wang-2026-safeatlas-vl
project: visual-token-pruning
reading_level: skimmed
verification: source-checked
relevance: high
priority: high
tags: [paper-note, research, multimodal-safety, safety-guardrail, safety-evaluation, vision-language-model]
status: active
created: 2026-09-18
updated: 2026-09-24
---

# 来源与核验范围

正式标题为 *SafeAtlas-VL: Beyond Binary Multimodal Safety with Large-Scale Data and Guard Models*，用户输入的 SafeAtlus-VL 按该资源理解。[官方 v1 HTML](https://arxiv.org/html/2608.29098v1)及 [arXiv v1 PDF](https://arxiv.org/pdf/2608.29098v1)（本地副本已于 2026-09-24 清理）；定向 skimmed 数据构造、标签、目标定义和相关实验，未作完整 Guard 方法精读或模型复现。已读摘要、引言、总览图、主要结果与结论；视觉核验 PDF pp.3/5/6 的 Figures1/3/4 及 pp.36–38 的 TablesA12–A14。原件元数据触发 Poppler 语法警告，所查页面可读，原件未修复/重导出。

## 研究问题与方法家族

论文以目标条件化的五级安全标签统一 image、request、response，并训练 Qwen3-VL 系列 Guard；这是数据和序数风险建模工作，不是早退出或 token 剪枝工作。模型主表用于任务定位，不能替代本数据集缺模态实验。与本项目的关系是训练数据与证据可观察性审计；是否深读完整 Guard 方法，取决于后续是否复现该模型。

## 直接来源事实：安全训练样本

§2.5 / p.6 和 TablesA12–A14 / pp.36–38 的完整训练集统计：

| 判别目标 | 全部标注实例 | safe_core | 占该目标比例 |
|---|---:|---:|---:|
| image | 228,727 | 155,474 | 67.97% |
| request | 528,916 | 78,570 | 14.85% |
| response | 745,641 | 141,730 | 19.01% |

按这三项自行加总，safe_core 为 375,774 / 1,503,284，约 25.00%；这是标注实例比例，不是独立图片比例，也不是公开 1M 子集的统计。safe_leaning_disputed 是另一标签，不能计入上述 safe_core 数字；§4.1 / AppendixC.3 的二分类评测将 boundary_uncertain 及以上作为 unsafe。

## 直接来源事实：图文构造与监督

§2.2、AppendixA.5 / pp.4/16–17：请求基于图像生成并经独立相关性检查，回复经上下文检查。图文配对有意关联；筛图的 CLIP 阈值是图像—检索锚点相似度，不是最终图像—用户请求的整体相关性指标。

§3.1 定义三个不同输入目标；image 是纯图片判别。AppendixA.6 / p.17：文本教师 Qwen3Guard 只看请求，或请求加回复；另外两个教师看图文。§2.3 / Figure3 / p.5：请求/回复的两个 core 端点由三教师一致判决构成。核查原文实验与消融，未见同一 SafeAtlas 测试集的缺图片/缺文本基线或必须联合判别比例；外部文本测试不能代替这种证据。

## 个人推导：core-only 请求/回复二分类存在结构性文本捷径

在只保留两个 core 标签的请求/回复子集中，构造规则意味着

$$
y=\mathrm{safe\_core}\Rightarrow j^Q=\mathrm{S},\qquad
y=\mathrm{unsafe\_core}\Rightarrow j^Q=\mathrm{U}.
$$

因此，对该已筛选子集，原标注时文本教师的输出即可区分端点，不需要视觉教师输出。这是从标签规则得到的逻辑关系，不是已跑出的 text-only 100% 准确率：重新执行教师可能受版本、prompt 或随机性影响，普通学生也未必复制教师。该推导不覆盖三种中间等级，也不覆盖 image 目标。

其他文字自足样本或图片主导样本可能存在，实际比例未知。语义相关、模型能从单模态猜标签、真实政策必须依赖图文，是三种不同问题；前者不能证明后者。safe_core 表示标注规则的低风险端点，不是逐条人工证明安全。

## 候选审计与实验启发（尚未运行）

- 分开报告三个 target；request/response 再区分五级标签、core-only 和全等级二分类。不要把 image 目标计入图文联合必要性的分母。
- 相同数据划分分别训练/校准 text-only 与 full multimodal；response 的 text-only 输入至少包括请求和回复。image-only 用同一图片猜 request/response 标签只能作为捷径基线，因为目标不同于图片安全。
- 随机打乱图片而保持原标签只诊断对视觉输入的依赖，不是新构造的有效安全测试。可信的联合判别评测需人工确认并重新标注的匹配反事实图文对，检查换图片/换文本是否真的改变政策标签。
- 同图片多条交互按图片或近重复图片组隔离训练/测试，避免同一图泄漏；元数据中的 category 和 teacher_head 只作监督或事后审计，不能作为预测输入。
- 对比 [[LLM-Wiki/research/visual-token-pruning/papers/2025-palaskar-vlsu.md|VLSU]] 的独立模态/组合标注与当时的联合压缩路线：仅在本集获得快且准的结果，不能证明图文联合机制必要。若文本级联足够好，它应成为必要基线。

## 未完成与收尾记录

公开版本见 [[LLM-Wiki/research/visual-token-pruning/safeatlas-vl-public-release.md|数据卡核验]]。原始 gated 记录未读取，未统计公开子集标签或图文相关性，未运行模态消融；这些是证据缺口，不用 LLM 推断补数字。没有修改正式 motivation 或现有实验结果。

本轮新增原始 PDF、本页与数据卡 source-note；修改 raw/sources.yaml、项目 overview、reading-log、index/tags.md 和 CHANGELOG.md。结尾由 wiki-finalize 校验；既有旧实验断链与旧 changes 未关联的警告交由另行判断。
