
local _, WB = ...

-- Cache of the current specialization ID for quick access elsewhere in the WB.
WB._currentSpecId = nil

local function UpdateCurrentSpecId()
	local specId = nil
	-- Prefer the ClassTalents API when available (more reliable)
	if C_ClassTalents and C_ClassTalents.GetActiveConfigID and C_ClassTalents.GetSpecInfoForConfig then
		local cfg = C_ClassTalents.GetActiveConfigID()
		local info = cfg and C_ClassTalents.GetSpecInfoForConfig(cfg) or nil
		if info and type(info.specID) == "number" and info.specID > 0 then
			specId = info.specID
		end
	end

	-- Fallback: use the legacy GetSpecialization API
	if not specId and GetSpecialization and GetSpecializationInfo then
		local spec = GetSpecialization()
		if spec then
			local ok, id = pcall(function() return select(7, GetSpecializationInfo(spec)) end)
			if ok and type(id) == "number" and id > 0 then
				specId = id
			end
		end
	end

	WB._currentSpecId = specId
	return specId
end

-- Expose a simple getter for other modules
WB.GetActiveSpecId = function()
	return WB._currentSpecId or UpdateCurrentSpecId()
end

WB.GetHighComboThreshold = function()
	return SnapComboPointsDB and SnapComboPointsDB.highComboPointsThreshold or 0
end

WB.IsHighComboEnabledForSpec = function()
	return SnapComboPointsDB and SnapComboPointsDB.highComboEnabled
end

-- Keep the cached value up-to-date
local specFrame = CreateFrame("Frame")
specFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
specFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
specFrame:SetScript("OnEvent", function()
	UpdateCurrentSpecId()
end)

-- Initialize immediately if possible
UpdateCurrentSpecId()
