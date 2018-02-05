local ns2_BuildTechData = BuildTechData

function BuildTechData()

	local techData = ns2_BuildTechData()
	table.insert(techData, { [kTechDataId] = kTechId.Digest,  [kTechDataDisplayName] = "Digest",  [kTechDataCostKey] = 0,   [kTechIDShowEnables] = false,  [kTechDataResearchTimeKey] = kRecycleTime,   [kTechDataHotkey] = Move.R,   [kTechDataTooltipInfo] =  "RECYCLE_TOOLTIP"})
	
    return techData
end