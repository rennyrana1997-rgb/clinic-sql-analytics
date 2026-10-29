# Healthcare Clinic Capacity & Patient Flow Analytics (PostgreSQL)

A relational database project simulating outpatient clinic operations to analyze patient wait times, physician workloads, and scheduling no-show trends.

## 🎯 Project Overview
- Designed a normalized schema across 4 core tables: `departments`, `providers`, `appointments`, and `clinical_encounters`.
- Investigated the operational relationship between booking lead time and patient no-show rates.
- Calculated patient bottleneck metrics (check-in to doctor examination time) using PostgreSQL date/time functions.

## 🛠️ Tech Stack
- **Database:** PostgreSQL
- **SQL Concepts Used:** Foreign Keys, Aggregations (`COUNT`, `AVG`, `ROUND`), `CASE` statements, Table Joins (`JOIN`, `LEFT JOIN`), and Timestamp Epoch math.

## 📊 Key Queries Included
1. **Lead-Time vs. No-Show Analysis:** Categorizes appointments into lead-time windows to identify patient absence risk.
2. **Clinic Wait-Time Bottlenecks:** Tracks average minutes spent in the waiting room per department.
3. **Provider Schedule Fulfillment:** Measures completed vs. scheduled patient counts per provider.