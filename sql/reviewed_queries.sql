-- Portfolio revision. Original submission is preserved in original_queries.sql.
-- Q1: largest battery, including ties.
SELECT model_name, model_year, battery_capacity
FROM electric_vehicle
WHERE battery_capacity = (SELECT MAX(battery_capacity) FROM electric_vehicle);

-- Q2: stations with at least one outlet at 100 kW or above.
SELECT cs.station_id, cs.state, cs.postcode
FROM charging_station AS cs
WHERE EXISTS (SELECT 1 FROM outlet AS o
              WHERE o.station_id = cs.station_id AND o.charging_rate >= 100);

-- Q3: stations without facilities.
SELECT cs.station_id FROM charging_station AS cs
WHERE NOT EXISTS (SELECT 1 FROM facility AS f WHERE f.station_id = cs.station_id);

-- Q4: people with vehicles that have never had a charging event.
SELECT p.license_num, p.person_name, COUNT(*) AS uncharged_vehicle_count
FROM person AS p
JOIN electric_vehicle AS ev ON ev.license_num = p.license_num
WHERE NOT EXISTS (SELECT 1 FROM charging_event AS ce WHERE ce.vin = ev.vin)
GROUP BY p.license_num, p.person_name
ORDER BY p.person_name ASC;

-- Q5: issued coupons, but none redeemed at any time on the specified day.
SELECT f.facility_id FROM facility AS f
WHERE EXISTS (SELECT 1 FROM coupon AS c WHERE c.facility_id = f.facility_id)
  AND NOT EXISTS (
    SELECT 1 FROM coupon AS c
    JOIN charging_event AS ce ON ce.coupon_id = c.coupon_id
    WHERE c.facility_id = f.facility_id
      AND ce.requested_at >= '2025-01-01'
      AND ce.requested_at < '2025-01-02'
  );

-- Q6: average charge above 50 kWh, considering outlets above 68 kW.
SELECT ev.model_name, ev.model_year, co.company_name,
       ROUND(AVG(ce.kwh), 2) AS rounded_average_kwh
FROM charging_event AS ce
JOIN electric_vehicle AS ev ON ev.vin = ce.vin
JOIN outlet AS o ON o.station_id = ce.station_id AND o.outlet_number = ce.outlet_number
JOIN company AS co ON co.abn = ev.abn
WHERE o.charging_rate > 68 AND ce.kwh IS NOT NULL
GROUP BY ev.model_name, ev.model_year, co.abn, co.company_name
HAVING AVG(ce.kwh) > 50;

-- Q7: root manufacturer and children/grandchildren, as specified.
SELECT COUNT(*) AS total_number_manufactured
FROM electric_vehicle AS ev
WHERE ev.abn = '1'
   OR ev.abn IN (SELECT abn FROM company WHERE parent_abn = '1')
   OR ev.abn IN (SELECT child.abn FROM company AS child
                JOIN company AS parent ON parent.abn = child.parent_abn
                WHERE parent.parent_abn = '1');

-- Q8: at least one charge, but none by the registered owner. NULL kWh still counts.
SELECT ev.vin FROM electric_vehicle AS ev
WHERE EXISTS (SELECT 1 FROM charging_event AS ce WHERE ce.vin = ev.vin)
  AND NOT EXISTS (SELECT 1 FROM charging_event AS ce
                  WHERE ce.vin = ev.vin AND ce.license_num = ev.license_num);

-- Q9: existing person/car charging pairs covering every qualifying outlet.
-- For an empty set of qualifying outlets, existing pairs satisfy universal coverage.
SELECT DISTINCT candidate.license_num, candidate.vin
FROM charging_event AS candidate
JOIN electric_vehicle AS ev ON ev.vin = candidate.vin
WHERE NOT EXISTS (
    SELECT 1 FROM outlet AS o
    JOIN charging_station AS cs ON cs.station_id = o.station_id
    JOIN company_owns_station AS cos ON cos.station_id = cs.station_id
    WHERE cos.abn = ev.abn AND cs.postcode >= '3000' AND cs.postcode < '4000'
      AND NOT EXISTS (
        SELECT 1 FROM charging_event AS done
        WHERE done.license_num = candidate.license_num AND done.vin = candidate.vin
          AND done.station_id = o.station_id AND done.outlet_number = o.outlet_number
      )
);

-- Q10: the source explicitly defines coupon.discount as the payable multiplier.
SELECT ROUND(SUM(ce.kwh * o.price_kwh * COALESCE(c.discount, 1)), 2) AS total_income
FROM charging_event AS ce
JOIN outlet AS o ON o.station_id = ce.station_id AND o.outlet_number = ce.outlet_number
JOIN charging_station AS cs ON cs.station_id = ce.station_id
LEFT JOIN coupon AS c ON c.coupon_id = ce.coupon_id
WHERE o.outlet_number = 2 AND cs.street = '125 Collins Street' AND cs.postcode = '3000'
  AND ce.requested_at >= '2025-01-01' AND ce.requested_at < '2025-02-01';
