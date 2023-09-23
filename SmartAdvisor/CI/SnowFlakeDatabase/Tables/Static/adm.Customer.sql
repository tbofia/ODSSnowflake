CREATE OR REPLACE TABLE adm.Customer (
	  CUSTOMER_ID NUMBER(10, 0) NOT NULL
	, CUSTOMER_NAME VARCHAR(100) NOT NULL
	, SITE_CODE VARCHAR(25) NOT NULL
	, CUSTOMER_DATABASE VARCHAR(255) NOT NULL
	, SERVER_NAME VARCHAR(255) NULL
	, IS_ACTIVE BOOLEAN NOT NULL
	, IS_SELF_HOSTED NUMBER(10, 0) NOT NULL
	, IS_FROM_SMART_ADVISOR NUMBER(10, 0) NOT NULL
	, IS_LOADED_DAILY NUMBER(10, 0) NOT NULL
	, USE_FOR_REPORTING NUMBER(10, 0) NOT NULL
	, INCLUDE_IN_INDUSTRY NUMBER(10, 0) NOT NULL
);
