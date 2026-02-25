/*
===============================================================================
DML Script: Load Data into Bronze Layer
===============================================================================

Script Purpose:
    This script loads raw source data from CSV files into the
    corresponding Bronze layer tables.

Process Overview:
    - Each table is truncated before loading to prevent duplication.
    - Source CSV files are ingested using LOAD DATA LOCAL INFILE.
    - No transformations, cleansing, or business logic are applied.
    - Optional row-count checks are included for basic validation.
    - Batch start and end timestamps are recorded for execution tracking.

Execution Requirements:
    - Ensure 'local_infile' is enabled on the MySQL server.
    - Verify correct file paths before execution.
    - Execute the full script to maintain batch consistency.

Outcome:
    After execution, Bronze tables will contain the latest raw snapshot
    of CRM and ERP source data, ready for transformation into the Silver layer.

===============================================================================
*/

DROP PROCEDURE IF EXISTS load_bronze;

TRUNCATE TABLE bronze_crm_cust_info;
LOAD DATA LOCAL INFILE 'C:/Users/Admin/Desktop/College related/Own Projects/sql-data-warehouse-project-main/datasets/source_crm/cust_info.csv'
INTO TABLE bronze_crm_cust_info
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
SELECT COUNT(*) FROM bronze_crm_cust_info;
SELECT * FROM bronze_crm_cust_info;

TRUNCATE TABLE bronze_crm_prd_info;
LOAD DATA LOCAL INFILE 'C:/Users/Admin/Desktop/College related/Own Projects/sql-data-warehouse-project-main/datasets/source_crm/prd_info.csv'
INTO TABLE bronze_crm_prd_info
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
SELECT COUNT(*) FROM bronze_crm_prd_info;
SELECT * FROM bronze_crm_prd_info;

TRUNCATE TABLE bronze_crm_sales_details;
LOAD DATA LOCAL INFILE 'C:/Users/Admin/Desktop/College related/Own Projects/sql-data-warehouse-project-main/datasets/source_crm/sales_details.csv'
INTO TABLE bronze_crm_sales_details
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
SELECT COUNT(*) FROM bronze_crm_sales_details;
SELECT * FROM bronze_crm_sales_details;

TRUNCATE TABLE bronze_erp_cust_az12;
LOAD DATA LOCAL INFILE 'C:/Users/Admin/Desktop/College related/Own Projects/sql-data-warehouse-project-main/datasets/source_erp/cust_az12.csv'
INTO TABLE bronze_erp_cust_az12
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
SELECT COUNT(*) FROM bronze_erp_cust_az12;
SELECT * FROM bronze_erp_cust_az12;

TRUNCATE TABLE bronze_erp_loc_a101;
LOAD DATA LOCAL INFILE 'C:/Users/Admin/Desktop/College related/Own Projects/sql-data-warehouse-project-main/datasets/source_erp/loc_a101.csv'
INTO TABLE bronze_erp_loc_a101
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
SELECT COUNT(*) FROM bronze_erp_loc_a101;
SELECT * FROM bronze_erp_loc_a101;

TRUNCATE TABLE bronze_erp_px_cat_g1v2;
LOAD DATA LOCAL INFILE 'C:/Users/Admin/Desktop/College related/Own Projects/sql-data-warehouse-project-main/datasets/source_erp/px_cat_g1v2.csv'
INTO TABLE bronze_erp_px_cat_g1v2
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
SELECT COUNT(*) FROM bronze_erp_px_cat_g1v2;
SELECT * FROM bronze_erp_px_cat_g1v2;

SET @batch_end = NOW();

SELECT
'Bronze Load Completed' AS status,
@batch_end AS end_time,
TIMESTAMPDIFF(SECOND, @batch_start, @batch_end) AS total_duration_seconds;
