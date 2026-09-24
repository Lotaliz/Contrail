---
id: ai-system-security-hot-topics-landscape
type: synthesis
title: 当前热门 AI 系统安全问题与技术版图
tags: [research, ai-agent-security]
project_id: ai-system-security-landscape
sources: [webpage-usenix-security-2026-cfp-ml, report-nist-2025-adversarial-ml-taxonomy, webpage-owasp-2025-llm-top-10, knowledgebase-mitre-atlas-2026]
status: active
created: 2026-09-15
updated: 2026-09-15
---

# 当前热门 AI 系统安全问题与技术版图

## 推荐二维分类

### 维度一：攻击目标

1. **完整性**：让模型、检索或 agent 产生攻击者希望的错误行为。
2. **机密性/隐私**：获得训练数据、提示、memory、RAG 文档、模型参数或用户秘密。
3. **可用性/成本**：拖慢、耗尽、使服务拒绝服务或制造异常账单。
4. **授权与控制**：让模型越权调用工具、访问资源、跨租户或绕过策略。
5. **来源与问责**：伪造模型/内容来源、移除水印、破坏审计或否认行为。

### 维度二：攻击面

数据与供应链 → 训练/微调 → 模型产物 → 推理/guard → RAG/embedding/memory → agent/工具 → serving/硬件 → 用户与内容生态。

## 热门问题

### 1. Prompt injection、jailbreak 与 guardrail bypass

- 直接或间接 prompt injection、跨模态注入、system prompt/政策绕过、编码/多轮/组合攻击。
- 防御关注输入隔离、指令与数据分离、来源标注、运行时 guard、隐藏状态检测、策略执行和自适应攻击评测。
- 热点原因：它是 RAG、浏览器、邮件、代码 agent 等外部数据进入控制平面的共同入口。

### 2. Agentic AI：工具调用、权限与多代理安全

- Excessive agency、confused deputy、工具参数注入、credential misuse、越权执行、memory poisoning、多 agent 串谋或级联失败。
- 核心已从“模型会不会回答坏内容”转为“模型能否造成真实状态变化”。
- 防御关注最小权限、capability token、执行前验证、人类确认、信息流控制、事务/回滚和可审计轨迹。

### 3. RAG、向量库与长期 memory 安全

- 检索库投毒、恶意文档间接注入、embedding inversion、跨租户检索、私有文档 membership、ACL 与语义检索不一致、长期 memory 污染。
- 防御必须同时覆盖 ingestion、索引、retrieval、context assembly 和生成，而不是只在最终输出上加 guard。

### 4. 数据/模型投毒、后门与 AI 供应链

- 预训练数据、微调数据、RLHF/偏好数据、RAG 文档和合成数据投毒；模型权重、adapter、checkpoint、tokenizer 和第三方模型仓库后门。
- 研究重点包括隐蔽触发器、跨模态/语义后门、训练后持久性、模型合并/量化后的行为、数据与模型 provenance。

### 5. 隐私、训练数据与系统秘密泄露

- MIA、训练数据提取、模型反演、属性/梯度推断、PII extraction、system prompt 泄露、RAG/embedding/memory 泄露、跨版本或侧信道泄露。
- 防御包括差分隐私、隐私审计、数据最小化、输出限制、机密计算、机器遗忘和访问控制。
- 当前趋势是从单模型输出扩展到 tokenizer、checkpoint、压缩版本、检索库和 agent 轨迹。

### 6. 模型窃取、IP 与内容/模型来源

- API model extraction、功能克隆、模型/adapter 偷窃、训练数据版权检测、模型水印移除、内容水印规避、伪造模型来源。
- 热点由开放模型生态、蒸馏、模型路由、多供应商 API 和生成内容治理共同推动。

### 7. 对抗规避与多模态鲁棒性

- 传统 adversarial examples 仍重要，但热点转向物理世界、跨模态、语义保持、黑盒转移、自适应攻击及感知—推理—策略链条。
- 只对 benign noise 鲁棒通常不构成安全顶会贡献；必须明确攻击者怎样操纵输入以及造成何种系统影响。

### 8. Serving、运行时与硬件攻击面

- GPU/accelerator 多租户侧信道、模型与 KV cache 泄露、cache/批处理隔离、speculative execution、模型版本/压缩版本侧信道。
- Availability 包括 sponge example、超长上下文、递归 agent、tool loop、token/cost exhaustion 和调度 starvation。
- 防御需要端到端测量吞吐、尾时延、隔离性和安全退化，不能只报告 FLOPs。

### 9. 不安全输出处理与下游软件执行

- LLM 输出进入 shell、SQL、浏览器、模板、CI/CD 或代码仓库后形成命令注入、XSS、依赖混淆和供应链漏洞。
- 安全边界应放在确定性解析、类型/模式验证、沙箱和授权系统，而不是依赖 system prompt 作为权限控制。

### 10. 模型滥用、内容完整性与人因安全

- 恶意代码/诈骗/钓鱼辅助、deepfake、misinformation、骚扰、极端主义、角色平台安全和过度依赖。
- 研究既包括攻击能力和防护，也包括用户行为、平台政策、误拒/漏报、申诉与治理效果。
- 与一般 AI safety 的分界是是否有明确恶意行为者、滥用路径、受害者和可测安全结果。

## 2025—2026 热度判断

### 第一梯队：快速升温且系统问题尚未收敛

- prompt injection / jailbreak 与 guardrail bypass；
- agent 权限、工具调用、memory 与多 agent 安全；
- RAG、embedding、向量库和私有知识安全；
- 数据/模型供应链投毒与后门；
- 训练数据、PII、prompt、RAG 和跨版本隐私泄露。

### 第二梯队：成熟问题在新模型/模态/部署上重构

- adversarial evasion；
- model stealing、watermark 和 provenance；
- 生成式多模态隐私与安全；
- serving DoS、成本攻击和硬件侧信道；
- 压缩、量化、微调、unlearning、合并后安全性质是否保持。

### 横向共性难题

- 自适应攻击者与防御绕过；
- 真实查询/成本/权限约束；
- 多租户与跨组件组合攻击；
- benchmark 污染和不可比指标；
- 安全—效用—时延—成本的联合权衡；
- artifact、可重复性、负结果与负责任披露。

## 安全顶会审稿边界

一个“AI 有缺陷”命题要成为安全研究，通常至少要具备：

1. 明确攻击者及其能力、知识和成本；
2. 明确可攻击的系统组件、信任边界和生命周期阶段；
3. 明确违反的安全属性和实际影响；
4. 与真实部署一致的基线、查询预算、权限和自适应攻击；
5. 端到端系统与安全评测，而非只报告任务准确率或攻击成功率；
6. 可复核 artifact、伦理分析和披露过程。
