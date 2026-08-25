---
id: paper-note-vasu-2024-mobileclip
type: paper-note
title: "MobileCLIP: Fast Image-Text Models through Multi-Modal Reinforced Training"
authors: ["Pavan Kumar Anasosalu Vasu", "Hadi Pouransari", "Fartash Faghri", "Raviteja Vemulapalli", "Oncel Tuzel"]
year: 2024
venue: "CVPR 2024"
source_id: paper-vasu-2024-mobileclip
project: safety-classifier-compression
reading_level: deep-read
verification: source-checked
relevance: high
priority: high
tags: [paper-note, research, method]
status: active
related: []
created: 2026-08-24
updated: 2026-08-24
---

# MobileCLIP

## 核心方法

用 caption model 生成多 caption，并离线保存强 CLIP ensemble 在增强图像、真实/合成文本上的 embedding；这些 reinforced data 可供多个轻量 image/text encoder 反复训练，避免在线教师开销。

## 主要证据

MobileCLIP-S2 相比此前 ViT-B/16 CLIP 方案 2.3× 更快且更准；作者报告 10–1000× 学习效率提升。延迟在 iPhone 12 Pro Max、Core ML、batch=1 下测量；例：MCt text encoder 1.6ms 对 Base 3.3ms。

## 证据定位与局限

方法第 3–4 节；表 1；延迟协议与消融第 5.1 节。一次性数据强化、embedding 存储与教师生成成本需在小流量/频繁更新场景单独核算。
