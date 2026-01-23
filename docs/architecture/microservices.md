#  FrostByte Microservice Architecture

## Overview
To ensure scalability and fault isolation, the system is decomposed into three autonomous microservices. This separation ensures that complex validation logic does not block simple CRUD operations, and high-volume data (Demands) is separated from static infrastructure data (Routes/Locations).

## 1. Infrastructure Service 
**Responsibility:** The "Source of Truth" for the physical logistics network. It manages the static and semi-static entities.
* **Database Scope:** `locations`, `products`, `storage_units`, `routes`
* **Why:** These entities represent the physical graph of the network.

| API Endpoint | Method | Responsibility |
| :--- | :--- | :--- |
| `/locations` | POST, GET | Manage physical nodes (Warehouses, Hospitals, etc). |
| `/products` | POST, GET | Define catalog items and their temp constraints. |
| `/storage-units` | POST, GET | Manage capacity and temp capability at Warehouses. |
| `/routes` | POST, GET | Define the edges of the graph (connections & constraints). |
| `/network/summary` | GET | Aggregates the full graph state for analytics. |

## 2. Demand Service 
**Responsibility:** Manages the dynamic influx of delivery requirements. It captures client intent before validation.
* **Database Scope:** `demands`
* **Why:** Demands are high-volume, transactional data. Decoupling them prevents "Order Storms" from slowing down the route management system.

| API Endpoint | Method | Responsibility |
| :--- | :--- | :--- |
| `/demands` | POST | Register a new delivery requirement for a specific date. |
| `/demands` | GET | Retrieve list of active demands. |

## 3. Feasibility Engine (The Validator) 🛡️
**Responsibility:** A high-performance, stateless computation engine. It strictly enforces safety and reliability constraints.
* **Database Scope:** None (Stateless). It fetches data from Infrastructure and Demand services to perform calculations.
* **Why:** Validation is CPU-intensive. Isolating it allows us to scale the "Brain" of the system independently from the "Storage."

| API Endpoint | Method | Responsibility |
| :--- | :--- | :--- |
| `/temps/validate` | POST | **Temperature Check:** Verifies if products fit storage unit temp ranges. |
| `/network/validate` | POST | **Capacity Check:** Verifies route min/max limits and storage capacity. |

---

## 🔄 Service Communication Flow (Example: Validation)

1.  **Client** sends a request to `POST /network/validate`.
2.  **Feasibility Engine** calls **Demand Service** to get all `demands` for that date.
3.  **Feasibility Engine** calls **Infrastructure Service** to build the graph (Routes + Storage capacities).
4.  **Feasibility Engine** runs the Max Flow / Constraint algorithms.
5.  **Response** is returned to the client: `{"feasible": false, "issues": ["MAX_CAPACITY_VIOLATION"]}`.