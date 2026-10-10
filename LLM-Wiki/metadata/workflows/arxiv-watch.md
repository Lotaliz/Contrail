---
id: workflow-arxiv-watch
type: metadata
title: "arXiv 近期论文追踪：发现、人工筛选与精读晋升"
tags: [metadata, workflow, research, source]
status: active
created: 2026-09-16
updated: 2026-10-10
---

# 目的与边界

这是 [[LLM-Wiki/metadata/workflows/literature-review.md|文献调研流程]] 的 discovered 模式：定期检索、读标题与摘要确认相关性、登记候选，交由研究者决定精读。默认不下载 PDF、不写逐篇阅读笔记、不更新 landscape、comparison、gaps、motivation 或 concepts。只看题录与摘要仍是 discovered，不能标为 skimmed 或 source-checked。

执行前读 [[LLM-Wiki/metadata/workflows/common-contract.md|共同契约]]、项目 overview 和项目 `watch/overview.md`。具体主题、查询和预算只维护在项目配置页；仓库 skill 负责调用本流程。

## 文件分工

| 位置 | 内容与维护责任 |
|---|---|
| `raw/sources.yaml` | 每篇已确认题录的论文唯一来源；标题、作者、年份、URL、访问日期；没有 PDF 时本地路径和哈希留空 |
| `research/<project>/watch/overview.md` | 检索配置、时间窗口、纳入边界、频率和简短调用示例 |
| `watch/candidates.md` | 所有已筛查命中的持久轻量索引；推荐队列保留人工决定，未入推荐的相关论文单列备查，out-of-scope 单列排除；一篇一行 |
| `watch/runs.md` | 批次导航与 complete / partial / failed 状态；不是论文索引 |
| `watch/runs/<run-id>.md` | 当次准确查询、时间窗口、覆盖情况、候选 ID、重复 ID、待处理与失败信息 |
| `research/<project>/papers/` | 研究者选中后实际执行阅读的笔记；默认等精读任务启动后再创建 |
| 项目 `reading-log.md` | 继续承载专题调研与阅读证据；链接近期追踪入口，不复制每次发现列表 |

候选正文中的关系、筛选决定与批次状态是业务字段，不是新的 Wiki 文档类型、frontmatter status 或技术标签。页面复用 index / metadata 与已有标签，保持 Schema 不变。

## 时间与检索

