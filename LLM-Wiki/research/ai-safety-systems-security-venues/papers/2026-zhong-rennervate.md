---
id: paper-note-zhong-2026-rennervate
type: paper-note
title: "Attention is All You Need to Defend Against Indirect Prompt Injection Attacks in LLMs"
authors: ["Yinan Zhong", "Qianhao Miao", "Yanjiao Chen", "Jiangyi Deng", "Yushi Cheng", "Wenyuan Xu"]
year: 2026
venue: "NDSS 2026"
source_id: paper-zhong-2026-rennervate
project: ai-safety-systems-security-venues
reading_level: skimmed
verification: source-checked
relevance: high
priority: high
tags: [paper-note, research]
status: active
related: [ai-safety-systems-security-venues]
created: 2026-08-25
updated: 2026-08-25
---

# tle: "Attention is All You Need to Defend Against Indirect Prompt Injection Attacks in LLMs

## Role and method

Rennervate pools attention-head and response-token signals for token-level detection and sanitization of indirect prompt injection. It is evaluated on five LLMs and six datasets against 15 defenses.

## Boundary

Fine-grained sanitization may reduce whole-request rejection, but the design requires access to attention features.
