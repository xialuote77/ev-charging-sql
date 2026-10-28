# EV Charging Network: SQL Query Portfolio

## 中文概览

### 电动车充电网络 SQL 分析

基于包含车辆、充电站、充电记录和优惠券等信息的关系型数据库，编写 10 类 SQL 查询，分析充电设施覆盖、用户充电行为、车型平均充电量及站点收入。

- **个人工作**：独立完成 SQL 查询，使用多表连接、聚合、嵌套子查询及 EXISTS / NOT EXISTS 处理不同业务条件。
- **查询场景**：识别高功率充电站、查找无充电记录的车辆、分析车主与非车主充电行为、检查指定充电接口的使用覆盖情况，以及计算优惠券折扣后的收入。
- **结果验证**：为查询补充合成数据检查，覆盖空值、日期边界、并列最大值等情况，10 条修订查询均通过检查。

本项目源于墨尔本大学数据库课程，使用课程提供的数据库结构。查询文件和运行方式见下方说明。

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
