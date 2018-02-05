

DigestMixin = CreateMixin(DigestMixin)
DigestMixin.type = "Digest"

local kDigestEffectDuration = 2

DigestMixin.expectedCallback =
{
}

DigestMixin.optionalCallbacks =
{
    GetCanDigestOverride = "Return custom restrictions for Digesting."
}

DigestMixin.expectedMixins =
{
    Research = "Required for Digest progress / cancellation."
}    

DigestMixin.networkVars =
{
    Digested = "boolean"
}

function DigestMixin:__initmixin()
    self.Digested = false
end

function DigestMixin:GetDigestActive()
    return self.researchingId == kTechId.Digest
end

function DigestMixin:OnDigested()
end

function DigestMixin:GetCanDigest()

    local canDigest = true
    
    if self.GetCanDigestOverride then
        canDigest = self:GetCanDigestOverride()
    end

    return canDigest and not self:GetDigestActive()    

end

function DigestMixin:OnResearchComplete(researchId)

    if researchId == kTechId.Digest then
        
        -- Do not display new killfeed messages during concede sequence
        if GetConcedeSequenceActive() then
            return
        end
        
        self:TriggerEffects("Digest_end")
        
        -- Amount to get back, accounting for upgraded structures too
        local upgradeLevel = 0
        if self.GetUpgradeLevel then
            upgradeLevel = self:GetUpgradeLevel()
        end
        
        local amount = GetDigestAmount(self:GetTechId(), upgradeLevel) or 0
        -- returns a scalar from 0-1 depending on health the structure has (at the present moment)
        local scalar = self:GetDigestScalar() * kDigestPaybackScalar
        
        -- We round it up to the nearest value thus not having weird
        -- fracts of costs being returned which is not suppose to be
        -- the case.
        local finalDigestAmount = math.round(amount * scalar)
        
        
        self:GetTeam():PrintWorldTextForTeamInRange(kWorldTextMessageType.Resources, self:GetOrigin() + kWorldMessageResourceOffset, kResourceMessageRange)
        
        Server.SendNetworkMessage( "Digest", BuildDigestMessage(amount - finalDigestAmount, self:GetTechId(), finalDigestAmount), true )
        
        local team = self:GetTeam()
        local deathMessageTable = team:GetDeathMessage(team:GetCommander(), kDeathMessageIcon.Digested, self)
        team:ForEachPlayer(function(player) if player:GetClient() then Server.SendNetworkMessage(player:GetClient(), "DeathMessage", deathMessageTable, true) end end)
        
        self.Digested = true
        self.timeDigested = Shared.GetTime()

        self:OnDigested()
        
    end

end

function DigestMixin:GetIsDigested()
    return self.Digested
end

function DigestMixin:GetDigestScalar()
    return self:GetHealth() / self:GetMaxHealth()
end

function DigestMixin:GetIsDigesting()
    return self.researchingId == kTechId.Digest
end

function DigestMixin:OnResearch(researchId)

    if researchId == kTechId.Digest then        
        self:TriggerEffects("Digest_start")        
        if self.MarkBlipDirty then
            self:MarkBlipDirty()
        end
    end
    
end


function DigestMixin:OnResearchCancel(researchId)

    if researchId == kTechId.Digest then
        if self.MarkBlipDirty then
            self:MarkBlipDirty()
        end
    end
    
end


function DigestMixin:OnUpdateRender()

    PROFILE("DigestMixin:OnUpdateRender")

    if self.Digested ~= self.clientDigested then
    
        self.clientDigested = self.Digested
        self:SetOpacity(1, "DigestAmount")
        
        if self.Digested then
            self.clientTimeDigestStarted = Shared.GetTime()
        else
            self.clientTimeDigestStarted = nil
        end
    
    end
    
    if self.clientTimeDigestStarted then
    
        local DigestAmount = 1 - Clamp((Shared.GetTime() - self.clientTimeDigestStarted) / kDigestEffectDuration, 0, 1)
        self:SetOpacity(DigestAmount, "DigestAmount")
    
    end

end

function DigestMixin:OnUpdateAnimationInput(modelMixin)

    PROFILE("DigestMixin:OnUpdateAnimationInput")
    modelMixin:SetAnimationInput("recycling", self:GetDigestActive())
    
end

local function SharedUpdate(self, deltaTime)

    if Server then
    
        if self.timeDigested then
        
            if self.timeDigested + kDigestEffectDuration + 1 < Shared.GetTime() then
                DestroyEntity(self)
            end
        
        elseif self.researchingId == kTechId.Digest then
            self:UpdateResearch(deltaTime)
        end
        

    end
    
end

function DigestMixin:OnUpdate(deltaTime)
    SharedUpdate(self, deltaTime)
end

function DigestMixin:OnProcessMove(input)
    SharedUpdate(self, input.time)
end