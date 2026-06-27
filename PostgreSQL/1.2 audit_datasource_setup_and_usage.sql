WITH
	ds_setup AS (
		SELECT
			ds.site_id,
			s.name                     AS site_name,
			ds.project_id,
			prj.name                   AS project_name,
			ds.id                      AS datasource_id,
			ds.name                    AS datasource_name,
			-- About description added to TableauServer
			ds.description             AS about_note,
			-- when the datasource was first published to TableauServer
			ds.first_published_at      AS datasource_first_published,
			-- when the datasource was last re-published on TableauServer
			ds.last_published_at       AS datasource_last_published,
			-- TRUE/FALSE indicator showing if extracts were set or not
			ds.refreshable_extracts    AS has_refreshable_extracts,
			-- TREU/FALSE indocator showing if extracts are incremented or not
			ds.incrementable_extracts  AS has_incrementable_extracts,
			-- timestamp of the last full refresh
			ds.extracts_refreshed_at   AS last_full_extract_refresh,
			-- timestamp of the last incremental refresh
			ds.extracts_incremented_at AS last_incremental_extract_refresh,
			-- TRUE/FALSE indicator showing if the dataset is certified or not
			ds.is_certified,
			-- display name of the Tableau User who certified it
			ds.certifier_details       AS certified_by,
			ds.certification_note      AS certfication_note,
			-- user who last (re-)published the dataset
			sysus.name                 AS datasource_owner,
			dc.id                      AS datasource_connection_id,
			dc.server                  AS datasource_connected_to,             -- IP to which the connection is made;  NULL in case if bigquery and empty string for Excel and google sheets
			dc.dbclass                 AS datasource_connection_type,          -- e.g. sqlserver, mysql, postgresql, bigquery, excel-direct, google-sheets. etc
			dc.dbname                  AS datasource_connection_name,          -- the exact database to which the database is connected --> #if cross-DB connections are used, this will return more than 1 entry
			-- e.g. Datasource, Workbook
			dc.owner_type              AS connection_type,
			-- the credentials used to connect to the data
			dc.username                AS credentials_used,
			-- TRUE/FALSE indicator that shows if password was embedded or not
			dc.password                AS embedded_password,
			-- the unique identifer used by the TableauServer Client API
			dc.luid                    AS connection_luid,
			-- timestamp of the connection creation
			dc.created_at              AS connection_first_created,
			-- timestamp of the latest connection update
			dc.updated_at              AS connection_last_revised,
			-- TRUE/FALSE indicator showing if extract is set
			dc.has_extract             AS connection_uses_extract,
			dc.caption                 AS connection_friendly_name				-- as seen in Desktop Pane; NB use with caution may be manually overwritten by a user

		FROM public.datasources AS ds
			INNER JOIN public.data_connections AS dc
				ON ds.id = dc.datasource_id

			------get datasource site -------------
			INNER JOIN public.sites AS s
				ON ds.site_id = s.id

			------get datasource project------------
			INNER JOIN projects AS prj
				ON ds.project_id = prj.id

			------get datasource owner---------------
			INNER JOIN public.users AS us
				ON ds.owner_id = us.id

			INNER JOIN public.system_users AS sysus
				ON us.system_user_id = sysus.id


		WHERE dc.owner_type = 'Datasource'       --'Datasource' represents a published dataset; 'Workbook' means embedded dataset

		ORDER BY
			ds.project_id,
			ds.name
	),

	ds_access AS (
		SELECT
			hd.datasource_id,
			MAX(he.created_at) AS last_accessed,
			COUNT(*)           AS times_accessed

		FROM
			historical_events AS he,
			hist_datasources AS hd,
			historical_event_types AS het

		WHERE
			he.hist_datasource_id = hd.id
			AND he.historical_event_type_id = het.type_id
			AND (
				het.name = 'Access Data Source'
				OR het.name = 'Download Data Source'
			)

		GROUP BY
			hd.datasource_id

		ORDER BY datasource_id

	),

	ds_metrics_aggregations AS (
		SELECT
			ma.datasource_id,
			TO_DATE(
				CONCAT(
					CAST(ma.year_index AS text), '-',
					CAST(ma.month_index AS text), '-',
					CAST(ma.day_index AS text), '-'
				), 'YYYY-MM-DD'
			)                  AS date_viewed,

			SUM(ma.view_count) AS num_views
		FROM public.datasource_metrics_aggregations AS ma
		GROUP BY 1, 2
		ORDER BY 2 DESC

	)

SELECT
	s.*,
	s.connection_friendly_name,
	a.last_accessed,
	a.times_accessed,
	m.date_viewed,
	m.num_views

FROM ds_setup AS s
	LEFT JOIN ds_access AS a
		ON s.datasource_id = a.datasource_id

	LEFT JOIN ds_metrics_aggregations AS m
		ON s.datasource_id = m.datasource_id

ORDER BY s.datasource_id
