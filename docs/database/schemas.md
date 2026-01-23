# FrostByte Logistics – Database Schema Documentation

This document describes the database schema used for the FrostByte Logistics platform.
The schema is designed to support validation of delivery feasibility based on
location connectivity, temperature compatibility, storage capacity, and demand constraints.

---

## 1. locations

Stores all physical locations in the logistics network such as warehouses and client sites.

| COLUMN_NAME | DATA_TYPE     | NULLABLE | DATA_DEFAULT        | CONSTRAINTS        | COMMENTS |
|------------|---------------|----------|---------------------|--------------------|----------|
| id         | UUID          | No       | uuid_generate_v4()  | PRIMARY KEY        | Unique identifier for each location. |
| name       | VARCHAR(100)  | No       | null                | —                  | Name of the location. |
| type       | VARCHAR(50)   | No       | null                | —                  | Type of location (Warehouse, Hospital, Retailer, etc.). |
| city       | VARCHAR(100)  | No       | null                | —                  | City where the location is situated. |

### Purpose
Represents all nodes in the logistics network.  
Locations act as sources, transit points, and destinations for shipments.

---

## 2. products

Stores all products that can be transported through the logistics network.

| COLUMN_NAME      | DATA_TYPE | NULLABLE | DATA_DEFAULT       | CONSTRAINTS | COMMENTS |
|------------------|-----------|----------|--------------------|-------------|----------|
| id               | UUID      | No       | uuid_generate_v4() | PRIMARY KEY | Unique identifier for each product. |
| name             | VARCHAR(100) | No    | null               | —           | Name of the product. |
| min_temperature  | INTEGER   | No       | null               | —           | Minimum temperature required for safe transport. |
| max_temperature  | INTEGER   | No       | null               | —           | Maximum temperature allowed for safe transport. |

### Purpose
Defines the temperature requirements for each product.  
Used to ensure products are only stored and transported in compatible environments.

---

## 3. storage_units

Stores cold-storage units available at each location.

| COLUMN_NAME      | DATA_TYPE | NULLABLE | DATA_DEFAULT       | CONSTRAINTS | COMMENTS |
|------------------|-----------|----------|--------------------|-------------|----------|
| id               | UUID      | No       | uuid_generate_v4() | PRIMARY KEY | Unique identifier for the storage unit. |
| location_id      | UUID      | No       | null               | FK → locations(id) | Location where the storage unit exists. |
| min_temperature  | INTEGER   | No       | null               | —           | Minimum temperature supported by this storage unit. |
| max_temperature  | INTEGER   | No       | null               | —           | Maximum temperature supported by this storage unit. |
| capacity         | INTEGER   | No       | null               | CHECK (capacity ≥ 0) | Maximum quantity the unit can store. |

### Purpose
Represents cold-storage facilities at locations.  
Used to ensure products can be safely stored without exceeding capacity limits.

---

## 4. routes

Stores transportation routes between two locations.

| COLUMN_NAME        | DATA_TYPE | NULLABLE | DATA_DEFAULT       | CONSTRAINTS | COMMENTS |
|--------------------|-----------|----------|--------------------|-------------|----------|
| id                 | UUID      | No       | uuid_generate_v4() | PRIMARY KEY | Unique identifier for the route. |
| from_location_id   | UUID      | No       | null               | FK → locations(id) | Starting location of the route. |
| to_location_id     | UUID      | No       | null               | FK → locations(id) | Ending location of the route. |
| capacity           | INTEGER   | No       | null               | CHECK (capacity ≥ 0) | Maximum shipment capacity on this route. |
| min_shipment       | INTEGER   | No       | 0                  | —           | Minimum shipment quantity required on this route. |

### Purpose
Defines how goods can move between locations.  
Used to validate whether routes can handle required shipment quantities.

---

## 5. demands

Stores product demand requirements for locations on specific dates.

| COLUMN_NAME   | DATA_TYPE | NULLABLE | DATA_DEFAULT       | CONSTRAINTS | COMMENTS |
|---------------|-----------|----------|--------------------|-------------|----------|
| id            | UUID      | No       | uuid_generate_v4() | PRIMARY KEY | Unique identifier for the demand record. |
| location_id   | UUID      | No       | null               | FK → locations(id) | Location requesting the product. |
| product_id    | UUID      | No       | null               | FK → products(id) | Product being requested. |
| date          | DATE      | No       | null               | —           | Date on which the demand applies. |
| min_quantity  | INTEGER   | No       | 1                  | —           | Minimum quantity that must be delivered. |
| max_quantity  | INTEGER   | No       | null               | —           | Maximum quantity that can be delivered. |

### Purpose
Represents delivery requirements for products at specific locations and dates.  
Used as the demand input when validating whether a delivery plan is feasible.

---

## Relationship Summary

- **locations** are referenced by:
  - `storage_units`
  - `routes`
  - `demands`
- **products** are referenced by:
  - `demands`
- **storage_units** define storage constraints per location
- **routes** define transport constraints between locations
- **demands** define minimum and maximum delivery requirements

---

This schema allows the system to evaluate whether delivery demands can be satisfied
without violating storage, routing, or temperature constraints, enabling safe refusal
of infeasible delivery plans.
