--check subscriptions for workbooks connected to a particular published datasource
WITH
	datasources AS (
		SELECT
			v.id    AS view_id,
			v.name  AS view_name,
			v.workbook_id,
			w.name  AS workbook_name,
			ds.name AS datasource_name

		FROM public.workbooks AS w
			INNER JOIN views AS v
				ON w.id = v.workbook_id

			INNER JOIN public.datasources AS ds
				ON w.id = ds.parent_workbook_id

			INNER JOIN public.data_connections AS dc
				ON ds.id = dc.datasource_id

		WHERE
			1 = 1
			AND dc.owner_type = 'Workbook'
			AND dc.dbclass = 'sqlproxy'
	)

SELECT
	d.workbook_id,
	d.workbook_name,
	d.view_id,
	d.view_name,
	su.friendly_name AS subscriber,
	sub.subject,
	sub.created_at,
	sub.last_sent,
	sub.data_condition_type,
	sub.target_type,
	sub.attach_pdf,
	sub.attach_image

FROM public.subscriptions AS sub
	LEFT JOIN datasources AS d
		ON
			sub.target_id = d.workbook_id
			OR sub.target_id = d.view_id

	-----get subscriber info------------
	INNER JOIN users AS u
		ON sub.user_id = u.id

	INNER JOIN system_users AS su
		ON u.system_user_id = su.id

WHERE
	1 = 1
	AND datasource_name LIKE '%DS%'

ORDER BY
	workbook_id,
	view_id
