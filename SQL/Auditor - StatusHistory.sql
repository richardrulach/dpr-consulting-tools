USE auditor

DECLARE  @applicationRef	NVARCHAR(100)	= N'PM1001334117'

/*-----------------------------------------------------------------------------------------------------
	CTE holds all the entries in the audit table for a particular application
-----------------------------------------------------------------------------------------------------*/
;WITH AI AS (
	SELECT
		APP.ApplicationRef								AS ApplicationNumber,
		AI.[datetime]									AS UpdateDate,
		AI.Action										AS [Action],
		AI.StaffMemberId								AS [StaffMemberId],
		CAST(CAST(AI.auditxml AS NVARCHAR(MAX)) AS XML) AS SourceXml
	FROM 
				audit_AuditItem										AI
	INNER JOIN	backofficemortgage.dbo.[morAppFma_FMAApplication]	APP ON AI.EntityId = APP.id

	WHERE 
		AI.EntityType = 'FMAApplication'
	AND 
		APP.applicationref = @applicationRef
)


/*-----------------------------------------------------------------------------------------------------
	1. Separate the updates into different rows for each row that is changed (using CROSS APPLY)
	2. Select the items from the changed row that are of interest
-----------------------------------------------------------------------------------------------------*/
SELECT 
	AI.UpdateDate																					AS UpdateDate,
	AI.StaffMemberId																				AS StaffMemberId,	
	UP.UpdatedValues.query('.').value('(/C_/@id)[1]','uniqueidentifier')							AS Id,
	UP.UpdatedValues.query('.').value('(/C_/U_/F_[@n_ eq "StatusNameId"]/N_)[1]','varchar(200)')	AS StatusNameId,
	UP.UpdatedValues.query('.')																		AS UpdatesXml,
	AI.SourceXml																					AS SourceXml
FROM 
	AI
	CROSS APPLY AI.SourceXml.nodes('//C_[@t_ eq "FMAStatus"]') AS UP(UpdatedValues)
ORDER BY 
	AI.UpdateDate DESC

