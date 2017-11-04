USE auditor

IF OBJECT_ID('tempdb..#AuditItem') IS NOT NULL
	DROP TABLE #AuditItem

IF OBJECT_ID('tempdb..#Updates') IS NOT NULL
	DROP TABLE #Updates

SELECT
	APP.ApplicationRef								AS ApplicationNumber,
	AI.[datetime]									AS UpdateDate,
	AI.Action										AS [Action],
	AI.StaffMemberId								AS [StaffMemberId],
	CAST(CAST(AI.auditxml AS NVARCHAR(MAX)) AS XML) AS SourceXml
INTO 
	#AuditItem
FROM 
			audit_AuditItem										AI
INNER JOIN	backofficemortgage.dbo.[morAppFma_FMAApplication]	APP ON AI.EntityId = APP.id

WHERE 
	AI.EntityType = 'FMAApplication'
AND 
	APP.applicationref = 'PM1001334444'

ORDER BY 
	AI.[DateTime] DESC



SELECT 
	AI.UpdateDate												AS UpdateDate,
	AI.StaffMemberId											AS StaffMemberId,	
	AI.SourceXml.query('//C_[@t_ eq "FMAApplicantIncome"]/U_')	AS UpdatesXml
INTO
	#Updates
FROM 
	#AuditItem AI
WHERE 
	AI.SourceXml.exist('//C_[@t_ eq "FMAApplicantIncome"]') = 1


SELECT 
	UP.UpdateDate,
	UP.SourceXml.value('(/U_/F_[@n_ eq "ApplicantId"]/N_)[1]','uniqueidentifier')	AS ApplicantId,
	UP.SourceXml.value('(/U_/F_[@n_ eq "BasicSalary"]/N_)[1]','float')				AS BasicSalary,
	UP.SourceXml.value('(/U_/F_[@n_ eq "Overtime"]/N_)[1]','float')					AS Overtime,
	UP.SourceXml.value('(/U_/F_[@n_ eq "BonusCommission"]/N_)[1]','float')			AS BonusCommission,
	UP.SourceXml.value('(/U_/F_[@n_ eq "ShiftAllowance"]/N_)[1]','float')			AS ShiftAllowance,
	UP.SourceXml.value('(/U_/F_[@n_ eq "OtherIncome"]/N_)[1]','float')				AS OtherIncome,
	UP.SourceXml
FROM (
	SELECT 
		U.UpdateDate,
		UP.UpdatedValues.query('.') AS SourceXml
	FROM #Updates U
	CROSS APPLY U.UpdatesXml.nodes('/U_') AS UP(UpdatedValues)
) UP


