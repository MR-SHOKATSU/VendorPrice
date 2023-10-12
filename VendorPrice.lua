local debugMode = false
if debugMode then print("VendorPrice: Debug Mode enabled.") end

local OptionTable = {}

local SetTooltipTable = {
	SetBagItem = function(self, bagID, slot)
		--self.count = select(2, GetContainerItemInfo(bagID, slot))
		self.count = 0
		local info = C_Container.GetContainerItemInfo(bagID, slot)
		if info ~= nil then self.count = info.stackCount end
	end,
	SetInventoryItem = function(self, unit, slot)
		self.count = GetInventoryItemCount(unit, slot)
	end,
	SetAuctionItem = function(self, type, index)
		self.count = select(3, GetAuctionItemInfo(type, index))
	end,
	SetAuctionSellItem = function(self)
		self.count = select(3, GetAuctionSellItemInfo())
	end,
	SetQuestLogItem = function(self, _, index)
		self.count = select(3, GetQuestLogRewardInfo(index))
	end,
	SetInboxItem = function(self, index, itemIndex)
		if itemIndex then
			self.count = select(4, GetInboxItem(index, itemIndex))
		else
			self.count = select(1, select(14, GetInboxHeaderInfo(index)))
		end
	end,
	SetSendMailItem = function(self, index)
		self.count = select(4, GetSendMailItem(index))
	end,
	SetTradePlayerItem = function(self, index)
		self.count = select(3, GetTradePlayerItemInfo(index))
	end,
	SetTradeTargetItem = function(self, index)
		self.count = select(3, GetTradeTargetItemInfo(index))
	end,
}

for functionName, hookfunc in pairs (SetTooltipTable) do
	hooksecurefunc(GameTooltip, functionName, hookfunc)
end

local IfHasShowedMoneyLine = function(self, name, class)
	if class == "Recipe" then
		if string.find(name, "Recipe") or string.find(name, "Pattern")
		or string.find(name, "Plans") or string.find(name, "Schematic")
		or string.find(name, "Manual") then
			self.hasShowedMoneyLine = not self.hasShowedMoneyLine
			return self.hasShowedMoneyLine
		end
	end
	-- return false
end

local OnTooltipSetItem = function(self, ...)
	-- immediately return if the player is interacting with a vendor
	if MerchantFrame:IsShown() then return end
	local name, link = self:GetItem()
	if not link then return end
	local class = select(6, GetItemInfo(link))
	local vendorPrice = select(11, GetItemInfo(link))
	if not vendorPrice then return end
	if debugMode and self.count then print ("".. name .." (".. self.count ..")", self.hasShowedMoneyLine) end
	if vendorPrice == 0 then
		self:AddLine(NO_SELL_PRICE_TEXT, 255, 255, 255)
	else
		if not IfHasShowedMoneyLine(self, name, class) then
			self.count = self.count or 1
			if self.count == 0 then
				self.count = 1
			end
			self:AddLine(GetCoinTextureString(vendorPrice * self.count), 255, 255, 255)
		end
	end
	self.count = nil
end

for _, Tooltip in pairs {GameTooltip, ItemRefTooltip} do
	Tooltip:HookScript("OnTooltipSetItem", OnTooltipSetItem)
end