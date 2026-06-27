WITH
	wbks AS (
		--- which are my most used sheets within a workbook?
		--- when were they last viewed, how many times and by whom?
		SELECT
			prj.name         AS project,
			v.workbook_id,
			wb.name          AS workbook_name,
			vs.view_id,
			v.name           AS view_name,
			v.repository_url AS view_url,
			sou.name         AS view_created_by,
			v.created_at     AS view_created_at,
			v.index          AS view_tab_num_in_wbk,
			v.title          AS view_title,
			v.caption        AS view_description,
			v.fields         AS fields_used_in_view,

			STRING_AGG(
				DISTINCT
				vs.device_type, ', '
			)                AS viewed_on,

			STRING_AGG(
				DISTINCT
				su.friendly_name, ', '
			)                AS viewed_by,

			MAX(vs.time)     AS last_viewed,
			SUM(vs.nviews)   AS total_num_views

		FROM views_stats AS vs
			INNER JOIN views AS v
				ON vs.view_id = v.id

			--- get viewer info ----
			INNER JOIN users AS u
				ON vs.user_id = u.id

			INNER JOIN system_users AS su
				ON u.system_user_id = su.id

			-----get owner info------------
			INNER JOIN users AS ou
				ON v.owner_id = ou.id

			INNER JOIN system_users AS sou
				ON ou.system_user_id = sou.id

			----get workbook info ----------
			INNER JOIN public.workbooks AS wb
				ON v.workbook_id = wb.id

			------get project info---------
			INNER JOIN projects AS prj
				ON wb.project_id = prj.id

		GROUP BY
			prj.name,
			v.workbook_id,
			wb.name,
			vs.view_id,
			v.name,
			v.repository_url,
			sou.name,
			v.created_at,
			v.index,
			v.title,
			v.caption,
			v.fields

		ORDER BY
			v.workbook_id,
			v.id
	),

	subscriptions AS (
		--- who has subscribed to my workbook views?
		SELECT
			sub.target_id,
			sub.target_type,
			MAX(sub.last_sent) AS subscription_last_sent,

			STRING_AGG(
				DISTINCT
				su.friendly_name, ', '
			)                  AS subscribers

		FROM public.subscriptions AS sub

			-----get subscriber info------------
			INNER JOIN users AS u
				ON sub.user_id = u.id

			INNER JOIN system_users AS su
				ON u.system_user_id = su.id

		GROUP BY
			sub.target_id,
			sub.target_type
	)

SELECT
	w.project,
	w.workbook_id,
	w.workbook_name,
	w.view_id,
	w.view_name,
	w.view_url,
	w.view_created_by,
	w.view_created_at,
	w.view_tab_num_in_wbk,
	w.view_title,
	w.view_description,
	w.fields_used_in_view,
	w.viewed_on,
	w.viewed_by,
	w.last_viewed,
	w.total_num_views,
	s.subscription_last_sent,
	s.subscribers,
	s.target_type

FROM wbks AS w
	LEFT JOIN subscriptions AS s
		ON
			w.view_id = s.target_id			--- capture view subscriptions
			OR w.workbook_id = s.target_id	--- capture workbook subscriptions

ORDER BY
	w.workbook_id,
	w.view_id
