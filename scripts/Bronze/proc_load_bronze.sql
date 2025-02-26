/*
===============================================================
Store Procedure: Load Bronze Layer (source{CSV} >> Bronze)
===============================================================
*/



CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	PRINT '===================================================';
	PRINT 'LOADING BRONZE LAYER';
	PRINT '===================================================';

	PRINT '---------------------------------------------------';
	PRINT 'LOADING CRM TABLES';
	PRINT '---------------------------------------------------';

	PRINT 'TRUNCATING TABLE: bronze.crm_cust_info';
	TRUNCATE TABLE bronze.crm_cust_info
	PRINT 'INSERTING TABLE: bronze.crm_cust_info';
	BULK INSERT bronze.crm_cust_info
	FROM 'C:\Users\abhij\Downloads\source_crm\cust_info.csv'
	WITH (
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK
	);

	PRINT 'TRUNCATING TABLE: crm_sales_details';
	TRUNCATE TABLE bronze.crm_sales_details
	PRINT 'INSERTING TABLE: bronze.crm_sales_details';
	BULK INSERT bronze.crm_sales_details
	FROM 'C:\Users\abhij\Downloads\source_crm\sales_details.csv'
	WITH (
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK
	);


	PRINT 'TRUNCATING TABLE: crm_prd_info';
	TRUNCATE TABLE bronze.crm_prd_info
	PRINT 'INSERTING TABLE: bronze.crm_prd_info';
	BULK INSERT bronze.crm_prd_info
	FROM 'C:\Users\abhij\Downloads\source_crm\prd_info.csv'
	WITH (
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK
	);

	PRINT '---------------------------------------------------';
	PRINT 'LOADING ERP TABLES';
	PRINT '---------------------------------------------------';

	PRINT 'TRUNCATING TABLE: erp_px_cat_g1v2';
	TRUNCATE TABLE bronze.erp_px_cat_g1v2
	PRINT 'INSERTING TABLE: bronze.erp_px_cat_g1v2';
	BULK INSERT bronze.erp_px_cat_g1v2
	FROM 'C:\Users\abhij\Downloads\source_erp\px_cat_g1v2.csv'
	WITH (
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK
	);


	PRINT 'TRUNCATING TABLE: erp_cust_az12';
	TRUNCATE TABLE bronze.erp_cust_az12
	PRINT 'INSERTING TABLE: bronze.erp_cust_az12';
	BULK INSERT bronze.erp_cust_az12
	FROM 'C:\Users\abhij\Downloads\source_erp\cust_az12.csv'
	WITH (
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK
	);


	PRINT 'TRUNCATING TABLE: erp_loc_a101';
	TRUNCATE TABLE bronze.erp_loc_a101
	PRINT 'INSERTING TABLE: bronze.erp_loc_a101';
	BULK INSERT bronze.erp_loc_a101
	FROM 'C:\Users\abhij\Downloads\source_erp\loc_a101.csv'
	WITH (
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK
	);

END


EXEC bronze.load_bronze



