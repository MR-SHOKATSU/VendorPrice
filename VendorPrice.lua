local count = nil
local debugMode = false
local SetCount = function(itemCount) count = itemCount if debugMode then print(count) end end

local SetItem = {
	SetBagItem = function(_, bagID, slot)
		local count = select(2, GetContainerItemInfo(bagID, slot))
		SetCount(count)
	end,
	SetAuctionItem = function(_, type, index)
		local count = select(3, GetAuctionItemInfo(type, index))
		SetCount(count)
	end,
	SetAuctionSellItem = function(_)
		local count = select(3, GetAuctionSellItemInfo())
		SetCount(count)
	end,
	SetQuestLogItem = function(_, _, index)
		local count = select(3, GetQuestLogRewardInfo(index))
		SetCount(count)
	end,
	SetSendMailItem = function(_, index)
		local count = select(4, GetSendMailItem(index))
		SetCount(count)
	end,
	SetInboxItem = function(_, index, itemIndex)
		local count
		if itemIndex then
			count = select(4, GetInboxItem(index, itemIndex))
		else
			count, _ = select(14, GetInboxHeaderInfo(index))
		end
		SetCount(count)
	end,
	SetTradePlayerItem = function(_, index)
		local count = select(3, GetTradePlayerItemInfo(index))
		SetCount(count)
	end,
	SetTradeTargetItem = function(_, index)
		local count = select(3, GetTradeTargetItemInfo(index))
		SetCount(count)
	end,
}

for functionName, hookfunc in pairs (SetItem) do
	hooksecurefunc(GameTooltip, functionName, hookfunc)
end

local OnTooltipSetItem = function(self, ...)
	-- immediately return if the player is interacting with a vendor
	if MerchantFrame:IsShown() then return end
	local link = select(2, self:GetItem())
	if not link then return end
	local vendorPrice = select(11, GetItemInfo(link))
	if vendorPrice then
		if vendorPrice == 0 then
			self:AddLine("No sell price", 255, 255, 255)
			SetCount(nil)
		else
			count = count or 1
			price = GetCoinTextureString(vendorPrice * count)
			self:AddLine(price, 255, 255, 255)
			SetCount(nil)
		end
	end
end

for _, Tooltip in pairs {GameTooltip, ItemRefTooltip} do
	Tooltip:HookScript("OnTooltipSetItem", OnTooltipSetItem)
end