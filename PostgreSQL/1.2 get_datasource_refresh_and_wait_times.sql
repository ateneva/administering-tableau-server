SELECT
	job.id                  AS job_id,
	job.progress,
	job.updated_at,
	job.created_at,
	job.completed_at,
	job.started_at,
	job.job_name,
	job.finish_code,
	job.priority,
	job.title,
	job.created_on_worker,
	job.processed_on_worker,
	job.lock_version,
	job.backgrounder_id,
	job.serial_collection_id,
	job.site_id,
	job.subtitle,
	job.language,
	job.locale,
	job.correlation_id,
	job.attempts_remaining,
	job.luid,
	job.job_rank,
	job.queue_id,
	job.overflow,
	job.promoted_at,
	job.task_id,
	job.run_now,
	job.creator_id,
	s.id                    AS site_id,
	s.name                  AS site_name,
	s.url_namespace,
	s.status,
	CAST(job.args AS TEXT)  AS args,
	CAST(job.notes AS TEXT) AS notes,
	CAST(job.link AS TEXT)  AS link

FROM public.background_jobs AS job
	INNER JOIN public.sites AS s
		ON (job.site_id = s.id)

WHERE
	job.job_name LIKE 'Refresh%'
	OR job.job_name LIKE 'Subscription%'
