USE auditor

DECLARE  @applicationRef	NVARCHAR(100)	= N'PM1001334444'

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
	UP.UpdatedValues.query('.').value('(/C_/U_/F_[@n_ eq "ApplicantId"]/N_)[1]','uniqueidentifier')	AS ApplicantId,
	UP.UpdatedValues.query('.').value('(/C_/U_/F_[@n_ eq "BasicSalary"]/N_)[1]','float')			AS BasicSalary,
	UP.UpdatedValues.query('.').value('(/C_/U_/F_[@n_ eq "Overtime"]/N_)[1]','float')				AS Overtime,
	UP.UpdatedValues.query('.').value('(/C_/U_/F_[@n_ eq "BonusCommission"]/N_)[1]','float')		AS BonusCommission,
	UP.UpdatedValues.query('.').value('(/C_/U_/F_[@n_ eq "ShiftAllowance"]/N_)[1]','float')			AS ShiftAllowance,
	UP.UpdatedValues.query('.').value('(/C_/U_/F_[@n_ eq "OtherIncome"]/N_)[1]','float')			AS OtherIncome,
	UP.UpdatedValues.query('.')																		AS UpdatesXml,
	AI.SourceXml																					AS SourceXml
FROM 
	AI
	CROSS APPLY AI.SourceXml.nodes('//C_[@t_ eq "FMAApplicantIncome"]') AS UP(UpdatedValues)
ORDER BY 
	UP.UpdatedValues.query('.').value('(/C_/@id)[1]','uniqueidentifier'),
	AI.UpdateDate

