---
id: change-2026-08-25-design-safety-compression-experiments
type: change
tags: [experiment, research, method]
title: 设计三项安全判别压缩标准实验
date: 2026-08-25
change_type: content
---

# 设计三项安全判别压缩标准实验

- 新建三个互不依赖的预注册说明：0.5B decoder 校准—剪枝—KD、0.4B decoder + 8B 置信度级联、0.3B encoder 校准—剪枝—KD。
- 三项实验统一使用 WildGuardTrain 训练，WildGuardTest、ToxicChat、XSTest 测试；统一 split、输入长度、优化器、学习率、batch、epoch、KD loss、随机种子、硬件和计时口径。
- 明确禁止样本增广和测试集调参；教师只对既有开源训练样本提供二类 soft targets。
- 预注册分类召回、单样本 P50/P95、batch latency/throughput、对照组、成功标准、72 A100-GPU-hour 预算与停止条件。
- 当前仅完成设计，没有编写代码、下载数据、训练模型或产生结果。
