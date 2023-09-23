CREATE TABLE IF NOT EXISTS src.StateSettingsNyRoomRate (
	  OdsPostingGroupAuditId NUMBER(10, 0) NOT NULL
	 , OdsCustomerId NUMBER(10, 0) NOT NULL
	 , OdsCreateDate DATETIME NOT NULL
	 , OdsSnapshotDate DATETIME NOT NULL
	 , OdsRowIsCurrent INT NOT NULL
	 , OdsHashbytesValue BINARY(8000) NULL
	 , DmlOperation VARCHAR(1) NOT NULL
	 , StateSettingsNyRoomRateId NUMBER(10, 0) NOT NULL
	 , StartDate DATETIME NULL
	 , EndDate DATETIME NULL
	 , RoomRate NUMBER(19, 4) NULL
);

