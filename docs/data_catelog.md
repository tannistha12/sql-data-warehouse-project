# Gold Layer Data Catalog

---

## Overview

The Gold layer represents the final, business-ready data model within the Data Warehouse. It is designed to support analytical queries, reporting, and dashboarding by providing clean, structured, and meaningful datasets.

### Purpose
This layer transforms curated Silver data into well-defined business entities such as customers, products, and sales. It simplifies data access for analysts and decision-makers.

### Data Model
The Gold layer follows a **dimensional modeling (star schema)** approach:

- **Dimension Tables** → Descriptive data (Customers, Products)
- **Fact Tables** → Measurable events (Sales)

### Design Principles
- Data is fully cleaned and standardized
- Business rules are applied consistently
- Surrogate keys ensure stable joins
- Optimized for analytical workloads

### Outcome
The Gold layer acts as the **single source of truth**, enabling:
- Faster queries
- Reliable reporting
- Scalable analytics

---

## 1. gold_dim_customers

### Purpose
Stores enriched customer information by combining CRM and ERP data, including demographic and geographic attributes. Used for customer-level analytics and segmentation.

| Column Name        | Data Type     | Description |
|--------------------|--------------|-------------|
| customer_key       | INT          | Surrogate key uniquely identifying each customer record. |
| customer_id        | INT          | Unique identifier from CRM system. |
| customer_number    | VARCHAR(50)  | Business identifier for the customer. |
| first_name         | VARCHAR(50)  | Customer’s first name. |
| last_name          | VARCHAR(50)  | Customer’s last name. |
| country            | VARCHAR(50)  | Standardized country name. |
| marital_status     | VARCHAR(50)  | Customer’s marital status (e.g., Single, Married). |
| gender             | VARCHAR(50)  | Standardized gender (Male, Female, n/a). |
| birthdate          | DATE         | Customer’s date of birth. |
| create_date        | DATE         | Record creation date. |

---

## 2. gold_dim_products

### Purpose
Provides standardized product information with categorization and pricing details. Enables product-level analysis.

| Column Name     | Data Type     | Description |
|----------------|--------------|-------------|
| product_key     | INT          | Surrogate key for each product. |
| product_id      | INT          | Unique identifier from source system. |
| product_number  | VARCHAR(50)  | Business product code. |
| product_name    | VARCHAR(100) | Name of the product. |
| category_id     | VARCHAR(50)  | Derived category identifier. |
| category        | VARCHAR(50)  | Product category. |
| subcategory     | VARCHAR(50)  | Product subcategory. |
| cost            | INT          | Product cost. |
| product_line    | VARCHAR(50)  | Standardized product line. |
| start_date      | DATE         | Product start date. |
| end_date        | DATE         | Product end date. |

---

## 3. gold_fact_sales

### Purpose
Captures transactional sales data linking customers and products. Core table for revenue and performance analysis.

| Column Name     | Data Type     | Description |
|----------------|--------------|-------------|
| order_number    | VARCHAR(50)  | Unique order identifier. |
| product_key     | INT          | Foreign key to product dimension. |
| customer_key    | INT          | Foreign key to customer dimension. |
| order_date      | DATE         | Order date. |
| ship_date       | DATE         | Shipping date. |
| due_date        | DATE         | Expected delivery date. |
| sales_amount    | INT          | Total sales value. |
| quantity        | INT          | Quantity sold. |
| price           | INT          | Price per unit. |

---

