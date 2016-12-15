--[[
    cooldown.lua
    Manages the cooldowns need for timers
--]]

local Cooldown = OmniCC:New('Cooldown')


--[[ Control ]]--

function Cooldown:Start(...)
    Cooldown.UpdateAlpha(self)
    if Cooldown.CanShow(self, unpack(arg)) then
        Cooldown.Setup(self)
        self.omnicc:Start(unpack(arg))
    else
        Cooldown.Stop(self)
    end
end

function Cooldown:Setup()
    if not self.omnicc then
        self:SetScript('OnShow', Cooldown.OnShow)
        self:SetScript('OnHide', Cooldown.OnHide)
        self:SetScript('OnSizeChanged', Cooldown.OnSizeChanged)
        self.omnicc = OmniCC.Timer:New(self)
    end

    OmniCC:SetupEffect(self)
end

function Cooldown:Stop()
    local timer = self.omnicc
    if timer and timer.enabled then
        timer:Stop()
    end
end

function Cooldown:CanShow(start, duration)
    if not self.noCooldownCount and duration and start and start > 0 then
        local sets = OmniCC:GetGroupSettingsFor(self)
        if duration >= sets.minDuration and sets.enabled then
            -- local globalstart, globalduration = GetSpellCooldown(61304)
            -- return start ~= globalstart or duration ~= globalduration
            return true
        end
    end
end


--[[ Frame Events ]]--

function Cooldown:OnShow()
    local timer = this.omnicc
    if timer and timer.enabled then
        if timer:GetRemain() > 0 then
            timer.visible = true
            timer:UpdateShown()
        else
            timer:Stop()
        end
    end
end

function Cooldown:OnHide()
    local timer = this.omnicc
    if timer and timer.enabled then
        timer.visible = nil
        timer:Hide()
    end
end

function Cooldown:OnSizeChanged(...)
    local width = this:GetWidth() * (1 - arg1)
    local height = this:GetHeight() * (1 - arg2)

    if this.omniWidth ~= width then
        this.omniWidth = width

        local timer = this.omnicc
        if timer then
            timer:UpdateFontSize(width, height)
        end
    end
end

function Cooldown:OnColorSet(...)
    if not self.omniTask then
        self.omniR, self.omniG, self.omniB, self.omniA = unpack(arg)
        Cooldown.UpdateAlpha(self)
    end
end


--[[ Misc ]]--

function Cooldown:UpdateAlpha()
    local alpha = OmniCC:GetGroupSettingsFor(self).spiralOpacity * (self.omniA or 1)

    self.omniTask = true
    -- OmniCC.Meta.SetSwipeColor(self, self.omniR or 0, self.omniG or 0, self.omniB or 0, alpha)
    self.omniTask = nil
end

function Cooldown:ForAll(func, ...)
    func = self[func]

    for cooldown in pairs(OmniCC.Cache) do
        func(cooldown, unpack(arg))
    end
end
