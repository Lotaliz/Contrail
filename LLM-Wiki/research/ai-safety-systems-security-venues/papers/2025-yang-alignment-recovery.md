---
id: paper-note-yang-2025-alignment-recovery
type: paper-note
title: "Alleviating the Fear of Losing Alignment in LLM Fine-tuning"
authors: ["Kang Yang", "Guanhong Tao", "Xun Chen", "Jun Xu"]
year: 2025
venue: "IEEE S&P 2025"
source_id: paper-yang-2025-alignment-recovery
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

# tle: "Alleviating the Fear of Losing Alignment in LLM Fine-tuning

## Role and method

The paper restores a small gradient-selected subset of weights from the original aligned model and uses rollback to protect downstream utility. Across 125 fine-tuned models, the authors report reducing harmful rate from 33.25% to 1.74% with limited utility loss.

## Boundary

Direct evidence that downstream fine-tuning can damage alignment. It does not prove that every pruning or quantization method has the same effect.
