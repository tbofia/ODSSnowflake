SET AppVer='1.1.0.0';

INSERT INTO ADM.APP_VERSION(APP_VERSION, APP_VERSION_DATE) 
VALUES ($AppVer, CURRENT_TIMESTAMP::TIMESTAMP_NTZ);

