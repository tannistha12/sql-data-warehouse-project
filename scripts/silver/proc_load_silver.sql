/*
===============================================================================
DML Script: Load and Transform Data into Silver Layer
===============================================================================

Script Purpose:
    This script performs data transformation and loading operations
    to populate the Silver layer tables from the Bronze layer.

Layer Description:
    The Silver layer contains cleansed, standardized, and validated data.
    This script applies transformation logic to raw Bronze data to ensure
    consistency, quality, and structural alignment with warehouse standards.

Transformation Logic Includes:
    - Removing unwanted characters and trimming whitespace.
    - Standardizing categorical values (e.g., country codes to full names).
    - Handling null, blank, or invalid records (e.g., replacing with 'n/a').
    - Enforcing consistent formatting and data types.
    - Applying basic business validation rules.

Execution Details:
    - Data is selected from Bronze tables.
    - Required transformations are applied during INSERT/UPDATE operations.
    - No structural changes occur in this script (DML only).

Outcome:
    After execution, Silver tables will contain cleaned, reliable, and
    standardized data ready for downstream consumption in the Gold layer.

===============================================================================
*/

-- removed duplicates, unwanted spaces & standardized the data
TRUNCATE TABLE silver_crm_cust_info;
INSERT INTO silver_crm_cust_info (
    cst_id,
    cst_key,
    cst_firstname,
    cst_lastname,
    cst_marital_status,
    cst_gndr,
    cst_create_date
)
SELECT 
    cst_id, 
    cst_key, 
    TRIM(cst_firstname) AS cst_firstname,
    TRIM(cst_lastname) AS cst_lastname,

    CASE 
        WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
        WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
        ELSE NULL
    END AS cst_marital_status,

    CASE 
        WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
        WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
        ELSE NULL
    END AS cst_gndr,

    CASE
        WHEN cst_create_date IS NULL
             OR YEAR(cst_create_date) = 0
        THEN NULL
        ELSE cst_create_date
    END AS cst_create_date

FROM (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY cst_id 
               ORDER BY cst_create_date DESC
           ) AS flag_last
    FROM bronze_crm_cust_info
    WHERE cst_id IS NOT NULL
      AND cst_id <> 0
) AS t
WHERE flag_last = 1;

TRUNCATE TABLE silver_crm_prd_info;
INSERT INTO silver_crm_prd_info (
    prd_id,
    cat_id,
    prd_key,
    prd_nm,
    prd_cost,
    prd_line,
    prd_start_dt,
    prd_end_dt
)
SELECT 
prd_id,
REPLACE(SUBSTRING(prd_key, 1,5),'-','_') AS cat_id, -- Extract category id
SUBSTRING(prd_key, 7,LENGTH(prd_key)) AS prd_key, -- Extract product key
prd_nm,
prd_cost,
CASE UPPER(TRIM(prd_line))
	WHEN 'M' THEN 'Mountains'
	WHEN 'R' THEN 'Roads'
    WHEN 'T' THEN 'Touring'
    WHEN 'S' THEN 'Other Sales'
	ELSE 'n/a'
END AS prd_line, -- Map product line codes into descriptive words
CAST(prd_start_dt AS DATE) AS prd_start_dt,
DATE_SUB(
    LEAD(prd_start_dt) 
    OVER (PARTITION BY prd_key ORDER BY prd_start_dt),
    INTERVAL 1 DAY
) AS prd_end_dt -- calculate end date as one day before the next start date
FROM bronze_crm_prd_info;

TRUNCATE TABLE silver_crm_sales_details;
INSERT INTO silver_crm_sales_details (
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt, 
    sls_sales,
    sls_quantity,
    sls_price
)
SELECT
sls_ord_num,
sls_prd_key,
sls_cust_id,
CASE WHEN sls_order_dt=0 OR LENGTH(sls_order_dt) != 8 THEN NULL
	 ELSE STR_TO_DATE(CAST(sls_order_dt AS CHAR), '%Y%m%d') 
END AS sls_order_dt,
CASE WHEN sls_ship_dt=0 OR LENGTH(sls_ship_dt) != 8 THEN NULL
	 ELSE STR_TO_DATE(CAST(sls_ship_dt AS CHAR), '%Y%m%d') 
END AS sls_ship_dt,
CASE WHEN sls_due_dt=0 OR LENGTH(sls_due_dt) != 8 THEN NULL
	 ELSE STR_TO_DATE(CAST(sls_due_dt AS CHAR), '%Y%m%d') 
END AS sls_due_dt,
CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
	 THEN sls_quantity * ABS(sls_price)
     ELSE sls_sales
END AS sls_sales,
sls_quantity,
CASE WHEN sls_price IS NULL OR sls_price <= 0 
	 THEN sls_sales / NULLIF(sls_quantity,0)
     ELSE sls_price
END AS sls_price
FROM bronze_crm_sales_details;

TRUNCATE TABLE silver_erp_cust_az12;
INSERT INTO silver_erp_cust_az12 (
    cid,
    bdate,
    gen
)
SELECT 
CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LENGTH(cid)) 
	 ELSE cid
END AS cid,
CASE WHEN STR_TO_DATE(bdate, '%d-%m-%y') > CURDATE() THEN NULL
	 ELSE STR_TO_DATE(bdate, '%d-%m-%y')
END AS bdate,
CASE
	WHEN gen IS NULL 
		OR TRIM(REPLACE(gen, CHAR(13), '')) = '' 
		THEN 'n/a'
	WHEN UPPER(TRIM(REPLACE(gen, CHAR(13), ''))) IN ('M','MALE') 
		THEN 'Male'
	WHEN UPPER(TRIM(REPLACE(gen, CHAR(13), ''))) IN ('F','FEMALE') 
		THEN 'Female'
	ELSE 'n/a'
END AS gen
FROM bronze_erp_cust_az12;

TRUNCATE TABLE silver_erp_loc_a101;
INSERT INTO silver_erp_loc_a101
(cid,cntry)
SELECT 
REPLACE(cid, '-','') cid, 
CASE 
	WHEN cntry IS NULL OR TRIM(REPLACE(cntry, CHAR(13), '')) = '' 
		THEN 'n/a'
	WHEN UPPER(TRIM(REPLACE(cntry, CHAR(13), ''))) IN ('US','USA') 
		THEN 'United States'
	WHEN UPPER(TRIM(REPLACE(cntry, CHAR(13), ''))) IN ('DE') 
		THEN 'Germany'
	ELSE cntry
END AS cntry
FROM bronze_erp_loc_a101;

TRUNCATE TABLE silver_erp_px_cat_g1v2;
INSERT INTO silver_erp_px_cat_g1v2
(id,cat,subcat,maintenance)
SELECT 
id,
cat,
subcat,
maintenance
FROM bronze_erp_px_cat_g1v2;

SET @batch_end = NOW();

SELECT
'Silver Load Completed' AS status,
@batch_end AS end_time,
TIMESTAMPDIFF(SECOND, @batch_start, @batch_end) AS total_duration_seconds;

SELECT * FROM silver_crm_cust_info LIMIT 10;
SELECT * FROM silver_crm_prd_info LIMIT 10;
SELECT * FROM silver_crm_sales_details LIMIT 10;
SELECT * FROM silver_erp_cust_az12 LIMIT 10;
SELECT * FROM silver_erp_loc_a101 LIMIT 10;
SELECT * FROM silver_erp_px_cat_g1v2 LIMIT 10;
