---
id: change-2026-08-28-verify-adaptive-model-size-execution
type: change
title: 核验自适应模型规模的执行与权重加载语义
tags: [metadata, research, dynamic-inference, model-serving]
date: 2026-08-28
change_type: Changed
---

# 核验自适应模型规模的执行与权重加载语义

- 新增 Once-for-All、MatFormer 与 Mixture-of-Depths 来源和论文笔记，并把 PuDDing 升级为 deep-read。
- 将弹性推理拆成部署前子网抽取、常驻共享超网就地激活、按请求加载预定义模块、前向内条件执行四种语义。
- 核验结论为：代表性方法通常不在请求关键路径永久剪除参数，但只有部分内存受限方法按请求加载模块；SuperServe、Deja Vu、Mixture-of-Depths 和 PowerInfer提供反例或不同实现。
- 对多模态安全 Guard 的推荐收敛为离线构建少量安全校准 profile，在线按风险、证据、SLO 与队列状态路由，并按 execution signature 组批和回退完整 Guard。
