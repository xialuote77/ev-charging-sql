-- Schema only, from supplied MySQL coursework database. No original INSERT records included.
-- Run in an empty disposable schema, not against production data.
SET FOREIGN_KEY_CHECKS=0;

CREATE TABLE `charging_event` (
  `charge_event_id` int NOT NULL AUTO_INCREMENT,
  `requested_at` datetime NOT NULL,
  `vin` varchar(25) NOT NULL,
  `license_num` varchar(10) NOT NULL,
  `station_id` int NOT NULL,
  `outlet_number` int DEFAULT NULL,
  `coupon_id` int DEFAULT NULL,
  `kwh` float DEFAULT NULL,
  `charge_started_at` datetime DEFAULT NULL,
  PRIMARY KEY (`charge_event_id`),
  KEY `fk_electric_vehicle_has_charging_outlet_charging_outlet1_idx` (`outlet_number`,`station_id`),
  KEY `fk_electric_vehicle_has_charging_outlet_electric_vehicle1_idx` (`vin`),
  KEY `fk_electric_vehicle_has_charging_outlet_coupon1_idx` (`coupon_id`),
  KEY `fk_charging_event_person1_idx` (`license_num`),
  KEY `fk_charging_event_charging_station1_idx` (`station_id`),
  CONSTRAINT `fk_charging_event_charging_station1` FOREIGN KEY (`station_id`) REFERENCES `charging_station` (`station_id`),
  CONSTRAINT `fk_charging_event_person1` FOREIGN KEY (`license_num`) REFERENCES `person` (`license_num`),
  CONSTRAINT `fk_electric_vehicle_has_charging_outlet_charging_outlet1` FOREIGN KEY (`outlet_number`, `station_id`) REFERENCES `outlet` (`outlet_number`, `station_id`),
  CONSTRAINT `fk_electric_vehicle_has_charging_outlet_coupon1` FOREIGN KEY (`coupon_id`) REFERENCES `coupon` (`coupon_id`),
  CONSTRAINT `fk_electric_vehicle_has_charging_outlet_electric_vehicle1` FOREIGN KEY (`vin`) REFERENCES `electric_vehicle` (`vin`)
) ENGINE=InnoDB AUTO_INCREMENT=532 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `charging_station` (
  `station_id` int NOT NULL,
  `street` varchar(50) NOT NULL,
  `suburb` varchar(20) NOT NULL,
  `state` varchar(3) NOT NULL,
  `postcode` varchar(4) NOT NULL,
  `establishment_date` date NOT NULL,
  PRIMARY KEY (`station_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `company` (
  `abn` char(11) NOT NULL,
  `company_name` varchar(250) NOT NULL,
  `ceo_name` varchar(100) NOT NULL,
  `parent_abn` char(11) DEFAULT NULL,
  PRIMARY KEY (`abn`),
  KEY `fk_manufacturer_company_manufacturer_company1_idx` (`parent_abn`),
  CONSTRAINT `fk_manufacturer_company_manufacturer_company1` FOREIGN KEY (`parent_abn`) REFERENCES `company` (`abn`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `company_owns_station` (
  `abn` char(11) NOT NULL,
  `station_id` int NOT NULL,
  PRIMARY KEY (`abn`,`station_id`),
  KEY `fk_manufacturer_company_has_charging_station_charging_stati_idx` (`station_id`),
  KEY `fk_manufacturer_company_has_charging_station_manufacturer_c_idx` (`abn`),
  CONSTRAINT `fk_manufacturer_company_has_charging_station_charging_station1` FOREIGN KEY (`station_id`) REFERENCES `charging_station` (`station_id`),
  CONSTRAINT `fk_manufacturer_company_has_charging_station_manufacturer_com1` FOREIGN KEY (`abn`) REFERENCES `company` (`abn`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `coupon` (
  `coupon_id` int NOT NULL,
  `facility_id` int NOT NULL,
  `discount` float NOT NULL,
  PRIMARY KEY (`coupon_id`),
  KEY `fk_coupon_facility1_idx` (`facility_id`),
  CONSTRAINT `fk_coupon_facility1` FOREIGN KEY (`facility_id`) REFERENCES `facility` (`facility_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `electric_vehicle` (
  `vin` varchar(25) NOT NULL,
  `abn` char(11) NOT NULL,
  `license_num` varchar(10) NOT NULL,
  `model_name` varchar(250) NOT NULL,
  `model_year` year NOT NULL,
  `battery_capacity` int unsigned NOT NULL,
  PRIMARY KEY (`vin`),
  KEY `fk_electric_vehicle_manufacturer_company1_idx` (`abn`),
  KEY `fk_electric_vehicle_person1_idx` (`license_num`),
  CONSTRAINT `fk_electric_vehicle_manufacturer_company1` FOREIGN KEY (`abn`) REFERENCES `company` (`abn`),
  CONSTRAINT `fk_electric_vehicle_person1` FOREIGN KEY (`license_num`) REFERENCES `person` (`license_num`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `facility` (
  `facility_id` int NOT NULL,
  `station_id` int NOT NULL,
  `facility_name` varchar(50) NOT NULL,
  PRIMARY KEY (`facility_id`),
  KEY `fk_facility_charging_station1_idx` (`station_id`),
  CONSTRAINT `fk_facility_charging_station1` FOREIGN KEY (`station_id`) REFERENCES `charging_station` (`station_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `outlet` (
  `outlet_number` int NOT NULL,
  `station_id` int NOT NULL,
  `charging_rate` int NOT NULL,
  `price_kwh` float NOT NULL,
  PRIMARY KEY (`outlet_number`,`station_id`),
  KEY `fk_charging_outlet_charging_station1_idx` (`station_id`),
  CONSTRAINT `fk_charging_outlet_charging_station1` FOREIGN KEY (`station_id`) REFERENCES `charging_station` (`station_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `person` (
  `license_num` varchar(10) NOT NULL,
  `person_name` varchar(100) NOT NULL,
  PRIMARY KEY (`license_num`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SET FOREIGN_KEY_CHECKS=1;
