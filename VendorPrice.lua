local count = nil
local SetCount = function(itemCount) count = itemCount end

local SetItem = {
	SetAuctionItem = function(_, type, index)
		local count = select(3, GetAuctionItemInfo(type, index))
		SetCount(count)
	end,
	SetAuctionSellItem = function(_)
		local count = select(3, GetAuctionSellItemInfo())
		SetCount(count)
	end,
	SetBagItem = function(_, bagID, slot)
		local count = select(2, GetContainerItemInfo(bagID, slot))
		SetCount(count)
	end,
	SetInventoryItem = function(_, unit, slot)
		if type(slot) ~= "number" or slot < 0 then return end
		local count = 1
		if slot < 20 or slot > 39 and slot < 68 then
			count = GetInventoryItemCount(unit, slot)
		end
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
		local count, itemID
		if itemIndex then
			count = select(4, GetInboxItem(index, itemIndex))
		else
			count, itemID = select(14, GetInboxHeaderInfo(index))
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
		else
			count = count or 1
			price = GetCoinTextureString(vendorPrice * count)
			self:AddLine(price, 255, 255, 255)
		end
	end
end

for _, Tooltip in pairs {GameTooltip, ItemRefTooltip} do
	Tooltip:HookScript("OnTooltipSetItem", OnTooltipSetItem)
end