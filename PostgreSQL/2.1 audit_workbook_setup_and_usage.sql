WITH
	workbook_setup AS (
		--which workbooks were recently published?
		--who published them and where?
		SELECT
			wb.luid                    AS wbk_luid,
			wb.id                      AS wbk_id,
			wb.name                    AS wbk_name,

			s.name                     AS wbk_site_name,
			prj.name                   AS wbk_project_name,

			wb.created_at              AS wbk_first_created,
			wb.updated_at              AS wbk_last_updated,
			wb.owner_id                AS wbk_owner_id,
			sysus.name                 AS wbk_owner,
			wb.first_published_at      AS wbk_first_published,
			wb.display_tabs            AS wbk_display_tabs,
			wb.published_all_sheets    AS wbk_published_all_sheets,

			wb.data_engine_extracts    AS wbk_connects_to_hyper_extracts,
			wb.refreshable_extracts    AS wbk_full_refresh_set,
			wb.extracts_refreshed_at   AS wbk_last_fully_refreshed_at,
			wb.incrementable_extracts  AS wbk_incremental_refresh_set,
			wb.extracts_incremented_at AS wbk_last_refreshed_incrementally_at,

			wb.last_published_at       AS wbk_last_published_at,
			wb.modified_by_user_id     AS wbk_last_modified_by,
			wb.revision                AS wbk_revision,
			wb.document_version,
			wb.content_version

		FROM public.workbooks AS wb

 	------get workbook site -------------
			INNER JOIN public.sites AS s
				ON wb.site_id = s.id

			------get project info---------
			INNER JOIN projects AS prj
				ON wb.project_id = prj.id

    ------get owner info-----------
			INNER JOIN public.users AS us
				ON wb.owner_id = us.id

			INNER JOIN public.system_users AS sysus
				ON us.system_user_id = sysus.id

	),

	used_published_datasources AS (
		--which published datasources do workbooks use?
		SELECT
			ds.project_id,
			ds.parent_workbook_id     AS workbook_id,
			w.name                    AS workbook_name,
			STRING_AGG(ds.name, '--') AS datasources_used_in_wbk

		FROM public.workbooks AS w
			INNER JOIN public.datasources AS ds
				ON w.id = ds.parent_workbook_id

			INNER JOIN public.data_connections AS dc
				ON ds.id = dc.datasource_id

		WHERE
			dc.owner_type = 'Workbook'
			AND dc.dbclass = 'sqlproxy'

		GROUP BY
			ds.project_id,
			ds.parent_workbook_id,
			w.name
	),

	used_fields AS (
		--what fields are used per workbook?
		SELECT
			v.workbook_id,
			STRING_AGG(DISTINCT v.fields, ',') AS fields_used_in_wbk

		FROM public.views AS v
		GROUP BY v.workbook_id
	),

	workbook_usage AS (
		SELECT
			v.workbook_id,
			STRING_AGG(su.friendly_name, ', ') AS viewers,
			STRING_AGG(DISTINCT v.name, ', ')  AS views_used_in_wbk,
			MAX(vs.time)                       AS last_viewed,
			SUM(vs.nviews)                     AS total_num_views

		FROM views_stats AS vs
			INNER JOIN views AS v
				ON vs.view_id = v.id

    --- get viewer info ----
			INNER JOIN users AS u
				ON vs.user_id = u.id

			INNER JOIN system_users AS su
				ON u.system_user_id = su.id

		GROUP BY v.workbook_id
		ORDER BY v.workbook_id
	)

SELECT
	ws.wbk_luid,
	ws.wbk_id,
	ws.wbk_name,
	ws.wbk_site_name,
	ws.wbk_project_name,
	ws.wbk_first_created,
	ws.wbk_last_updated,
	ws.wbk_owner_id,
	ws.wbk_owner,
	ws.wbk_first_published,
	ws.wbk_display_tabs,
	ws.wbk_published_all_sheets,
	ws.wbk_connects_to_hyper_extracts,
	ws.wbk_full_refresh_set,
	ws.wbk_last_fully_refreshed_at,
	ws.wbk_incremental_refresh_set,
	ws.wbk_last_refreshed_incrementally_at,
	ws.wbk_last_published_at,
	ws.wbk_last_modified_by,
	ws.wbk_revision,
	ud.datasources_used_in_wbk,
	uf.fields_used_in_wbk,
	wu.views_used_in_wbk,
	wu.viewers,
	wu.last_viewed,
	wu.total_num_views

FROM workbook_setup AS ws
	LEFT JOIN used_published_datasources AS ud
		ON ws.wbk_id = ud.workbook_id

	LEFT JOIN used_fields AS uf
		ON ws.wbk_id = uf.workbook_id

	LEFT JOIN workbook_usage AS wu
		ON ws.wbk_id = wu.workbook_id

WHERE
	1 = 1
	AND ud.datasources_used_in_wbk LIKE '%datasourcename%'
	OR ws.wbk_owner IN ('username1', 'username2')
	OR ws.wbk_name LIKE 'performance%'
