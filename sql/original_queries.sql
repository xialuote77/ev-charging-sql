-- Original submitted queries, identifiers and assessment wrapper removed.

-- Q1
SELECT model_name, model_year, battery_capacity
FROM electric_vehicle AS vehicle
WHERE battery_capacity = ( SELECT MAX(battery_capacity)
						   FROM electric_vehicle);

-- Q2
SELECT cs.station_id, cs.state, cs.postcode
FROM charging_station AS cs
	INNER JOIN outlet on cs.station_id = outlet.station_id
WHERE charging_rate > 100
GROUP BY cs.station_id, cs.state, cs.postcode
ORDER BY cs.station_id;

-- Q3
SELECT cs.station_id
FROM charging_station AS cs
	LEFT JOIN facility ON cs.station_id = facility.station_id
WHERE facility_id IS NULL
ORDER BY cs.station_id;

-- Q4
SELECT person.license_num, person_name, COUNT(ev.vin) AS total_num_of_cars_with_no_charge_event_registered_to_person
FROM person NATURAL JOIN electric_vehicle AS ev
	LEFT JOIN charging_event AS ce ON ev.vin = ce.vin
WHERE ce.vin IS NULL
GROUP BY person.license_num, person_name
ORDER BY person_name ASC;

-- Q5
SELECT facility_id
FROM facility NATURAL JOIN coupon
WHERE facility_id NOT IN (SELECT facility_id
						  FROM facility NATURAL JOIN coupon
							INNER JOIN charging_event AS ce ON coupon.coupon_id = ce.coupon_id
                          WHERE ce.requested_at = '2025-01-01'
                          )
GROUP BY facility_id;

-- Q6
SELECT model_name, model_year, company_name, ROUND(AVG(ce.kwh), 2)AS rounded_average_kwh
FROM charging_event as ce
	INNER JOIN electric_vehicle AS ev ON ce.vin = ev.vin
    INNER JOIN outlet ON ce.station_id = outlet.station_id
					  AND ce.outlet_number = outlet.outlet_number
	INNER JOIN company ON ev.abn = company.abn
WHERE charging_rate > 68 AND ce.kwh IS NOT NULL
GROUP BY ev.model_name, ev.model_year, company_name
HAVING AVG(ce.kwh > 50);

-- Q7
SELECT COUNT(*) AS total_number_manufactured
FROM electric_vehicle as ev
WHERE abn = 1 
	OR abn IN (SELECT abn
			   FROM company
               WHERE parent_abn = 1
				OR parent_abn IN (SELECT abn
								  FROM company
                                  WHERE parent_abn = 1
                                  )
			);

-- Q8
SELECT ev.vin
FROM electric_vehicle as ev
	INNER JOIN charging_event AS ce ON ev.vin = ce.vin
WHERE ce.license_num != ev.license_num
	AND ev.vin NOT IN (SELECT ev_.vin
					   FROM electric_vehicle AS ev_
							INNER JOIN charging_event AS ce_ ON ev_.vin = ce_.vin
							WHERE ce_.license_num = ev_.license_num
                            )
GROUP BY ev.vin;

-- Q9
SELECT DISTINCT ce.license_num, ce.vin
FROM charging_event AS ce
WHERE (ce.license_num, ce.vin) NOT IN (
	SELECT license_num, vin
    FROM (
		SELECT DISTINCT ce.license_num, ce.vin, outlet.station_id, outlet.outlet_number
        FROM charging_event AS ce
			INNER JOIN electric_vehicle AS ev ON ev.vin = ce.vin
            INNER JOIN company_owns_station AS cos ON ev.abn = cos.abn
            INNER JOIN charging_station AS cs ON cos.station_id = cs.station_id
            INNER JOIN outlet ON cs.station_id = outlet.station_id
		WHERE cs.postcode >= 3000 And cs.postcode < 4000
			AND (ce.license_num, ce.vin,outlet.station_id, outlet.outlet_number) NOT IN (
				SELECT license_num, vin, station_id, outlet_number
                FROM charging_event
                )
            ) AS missing
);

-- Q10
SELECT ROUND(SUM(
	ce.kwh * o.price_kwh * 
    CASE
		WHEN c.discount IS NULL THEN 1
        ELSE c.discount
		END
        ), 2) AS total_income
FROM charging_event AS ce
	INNER JOIN outlet AS o ON ce.station_id = o.station_id AND ce.outlet_number = o.outlet_number 
    INNER JOIN charging_station AS cs ON ce.station_id = cs.station_id
    LEFT JOIN coupon AS c ON ce.coupon_id = c.coupon_id
WHERE o.outlet_number = 2
	AND cs.street = '125 Collins Street'
	AND cs.postcode = 3000
    AND ce.requested_at >= '2025-01-01'
    AND ce.requested_at < '2025-02-01';
;