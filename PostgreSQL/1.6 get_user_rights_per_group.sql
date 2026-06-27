SELECT
	s.name              AS site_name,
	g.name              AS group_name,
	sysus.name          AS user_id,
	sysus.friendly_name AS user_name,
	r.id                AS role_id,
	r.name              AS role_name,
	STRING_AGG(
		c.name, ', '
		ORDER BY c.name
	)                   AS capabilities

FROM public.group_users AS usg
	INNER JOIN public.groups AS g
		ON usg.group_id = g.id

	-------get user details ----------
	INNER JOIN public.users AS u
		ON usg.user_id = u.id

	INNER JOIN public.system_users AS sysus
		ON u.system_user_id = sysus.id

	--------get role details ----------
	INNER JOIN public.roles AS r
		ON u.site_role_id = r.id

	INNER JOIN public.capability_roles AS cr
		ON r.id = cr.role_id

	INNER JOIN public.capabilities AS c
		ON cr.capability_id = c.id

	------get site details---------------
	INNER JOIN sites AS s
		ON g.site_id = s.id

WHERE
	g.site_id = 1 --Default site
	AND usg.group_id NOT IN (2) --all users

GROUP BY 1, 2, 3, 4, 5, 6

ORDER BY 1, 2
