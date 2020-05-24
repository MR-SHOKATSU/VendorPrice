local debugMode = true
if debugMode then print("VendorPrice: Debug Mode loaded.") end

local SetTooltipTable = {
	SetBagItem = function(self, bagID, slot)
		self.count = select(2, GetContainerItemInfo(bagID, slot))
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

local OnTooltipSetItem = function(self, ...)
	-- immediately return if the player is interacting with a vendor
	if MerchantFrame:IsShown() then return end
	local name, link = self:GetItem()
	if not link then return end
	local class = select(6, GetItemInfo(link))
	local vendorPrice = select(11, GetItemInfo(link))
	if vendorPrice then
		if debugMode then print(name, self.count, self.shouldPrintLine) end
		-- eliminate the duplicate money line on recipes
		if class == "Recipe" then
			self.shouldPrintLine = not self.shouldPrintLine
		end
		if class ~= "Recipe" or not self.shouldPrintLine then
			if vendorPrice == 0 then
				self:AddLine("No sell price", 255, 255, 255)	
			else
				self.count = self.count or 1
				self:AddLine(GetCoinTextureString(vendorPrice * self.count), 255, 255, 255)
			end
		end
	end
	self.count = nil
end

for _, Tooltip in pairs {GameTooltip, ItemRefTooltip} do
	Tooltip:HookScript("OnTooltipSetItem", OnTooltipSetItem)
end