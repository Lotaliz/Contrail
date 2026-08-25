---
id: paper-note-liu-2026-sentinel
type: paper-note
title: "Quantifying Large Language Model Attacks Through the Lens of Model Cognition"
authors: ["Xiuming Liu", "Chaoxiang He", "Xuanran Yu", "Jichen Chai", "Feiyue Xu", "Sheng Hang", "Hanqing Hu", "Bin Benjamin Zhu", "Hongsheng Hu", "Shi-Feng Sun", "Dawu Gu", "Shuo Wang"]
year: 2026
venue: "USENIX Security 2026"
source_id: paper-liu-2026-sentinel
project: ai-safety-systems-security-venues
reading_level: deep-read
verification: source-checked
relevance: high
priority: high
tags: [paper-note, research]
status: active
related: [ai-safety-systems-security-venues]
created: 2026-08-25
updated: 2026-08-25
---

# tle: "Quantifying Large Language Model Attacks Through the Lens of Model Cognition

## Role and method

Sentinel fuses lightweight toxicity probes over intermediate hidden states. The official page reports fewer than 5M parameters, over 94% detection accuracy under adversarial evaluation, and half the false negatives of generation-level refusal.

## Boundary

A direct compression anchor, but it depends on target-model hidden states and is not a standalone 5M encoder.
