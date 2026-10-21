---
id: qwen3-vl-resolution-budget-notes
type: source-note
title: "Qwen3-VL 图像网格：原图信息与编码预算的边界"
tags: [research, visual-token-pruning, efficient-inference]
source_id: code-qwen3-vl-vision-process
status: active
created: 2026-10-10
updated: 2026-10-20
---

# Qwen3-VL 图像网格与小裁图

来源：[官方 README](https://github.com/QwenLM/Qwen3-VL)、[vision_process.py](https://github.com/QwenLM/Qwen3-VL/blob/main/qwen-vl-utils/src/qwen_vl_utils/vision_process.py)，访问 2026-10-10。读取 main 上的图像 resize 相关函数与说明，未固定 revision、未运行代码；本地审核处理器实现未核验。

**源码事实：** README 支持 `resized_height/resized_width` 和 `min_pixels/max_pixels` 控制尺寸，Qwen3-VL 使用 image patch size 16；`smart_resize` 对网格取整，在面积低于最小像素要求时有上采样分支，`fetch_image` 最终调用 image resize。预处理后的网格不必等于源图原尺寸的网格。

**项目判断：** 需区分源图包含的信息和模型获得的编码容量。插值不会新增真实细节，但可能改变目标相对视觉编码器的尺度；是否增加预算收益属于 Cx 实验假设。不能把原尺寸裁图参考 Token 数直接当作不可超过的模型容量上限。

用户报告全图平均约 400 Token；面积近似下 1/16 和 1/9 裁图分别约 25、44 Token。此估算忽略取整、补边及处理器已有缩放，不能代替逐图实际网格。更大框在相同预算下减少采样密度；裁图相对参考预算的三档可以表达尺度差异，同时维持原单框结构。

关联：[[LLM-Wiki/changes/2026-10-20-resolution-plan-and-superseded-ideas-cleanup.md|cx-global-local-importance-plan（历史方案，已删除）]]。
