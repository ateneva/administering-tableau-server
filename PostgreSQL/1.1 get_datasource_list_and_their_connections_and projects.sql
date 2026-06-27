SELECT
	ds.site_id                 AS siteid,
	ds.project_id              AS projectid,
	prj.name                   AS projectname,
	ds.id                      AS datasourceid,
	ds.name                    AS datasourcename,

	-- About description added to TableauServer
	ds.description             AS aboutnote,

	-- when the datasource was first published to TableauServer
	ds.first_published_at      AS datasourcefirstpublishedon,

	-- when the datasource was last re-published on TableauServer
	ds.last_published_at       AS datasourcelastpublishedon,

	-- TRUE/FALSE indicator showing if extracts were set or not
	ds.refreshable_extracts    AS refreshableextracts,

	-- TREU/FALSE indocator showing if extracts are incremented or not
	ds.incrementable_extracts  AS incrementableextracts,

	-- timestamp of the last full refresh
	ds.extracts_refreshed_at   AS lastfullextractrefreshedon,

	-- timestamp of the last incremental refresh
	ds.extracts_incremented_at AS lastincrementedextracton,

	-- TRUE/FALSE indicator showing if the dataset is certified or not
	ds.is_certified            AS iscertified,

	-- display name of the Tableau User who certified it
	ds.certifier_details       AS certifiedby,
	ds.certification_note      AS certificationnote,
	-- user who last (re-)published the dataset
	sysus.name                 AS datasourceowner,
	dc.id                      AS connectionid,

	-- IP to which the connection is made;  
	--NULL in case if bigquery and empty string for Excel and google sheets
	dc.server                  AS connectionserver,

	-- e.g.qlserver, mysql, postgresql, bq, excel, google-sheets etc
	dc.dbclass                 AS connectiondatabasetype,

	-- the exact database to which the database is connected 
	-- if cross-DB connections are used, this will return more than 1 entry
	dc.dbname                  AS connectiondatabasename,
	-- e.g. Datasource, Workbook
	dc.owner_type              AS connectiontype,
	-- the credentials used to connect to the data
	dc.username                AS credentialsused,
	-- TRUE/FALSE indicator that shows if password was embedded or not
	dc.password                AS passwordembedded,
	-- the unique identifer used by the TableauServer Client API
	dc.luid                    AS connectionuniqueidentifier,
	-- timestamp of the connection creation
	dc.created_at              AS connectionfirstcreatedon,
	-- timestamp of the latest connection update
	dc.updated_at              AS connectionlastrevisedon,
	-- TRUE/FALSE indicator showing if extract is set
	dc.has_extract             AS connectionusesextract,
	-- connection friendly name - as seen in Desktop Pane
	dc.caption                 AS connectionfriendlyname

FROM public.datasources AS ds
	INNER JOIN public.data_connections AS dc
		ON ds.id = dc.datasource_id

	INNER JOIN projects AS prj
		ON ds.project_id = prj.id

	INNER JOIN public.users AS us
		ON ds.owner_id = us.id

	INNER JOIN public.system_users AS sysus
		ON us.system_user_id = sysus.id

--'Datasource' represents a published dataset;
-- 'Workbook' means embedded dataset
WHERE dc.owner_type = 'Datasource'

ORDER BY
	projectid,
	datasourcename
