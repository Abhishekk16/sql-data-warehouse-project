/*
========================================================================================
Store Procedure: Load Silver Layer (Bronze >> Silver)
========================================================================================
========================================================================================
Usages Example: Exec silver.load_silver
========================================================================================
/*

-----------------------------------------------------------------------------
--CREATING STORE PROCEDURE
-----------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE silver.load_silver
AS
BEGIN
	-----------------------------------------------------------------------------
	-----------------------------------------------------------------------------
	--INSERT CLEAN CRM_CUST_INFO TO SILVER
	-----------------------------------------------------------------------------
	-----------------------------------------------------------------------------
	TRUNCATE TABLE silver.crm_cust_info;
	INSERT INTO silver.crm_cust_info (
		cst_id,
		cst_key,
		cst_firstname,
		cst_lastname,
		cst_material_status,
		cst_gndr,
		cst_create_date)

	SELECT
		cst_id,
		cst_key,
		TRIM(cst_firstname) AS cst_firstname,
		TRIM(cst_lastname) AS cst_lastname,
		CASE WHEN cst_material_status = 'S' THEN 'Single'
			WHEN cst_material_status = 'M' THEN 'Married'
			ELSE 'n/a'
			END cst_material_status,
		CASE WHEN cst_gndr = 'M' THEN 'Male'
			WHEN cst_gndr = 'F' THEN 'Female'
			ELSE 'n/a'
		END cst_gndr,
		cst_create_date
	FROM (
		SELECT
			*,
			ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
		FROM
			bronze.crm_cust_info
		WHERE cst_id IS NOT NULL
		)t
	WHERE flag_last = 1

	-----------------------------------------------------------------------------
	-----------------------------------------------------------------------------
	--INSERT CLEAN CRM_PRD_INFO TO SILVER
	-----------------------------------------------------------------------------
	-----------------------------------------------------------------------------

	TRUNCATE TABLE silver.crm_prd_info;
	INSERT INTO silver.crm_prd_info (
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
		REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
		SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,
		prd_nm,
		ISNULL(prd_cost, 0) AS prd_cost,
		CASE WHEN prd_line = 'M' THEN 'Mountain'
			WHEN prd_line = 'R' THEN 'Rail'
			WHEN prd_line = 'S' THEN 'Super Sale'
			WHEN prd_line = 'T' THEN 'training'
		ELSE 'n/a' 
		END AS prd_line,
		CAST (prd_start_dt AS DATE) AS prd_start_dt,
		CAST (prd_end_dt AS DATE) AS prd_end_dt
	FROM
		bronze.crm_prd_info



	-----------------------------------------------------------------------------
	-----------------------------------------------------------------------------
	--INSERT CLEAN CRM_SALES_DETAILS TO SILVER
	-----------------------------------------------------------------------------
	-----------------------------------------------------------------------------

	--SELECT
	--	*
	--FROM
	--	bronze.crm_sales_details


	TRUNCATE TABLE silver.crm_sales_details;
	INSERT INTO silver.crm_sales_details (
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
		CASE WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
			ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
		END AS sls_order_dt,
		CASE WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
			ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
		END AS sls_ship_dt,
		CASE WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
			ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
		END AS sls_due_dt,
		CASE WHEN sls_sales IS NULL OR sls_sales <=0 OR sls_sales != sls_quantity * ABS(sls_price)
			THEN sls_quantity * ABS(sls_price)
			ELSE sls_sales
		END AS sls_sales,	
			sls_quantity,
		CASE WHEN sls_price IS NULL OR sls_price <=0
			THEN sls_sales / NULLIF(sls_quantity,0)
			ELSE sls_price
		END AS sls_price
	FROM
		bronze.crm_sales_details


	--CHECK SALES = QUANTITY * PRICE
	-- VALUES MUST NOT BE ZERO, NULL OR NEGATIVE

	--		SELECT DISTINCT
	--			sls_sales,
	--				sls_quantity,
	--				sls_price
	--			FROM
	--				bronze.crm_sales_details
	--			WHERE
	--				sls_sales != sls_quantity * sls_price
	--				OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
	--				OR sls_sales <=0 OR sls_quantity <=0 OR sls_price <=0


	-----------------------------------------------------------------------------
	-----------------------------------------------------------------------------
	--INSERT CLEAN ERP_CUST_AZ12 TO SILVER
	-----------------------------------------------------------------------------
	-----------------------------------------------------------------------------


	TRUNCATE TABLE silver.erp_cust_az12;
	INSERT INTO silver.erp_cust_az12 (
		cid,
		bdate,
		gen
	)
	SELECT
		CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
			ELSE cid
		END AS cid,
		CASE WHEN bdate > GETDATE() THEN NULL
			ELSE bdate
		END AS bdate,
		CASE WHEN UPPER(TRIM(gen)) IN ('F', 'Female') THEN 'Female'
			WHEN UPPER(TRIM(gen)) IN ('F', 'Male') THEN 'Male'
			ELSE 'n/a'
		END AS gen
	FROM
		bronze.erp_cust_az12


	-----------------------------------------------------------------------------
	-----------------------------------------------------------------------------
	--INSERT CLEAN ERP_CUST_AZ12 TO SILVER
	-----------------------------------------------------------------------------
	-----------------------------------------------------------------------------
	TRUNCATE TABLE silver.erp_loc_a101;
	INSERT INTO silver.erp_loc_a101 (
	cid, cntry)
	SELECT
	REPLACE(cid, '-', '') cid,
	CASE WHEN TRIM(cntry) = 'DE' THEN 'Germany'
		WHEN TRIM(cntry) IN ('USA', 'US') THEN 'United State'
		WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
		ELSE TRIM(cntry)
	END AS cntry
	FROM bronze.erp_loc_a101


	-----------------------------------------------------------------------------
	-----------------------------------------------------------------------------
	--INSERT CLEAN ERP_PX_CAT_G1V2 TO SILVER
	-----------------------------------------------------------------------------
	-----------------------------------------------------------------------------
	TRUNCATE TABLE silver.erp_px_cat_g1v2;
	INSERT INTO silver.erp_px_cat_g1v2 (
		id,
		cat,
		subcat,
		maintenance)

	SELECT
		id,
		cat,
		subcat,
		maintenance
	FROM bronze.erp_px_cat_g1v2

END


exec silver.load_silver
