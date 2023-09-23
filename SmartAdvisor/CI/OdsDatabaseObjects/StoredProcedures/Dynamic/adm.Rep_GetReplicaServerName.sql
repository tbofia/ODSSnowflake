IF OBJECT_ID('adm.Rep_GetReplicaServerName') IS NOT NULL
    DROP PROCEDURE adm.Rep_GetReplicaServerName
GO

CREATE PROCEDURE adm.Rep_GetReplicaServerName (
@DatabaseName VARCHAR(100) = NULL)
AS
BEGIN

	-- If an AlwaysOn AG exists for this database, let's use
	-- one of the secondary replicas as the source of our
	-- data extracts.  If not, we'll just use the current server.

	SET @DatabaseName = ISNULL(@DatabaseName, DB_NAME());

    IF NOT EXISTS ( SELECT  1
                    FROM    sys.databases
                    WHERE   name = @DatabaseName )
        RAISERROR ('@DatabaseName does not exist on this server.  Aborting.', 16, 1) WITH LOG

	-- By default, use the current server
    DECLARE @ReplicaServerName SYSNAME = @@SERVERNAME;

    IF SERVERPROPERTY('IsHadrEnabled') = 1
        BEGIN
		-- Get the name of the first secondary replica (by replica_id)
            SELECT TOP 1
                    @ReplicaServerName = rcs.replica_server_name
            FROM    sys.availability_groups_cluster agc
                    INNER JOIN sys.dm_hadr_availability_replica_cluster_states rcs ON rcs.group_id = agc.group_id
                    INNER JOIN sys.dm_hadr_availability_replica_states ars ON ars.replica_id = rcs.replica_id
            WHERE   ars.role = 2 -- SECONDARY
                    AND ars.connected_state = 1 -- CONNECTED
                    AND ars.synchronization_health = 2 -- HEALTHY
			-- Make sure that this database is part of the AG cluster
                    AND EXISTS ( SELECT 1
                                 FROM   sys.dm_hadr_availability_replica_states ars1
                                        INNER JOIN sys.databases d ON ars1.replica_id = d.replica_id
                                 WHERE  d.NAME = @DatabaseName
                                        AND ars1.role = 1 -- PRIMARY
                                        AND ars.group_id = ars1.group_id )
            ORDER BY rcs.replica_id;
        END

    SELECT  @ReplicaServerName AS ReplicaServerName;
END
GO
