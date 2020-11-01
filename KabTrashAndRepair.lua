local stop = true
local list = {}

local function SellGray()
  if stop then return end
  for bag=0,4 do
    for slot=0,GetContainerNumSlots(bag) do
      if stop then return end
      local link = GetContainerItemLink(bag, slot)
      if link and select(3, GetItemInfo(link)) == 0 and not list["b"..bag.."s"..slot] then
        --print("Selling",link,"bag",bag,"slot",slot)
        --print("Sold",link)
        list["b"..bag.."s"..slot] = true
        UseContainerItem(bag, slot)
        C_Timer.After(0.2, SellGray)
        return
      end
    end
  end
end

local function Repair()
	local isRepairer = CanMerchantRepair();
	if ( isRepairer ) then
		local repairAllCost, canRepair = GetRepairAllCost();
		local playerMoney = GetMoney();
		local inGuild = IsInGuild()
		local hasGuildPermissions = CanGuildBankRepair()

		if repairAllCost > 0 then
			if inGuild then
				local withdrawLimit = GetGuildBankWithdrawMoney()
				if withdrawLimit > GetGuildBankMoney() then
					withdrawLimit = GetGuildBankMoney()
				end
				if withdrawLimit > repairAllCost and hasGuildPermissions then
					RepairAllItems(1)
					local TotalValue = repairAllCost;
					local TGold = tonumber(string.sub(TotalValue,1,-5)) if TGold == nil or TGold == 0 then TGold = "" else TGold = (TGold.."g, ") end
					local TSilver = tonumber(string.sub(TotalValue,-4,-3)) if TSilver == nil or TSilver == 0 then TSilver = "" else TSilver = (TSilver.."s, ") end
					local TCopper = tonumber(string.sub(TotalValue,-2,-1)) if TCopper == nil or TCopper == 0 then TCopper = "" else TCopper = (TCopper.."c") end
					DEFAULT_CHAT_FRAME:AddMessage("Guild paid repair costs of " ..TGold..TSilver..TCopper.. ".", 1, 1, 0);
					return
				end
			end

			if not canRepair then
				return;
			elseif ( canRepair ) then
				if ( playerMoney > repairAllCost ) then
					RepairAllItems();
					local TotalValue = repairAllCost;
					local TGold = tonumber(string.sub(TotalValue,1,-5)) if TGold == nil or TGold == 0 then TGold = "" else TGold = (TGold.."g, ") end
					local TSilver = tonumber(string.sub(TotalValue,-4,-3)) if TSilver == nil or TSilver == 0 then TSilver = "" else TSilver = (TSilver.."s, ") end
					local TCopper = tonumber(string.sub(TotalValue,-2,-1)) if TCopper == nil or TCopper == 0 then TCopper = "" else TCopper = (TCopper.."c") end
					DEFAULT_CHAT_FRAME:AddMessage("You paid repair costs of " ..TGold..TSilver..TCopper.. ".", 1, 1, 0);
				elseif ( playerMoney <= repairAllCost ) then
					DEFAULT_CHAT_FRAME:AddMessage("Not enough money.", 1, 0, 0);
				end
			end

		else
			DEFAULT_CHAT_FRAME:AddMessage("No repairs needed.", 0, 1, 0);
		end
	end
end

local function OnEvent(self,event)
  if event == "MERCHANT_SHOW" then
    stop = false
    wipe(list)
    SellGray()
	Repair()
  elseif event == "MERCHANT_CLOSED" then
    stop = true
  end
end

local eventHandler = CreateFrame("Frame")
eventHandler:RegisterEvent("MERCHANT_SHOW")
eventHandler:RegisterEvent("MERCHANT_CLOSED")
eventHandler:SetScript("OnEvent", OnEvent)