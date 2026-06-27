SELECT
	usg.group_id        AS groupid,
	g.name              AS grouppermissions,
	sysus.friendly_name AS username,
	sysus.email         AS useremail

FROM public.group_users AS usg
	INNER JOIN public.groups AS g
		ON usg.group_id = g.id

	INNER JOIN public.users AS u
		ON usg.user_id = u.id

	INNER JOIN public.system_users AS sysus
		ON u.system_user_id = sysus.id

WHERE
	g.site_id = 1 --Default site
	AND usg.group_id NOT IN (2) --all users

ORDER BY 1
