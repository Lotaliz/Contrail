# LLM Wiki

一个面向 LLM/AI 研究与实践的轻量 Wiki。它将原始资料、研究项目、概念实体、实验数据、索引和维护元数据分开保存，并使用 Obsidian WikiLink 与标签建立连接。

## 导航

- [[LLM-Wiki/index/home.md|Wiki 首页]]
- [[LLM-Wiki/research/README.md|研究方向]]
- [[LLM-Wiki/metadata/workflows/README.md|标准研究工作流]]
- [[LLM-Wiki/index/tags.md|标签索引]]
- [[LLM-Wiki/index/entities.md|实体索引]]
- [[LLM-Wiki/raw/README.md|原始资料库]]
- [[LLM-Wiki/metadata/conventions.md|编写规范]]
- [[LLM-Wiki/CHANGELOG.md|修改记录]]

## 目录结构

    LLM-Wiki/
    ├─ raw/                 # 未改写的论文、网页快照及来源清单
    ├─ research/            # 项目、论文笔记、比较、缺口与 Motivation
    ├─ concepts/            # 跨论文复用的概念实体
    ├─ experiments/         # 实验记录、数据说明与结果摘要
    ├─ index/               # 首页、标签与实体索引
    ├─ metadata/            # Schema、规范和标准工作流
    ├─ templates/           # 可复制的文档模板
    ├─ changes/             # 复杂变更的详细说明
    └─ CHANGELOG.md         # 按日期统一记录实际变化

## 自动化工作方式

- AGENTS.md：项目级不变规则和任务路由。
- .agents/skills：读论文、做调研、跑实验、写论文和 Wiki 收尾。
- metadata/workflows：所有 LLM 共用的详细 SOP。
- .codex/hooks.json：任务结束前自动运行只读校验。
- 论文阅读层级：discovered、skimmed、deep-read；证据核验另用 verification 记录。
- CHANGELOG：按日期、类型和范围记录，不依赖 Git；所有 Git 操作由用户手动执行。

普通使用时可以直接说“阅读这篇论文”“调研某方向”“运行这个实验”或“根据当前证据写 Related Work”，无需重复完整维护 Prompt。
