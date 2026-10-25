# EV Charging Network: SQL Query Portfolio

## 中文概览

**项目定位：SQL / 关系型数据查询 / 业务规则验证。** 围绕电动车、充电站、充电事件和优惠券，编写十类查询，回答设施覆盖、车辆充电行为、平均电量、企业关系及收入计算问题。

- **个人贡献**：个人课程项目中的 SQL 查询实现；表结构来自教学材料，不表述为本人独立设计的生产数据库。
- **SQL 能力**：多表 JOIN、EXISTS/NOT EXISTS、GROUP BY/HAVING、聚合、嵌套子查询及“覆盖全部出口”条件的关系除法。
- **检查结果**：对照原需求修正 100 kW 边界、完整日期区间和平均值条件；十条修订查询通过合成数据检查，覆盖 NULL、并列最大值、空集合和月份边界等情况。
- **验证范围**：检查使用 SQLite 验证通用关系逻辑，并非原生 MySQL 8 执行或生产性能测试；保留原版查询以区分提交内容与后续修订。

## English documentation

Ten relational queries over an electric-vehicle charging schema. This individual project demonstrates multi-table joins, anti-joins, aggregation, nested subqueries, manufacturer hierarchies and revenue calculations.

## Contents

- `sql/schema.sql`: MySQL schema without original data records.
- `sql/original_queries.sql`: submitted query logic, with identity/template comments removed.
- `sql/reviewed_queries.sql`: reviewed portfolio revision with documented fixes and explicit join keys.
- `docs/REVIEW.md`: requirements review and verification scope.

## Business questions represented

Find large-battery vehicles; stations with high-rate outlets; stations without facilities; registered vehicles without charge events; facilities with unused coupons; average charging energy by vehicle model/manufacturer; company descendants; owner/non-owner charging patterns; charging coverage; and income for a specific outlet/month.

## Running

Use MySQL 8 with an empty disposable database. Load `sql/schema.sql`, populate it with authorised or synthetic records, and execute one query at a time. Schema creation is not intended for an existing populated database. All ten revised queries passed the included synthetic SQLite checks (`python checks/check_queries.py`). This verifies portable query logic and representative edge cases; native MySQL 8 execution and server-specific SQL modes were not available. No result counts or performance claims are invented.

Q2 now includes exactly 100 kW and Q5 checks the complete day. Q6 originally used `AVG(ce.kwh > 50)`, which averages Boolean comparisons. The reviewed variant uses `AVG(ce.kwh) > 50` for groups averaging more than 50 kWh. This is a portfolio correction, not a claim that the original submission was correct.

Originally INFO20003 Assignment 2, University of Melbourne. The schema is supplied teaching material, not a database designed independently by the author. Personal-looking rows from the original dump/CSVs are excluded; upstream redistribution terms need review before publication. See contribution and review notes.
