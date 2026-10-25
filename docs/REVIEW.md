# Query semantics and verification

Compared against the supplied assignment requirements and relational schema.

Corrections from the submission:
- Q2: charging_rate >= 100, including exactly 100 kW.
- Q5: half-open full-day interval, rather than midnight-only equality.
- Q6: AVG(kwh) > 50, rather than averaging Boolean comparisons.
- Explicit join keys and NOT EXISTS improve clarity and NULL robustness in the portfolio revision.

Confirmed unchanged meaning:
- Q7 intentionally considers only children and grandchildren; the specification excludes deeper relationships.
- Q10 uses coupon.discount directly because the task explicitly defines the payable-income formula that way. It is not changed to 1-discount.
- Q9 evaluates existing person/car charging pairs. With no qualifying outlets, those existing pairs satisfy universal coverage (vacuous truth); this choice is explicit.

Run python checks/check_queries.py from any directory. All ten queries passed synthetic SQLite fixtures covering ties, exactly-100 threshold, midday coupon redemption, NULL kWh, owners versus non-owners, company descendants, complete versus incomplete outlet coverage, empty qualifying outlet sets, postcode and month boundaries, and discount multipliers. Fixtures are invented and contain no actual personal records.

SQLite validates the portable relational logic; a native MySQL 8 server/ONLY_FULL_GROUP_BY execution was not available. The provided MySQL DDL has not been tested on a live server. No benchmark or real business result counts are claimed. Original query logic remains in sql/original_queries.sql for provenance.
