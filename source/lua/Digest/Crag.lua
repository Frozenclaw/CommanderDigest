Script.Load("lua/Digest/DigestMixin.lua")
local networkVars =
{
}
AddMixinNetworkVars(DigestMixin, networkVars)
local oldfunc = Crag.OnCreate
function Crag:OnCreate()

	InitMixin(self, DigestMixin)
end 