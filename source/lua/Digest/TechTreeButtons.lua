local ns2_GetMaterialXYOffset = GetMaterialXYOffset
function GetMaterialXYOffset(techId)
	if techId == kTechId.Digest then
		techId = kTechId.Recycle
	end
	return ns2_GetMaterialXYOffset(techId)
end 