---
id: change-2026-08-25-deep-read-vispco-qwen-experiment
type: change
tags: [research, experiment, method]
date: 2026-08-25
change_type: content
title: 精读 VisPCO 并设计 Qwen2.5-VL 小规模实验
---

# 精读 VisPCO 并设计 Qwen2.5-VL 小规模实验

## 论文笔记升级

- 将 VisPCO 从 skimmed 升级为 deep-read，补全 Qwen2.5-VL-3B 的模型、30K LLaVA-Instruct 训练集、图像面积平衡、八项 VLMEvalKit benchmark、700 个配置的 empirical Pareto frontier、FLOPs/TTFT/throughput 和超参数。
- 分离八项平均与 Table 3 三项平均，解释 Table 1 标准差来自 sampled configurations 而非训练 seeds。
- 记录 Table 1 的 50% TFLOPs 标题疑似排版错误，以及 §4.1、Appendix Table 6 与当前公开脚本之间的超参数差异。
- 核对官方实现，确认当前预处理脚本实际 resize 图片而非按论文文字进行样本重采样，且公开训练脚本使用 10K 路径而非论文 30K。

## 实验设计

- 在 `experiments/20260825-vispco-qwen25vl-small/` 新建 planned experiment，仅包含预注册 README，不编写或执行代码。
- 固定 Qwen2.5-VL-3B + FastV selector，在 A-OKVQA、MMBench、TextVQA 各 100 个样本和 50% FLOPs 下比较 Full、FastV、linear schedule、Random-8 与两种 VisPCO calibration data。
- 预先定义质量、预算、TTFT/P95、峰值显存、bootstrap、成功标准、6 GPU-hours 上限和停止条件。

## 未完成项

- 尚未下载模型或 benchmark，未生成样本索引，未运行训练或推理。
- 执行前仍需人工指定目标 GPU，并锁定 Qwen、VisPCO、FastV、VLMEvalKit 和各 evaluator 的不可变版本。

