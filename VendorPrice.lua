local debugMode = false
if debugMode then print("VendorPrice: Debug Mode loaded.") end

local count = nil
local SetCount = function(itemCount) count = itemCount if debugMode then print(count) end end
local ResetCount = function() count = nil end

local SetItemTable = {
	SetBagItem = function(_, bagID, slot)
		SetCount(select(2, GetContainerItemInfo(bagID, slot)))
	end,
	SetAuctionItem = function(_, type, index)
		SetCount(select(3, GetAuctionItemInfo(type, index)))
	end,
	SetAuctionSellItem = function(_)
		SetCount(select(3, GetAuctionSellItemInfo()))
	end,
	SetQuestLogItem = function(_, _, index)
		SetCount(select(3, GetQuestLogRewardInfo(index)))
	end,
	SetInboxItem = function(_, index, itemIndex)
		if itemIndex then
			SetCount(select(4, GetInboxItem(index, itemIndex)))
		else
			SetCount(select(1, select(14, GetInboxHeaderInfo(index))))
		end
	end,
	SetSendMailItem = function(_, index)
		SetCount(select(4, GetSendMailItem(index)))
	end,
	SetTradePlayerItem = function(_, index)
		SetCount(select(3, GetTradePlayerItemInfo(index)))
	end,
	SetTradeTargetItem = function(_, index)
		SetCount(select(3, GetTradeTargetItemInfo(index)))
	end,
}

for functionName, hookfunc in pairs (SetItemTable) do
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
			ResetCount()
		else
			count = count or 1
			-- price = GetCoinTextureString(vendorPrice * count)
			self:AddLine(GetCoinTextureString(vendorPrice * count), 255, 255, 255)
			ResetCount()
		end
	end
end

for _, Tooltip in pairs {GameTooltip, ItemRefTooltip} do
	Tooltip:HookScript("OnTooltipSetItem", OnTooltipSetItem)
end