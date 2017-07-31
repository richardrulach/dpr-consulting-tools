USE Auditor
GO


SELECT 
	AI.ref,
	AI.dt,
	A2.b.value('./@id', 'varchar(36)'),
	A2.b.value('./@t_', 'varchar(100)'),
	A2.b.query('./U_')
FROM 
(
	SELECT TOP 100
		CAST(CAST(a.auditxml AS NTEXT) AS XML) 
		, app.ApplicationRef
		, a.DateTime
	FROM audit_AuditItem a
	INNER JOIN backofficemortgage.dbo.morAppFma_FMAApplication app on a.EntityId = app.id
	WHERE entityType = 'FMAApplication'
	and app.ApplicationRef = 'PM1001334115'
) AI(x,ref,dt)
CROSS APPLY
	x.nodes('//C_') as A2(b)
WHERE 
	AI.x.exist('C_') = 1
order by 
A2.b.value('./@t_', 'varchar(100)'), A2.b.value('./@id', 'varchar(36)'), AI.dt desc



