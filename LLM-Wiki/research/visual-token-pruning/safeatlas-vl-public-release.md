---
id: source-note-safeatlas-vl-public-release
type: source-note
title: "SafeAtlas-VL 公开数据卡：版本、计数单位与字段边界"
tags: [source, research, data]
source_id: dataset-safeatlas-vl-2026-public-card
status: active
created: 2026-09-18
updated: 2026-09-18
---

# 官方版本与结构

截至 2026-09-18，[官方 Hugging Face 数据卡](https://huggingface.co/datasets/zrwang1211/SafeAtlas-VL)公开描述 train 为 1,000,000 条标注 / 594,487 张图片，test 为 5,000 条标注 / 4,979 张图片；完整集待后续发布。它不同于 [[LLM-Wiki/research/visual-token-pruning/papers/2026-wang-safeatlas-vl.md|论文 v1]] 的完整训练集统计，不能混用安全样本比例。

`images` 每图片一行、嵌套标注；`annotations` 每标注一行、不含图片，通过 `image_id` 关联。标注含 `target`、请求、回复、五级标签、类别和教师输出；category 的 `none` 对应 safe_core，teacher_head 为请求/回复保留三教师标签，image 目标为 null。

# 访问与批注

数据记录 gated，本轮只核公共数据卡，未提交申请、读取私有 token 或下载 248GB 数据，也未执行训练。不能声称统计了公开 1M 子集的无害比例、单模态可预测比例或整体配对相关性。

个人审计判断：将 category 或 teacher_head 当作模型输入会泄漏目标信息。统计单位应为标注实例或独立图片，需明确选择；不同 target 的安全性不能由同一个图片标签替代。