1. 启动时冻结 UTC 截止时刻 `T`，窗口为 `[T - 10 天, T]`，日志同时写 Asia/Shanghai 时刻。使用首次提交时间判断是否在窗口内，区分 API 返回的 published 与 updated。
2. 日期查询使用 `submittedDate`，按 submittedDate 降序；UTC 边界按分钟构造，返回后再按 published 检查精确边界。arXiv 官方文档给出的日期筛选是 submittedDate，lastUpdatedDate 是排序选项，不能据此假设存在更新时间范围筛选。[arXiv API 文档](https://info.arxiv.org/help/api/user-manual.html)
3. 使用项目预设的少量标题/摘要查询组。类别只作辅助，不要求论文必须属于单一类别。搜索引擎仅在 API 不可用时辅助发现，必须回到 arXiv 页面确认身份和首次提交日期；该回退标记 partial，不能声称等价覆盖。
4. 按项目预算分页，记下每组 totalResults、实际 start / max_results、读取数量与下一页起点。达到上限而仍有结果即 partial，不用“未发现论文”代替截断。API 连续请求间隔至少 3 秒；失败最多重试两次，遇到限流遵守 Retry-After，较长等待交由后续补检。[arXiv API 文档](https://info.arxiv.org/help/api/user-manual.html)
5. 本任务默认只找新论文。近 10 天外的旧论文新版本不自动扩入；若当前命中发现已知论文版本变动，只记录版本信息，保留原来源 ID、原候选行与人工决定，不作为新论文推送。独立的旧论文版本监控需另定范围。

滚动窗口会重叠，这是重试和延迟索引的缓冲，不按“上次运行之后”缩窄。停跑超过 10 天时明确记录未覆盖的时间区间；需要补检时按每段最多 10 天拆分，作为显式补检任务，不悄悄扩大例行窗口。关键词检索始终可能漏掉术语不同的论文，不以零命中证明没有新研究。

## 去重与轻量写入

按以下顺序处理，先核验身份再新增：

1. 查询间合并相同 arXiv 基础 ID，去掉 URL 中的 `vN`；保留本次实际看到的版本，不猜测版本号。
2. 查当前项目全部候选行，以及全库 sources.yaml、论文笔记和 reading-log 中的 arXiv ID / DOI。已有来源复用原 source_id；其他项目已有笔记也复用链接，不复制笔记。
3. 对使用会议 URL 的既有来源，用规范化标题和作者核对。相似标题仅是重复提示，不能直接合并；身份不明时写到当次日志的“待核验”，不分配新 source_id。
4. 当前项目已有候选只更新确实观测到的最近命中日期或版本；不改 first_seen，不覆盖研究者的筛选决定。旧笔记已存在但候选索引尚无此论文时，首次遇到再补一行并链接原笔记，标注历史来源，不能称作新论文。已有 deep-read 笔记可记 ingested；其他层级保留原层级并由研究者决定是否进一步阅读。
5. 仅对身份已确认的新来源登记现有题录字段，使用 `paper-arxiv-` 加基础 ID 的 kebab-case 表示作为稳定 ID；已有 ID 绝不改名。venue 只记已核实身份，没有核实会议时写 arXiv；缺失信息明确留空或 unknown，不补造。版本与“标题/摘要筛查，discovered”写在 notes 中。
6. 在 candidates.md 写一行：基础 ID、实际观测版本、标题与 arXiv 链接、首次提交日期、agent 关系判断与一句理由、首次/最近命中日期、source_id、已有笔记链接。入推荐队列的 direct / adjacent / uncertain 行另含研究者决定；相关备查和 out-of-scope 行不设决定字段。作者题录只存来源表；不写方法详情或实验数字，推荐排序依据另存批次日志。

关系判断取 direct / adjacent / uncertain / out-of-scope，并在理由中标注“摘要筛查判断”。out-of-scope 命中在独立排除表保留题录和排除理由，仅用于避免重复筛查；它由 agent 按项目边界直接视为范围外，不进入 pending / selected / deferred / skipped 人工决定队列。用户要求重审时，将该条移到相关候选表并设 pending。已核验但尚未读完摘要的命中记 uncertain；未经身份核验的命中只在批次日志留待办，不能编写相关性。符合主题的论文先按下述推荐上限处理，只有本批入选推荐的条目默认 pending。

候选索引中的一句相关性理由和排除理由统一使用中文，并写明“摘要筛查判断”；保留论文原标题、方法名以及 direct / adjacent / uncertain / out-of-scope 等固定枚举值。写入前检查本批新增条目，避免夹入英文理由。

## 每批推荐上限与初筛排序

读取项目 watch/overview.md 的 pending 新增上限；visual-token-pruning 自 2026-10-10 起每批至多新增 10 篇 pending。该上限是每批新增量，不是现有 pending 总量；不得删除或改写已有人工决定，也不回溯删减旧批次。

先完成去重、主题初筛和在线策略蒸馏排除，再对本批此前未登记的 direct / adjacent / uncertain 论文排序。符合条件的数量不超过上限时全部进入 pending；超过上限时只选最有潜在研究价值的前十篇，不为凑满十篇放宽主题边界。排序只读标题和摘要，不为推荐名额阅读正文、PDF 或实验表；潜在影响力是 agent 的初筛判断，不冒充已证实影响力或引用排名。

综合判断方法设计的新意与清晰度、可迁移范围、真实计算路径或部署价值、摘要中证据的具体程度，以及对当前项目政策条件视觉选择、单局部框和证据保留的启发。避免仅按作者、机构、论文标题或摘要中的最大加速数字排序；同等价值时兼顾机制覆盖，减少近乎重复的方法。日志记录入选顺序和一句中文依据；截断或未核验时说明排序仅针对已取得的记录。

符合主题但未进入本批前十的论文，放入 candidates.md 的“相关备查（未入推荐队列）”表，保留原关系、题录、source_id、日期与一句未入选依据，不设人工决定字段，不标为 out-of-scope、skipped 或 deferred。它们继续参与以后查重，不在每次重叠检索中重新引入 pending；用户可显式要求将备查论文移入推荐队列或选择精读。沿用既有 Wiki 类型、标签和决定枚举。

## 人工决定与晋升

| 决定 | 含义与允许的操作 |
|---|---|
| pending | 尚未决定；agent 新增 direct / adjacent / uncertain 候选的默认值 |
| selected | 研究者确认精读；例行检索仍不执行阅读 |
| deferred | 研究者暂缓；后续命中保留决定 |
| skipped | 研究者明确不精读；保留来源和索引，不删除 |
| ingested | 已完成该论文的 deep-read 收录，有可用笔记链接 |

研究者可以编辑推荐队列的“决定”单元格，或向 agent 提供 arXiv ID 和决定。更新决定时记录日期与“用户”，不要根据推荐优先级自动 selected。相关备查表和排除表没有决定状态；用户若选择备查论文，移入推荐队列并记录其明确决定；若要求重审排除论文，先改关系再移入队列。历史 deep-read 记录首次补入时可注明“已有精读记录”。

只有研究者明确启动“精读这些 ID”或“精读已选列表”才进入 [[LLM-Wiki/metadata/workflows/paper-ingestion.md|paper-ingestion]]。复用来源 ID 和既有笔记，按真实阅读深度写 reading_level / verification；选中本身不等于 deep-read。新笔记放项目 papers 下，精读完成并通过 wiki-finalize 后才将候选改为 ingested。阅读失败保留 selected 与失败位置；已生成的笔记按实际深度保持 draft，不伪装完成。

## 批次日志与完成条件

使用 [[LLM-Wiki/templates/arxiv-search-run.md|批次模板]]，run-id 使用 UTC 启动时刻，如 `2026-09-18-020000Z`。重试另建带后缀的日志，引用原批次，不覆盖原失败记录。默认保存查询、URL、访问时刻、题录 ID 与覆盖记录，不要求下载结果快照；如保存响应原件，放 raw/web 并登记来源，后续转换另存文件。

- complete：所有预设查询页已读取完，所有窗口内的唯一命中已筛查、去重并登记；即使零新增也记录批次。
- partial：分页截断、筛查预算用尽、身份待核验、回退检索、局部失败或检索成功但写入/校验未完成；保留查询和未处理 ID。
- failed：没有任何可用检索结果；写错误与已尝试方式，不能宣称没有新论文。
- 完成后更新候选/索引的 updated 和 runs 导航。运行 wiki-finalize；当次有结构、知识或筛选决定变化时按规则更新 CHANGELOG，单纯重复命中的访问记录不必制造知识更新条目。
- 人工核对三张表的候选基础 ID 合计唯一、source_id 存在、本批 pending 新增量不超过项目上限、选中/跳过决定未被覆盖、备查与排除表没有决定状态、ingested 有 deep-read 笔记。日志分别记录符合主题数、pending 新增数、相关备查数和排除数。现有 Wiki validator 不校验表格内业务字段，语义检查不可省略。
- 报告查询窗口、新增相关/相邻候选、重复数、未完成覆盖与日志链接。有新候选、重要失败或需要用户判断时通知；仅重复命中或 complete 且零新增时保持安静，日志照常保存。

每月复查相关候选的 pending / deferred 积压、查询词、排除理由和漏检案例；每次补检仍去重。不清空 skipped 或 out-of-scope 排除条目，不把来源登记表或轻量索引当成精读证据。
