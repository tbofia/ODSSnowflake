CALL ADM.DROP_OBJECT('drop','view','dbo','DIM_CLAIM_DETAIL_BILLLINE_SOJ_COMPANY_OFFICE_CUSTOMERNAME'); -- Remove old materialized view, if it's sitting around

CREATE OR REPLACE VIEW DBO.DIM_CLAIM_DETAIL_BILLLINE_SOJ_COMPANY_OFFICE_CUSTOMERNAME
AS
SELECT DISTINCT SOJ, COMPANY_ID,COMPANY, OFFICE_ID,OFFICE, ODS_CUSTOMER_ID, CUSTOMER_NAME
FROM DBO.CLAIM_DETAIL_BILLLINE
WHERE SOJ IS NOT NULL;