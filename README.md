# 📊LaunchMart Loyalty Analytics

Hey there!👋 <br/>
This repository holds all the SQL queries I wrote to tackle the LaunchMart loyalty program analysis project. LaunchMart is a growing African e-commerce company that recently launched a loyalty program to increase customer retention. <br/>
The goal was pretty clear: help the marketing folks figure out who's buying, who's sticking around, and who's about to ghost us.


## 📚 Data Setup and Environment
The analysis was performed using PostgreSQL within a Dockerized environment.

1. Database Schema
The database schema includes the following core tables:

customers: Customer master data (customer_id, full_name, join_date).

orders: Order details (order_id, customer_id, order_date, total_amount).

loyalty_points: Points earned by customers (customer_id, points_earned).

(Other tables like products, order_items were available but not used in the core reports).

The full Entity-Relationship Diagram (ERD) can be viewed in 03_launchMart_erd.png.

2. Setup Instructions
The database setup was completed by running the provided Data Definition Language (DDL) and Data Manipulation Language (DML) files:

Schema Creation: Executed the DDL statements in 01_schema.sql.

Data Seeding: Inserted sample data using 02_seed_data.sql.

## 🛠 Tools Used
* pgAdmin 4
* PostgreSQL
* Docker
