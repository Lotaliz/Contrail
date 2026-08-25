---
id: paper-note-wang-2025-selfdefend
type: paper-note
title: "SelfDefend: LLMs Can Defend Themselves against Jailbreaking in a Practical Manner"
authors: ["Xunguang Wang", "Daoyuan Wu", "Zhenlan Ji", "Zongjie Li", "Pingchuan Ma", "Shuai Wang", "Yingjiu Li", "Yang Liu", "Ning Liu", "Juergen Rahmel"]
year: 2025
venue: "USENIX Security 2025"
source_id: paper-wang-2025-selfdefend
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

# tle: "SelfDefend: LLMs Can Defend Themselves against Jailbreaking in a Practical Manner

## Role and method

SelfDefend runs a target LLM and a detection-state shadow LLM concurrently, then applies checkpoint-based access control before releasing output. It also studies distillation into dedicated defense models.

## Boundary

A central system-level anchor: the guard is combined with scheduling and an enforcement point. It maps naturally to a small-guard plus fallback architecture.
