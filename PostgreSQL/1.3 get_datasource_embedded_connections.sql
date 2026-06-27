SELECT
	ds.project_id,
	prj.name              AS project_name,
	ds.id                 AS datasource_id,
	ds.name               AS datasource_name,
	ds.repository_url,
	ds.parent_workbook_id AS workbook_id,
	w.name                AS workbook_name,
	sysus.name            AS datasource_owner,
	w.refreshable_extracts,
	w.extracts_refreshed_at,
	w.last_published_at   AS wbk_last_published,
	dc.dbclass            AS embedded_connection_type,
	dc.dbname             AS embedded_connection_name,
	ds.last_published_at  AS connection_last_published,
	dc.username           AS credentials_used,
	dc.password           AS embedded_password,
	dc.owner_type         AS connection_type

FROM public.datasources AS ds
	INNER JOIN public.data_connections AS dc
		ON ds.id = dc.datasource_id

	INNER JOIN public.workbooks AS w
		ON ds.parent_workbook_id = w.id

	INNER JOIN projects AS prj
		ON ds.project_id = prj.id

	INNER JOIN public.users AS us
		ON ds.owner_id = us.id

	INNER JOIN public.system_users AS sysus
		ON us.system_user_id = sysus.id

WHERE
	dc.owner_type = 'Workbook'
	AND ds.repository_url LIKE '%embedded%'
	AND dc.dbclass != 'sqlproxy'

ORDER BY
	ds.project_id ASC,
	connection_last_published DESC
