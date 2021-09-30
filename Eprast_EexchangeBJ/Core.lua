local Core = CreateFrame("Frame", nil, MerchantFrame);
Core:RegisterEvent("ADDON_LOADED");
Core:SetScript("OnEvent", function(self, event, ...) return self[event](self, ...) end);
--
local GetLocale, GetMerchantItemInfo, BuyMerchantItem, GetItemInfo, select, tonumber = GetLocale, GetMerchantItemInfo, BuyMerchantItem, GetItemInfo, select, tonumber;
local GetItemCount = GetItemCount;
--
local Locale = {
	["enGB"]	=	"Usuri Brightcoin",
	["enUS"]	=	"Usuri Brightcoin",
	["ruRU"]	=	"Усури Златоблям",
};
local LocaleError = {
	["enGB"]	=	"You do not have the required items for that purchase.",
	["enUS"]	=	"You do not have the required items for that purchase.",
	["ruRU"]	=	"У вас нет предметов, необходимых для этой покупки.",
};
local NPCName = Locale[GetLocale()];
local ErrorText = LocaleError[GetLocale()];
--
Core.BJ = {49426, 47241, 45624, 40753, 40752};	--	 ItemID (Эмблема льда, Эмблема триумфа, Эмблема завоевания, Эмблема доблести, Эмблема героизма);
local Items = {"Frost", "Triumph", "Conquest", "Valor", "Heroism"};
local SellID		=	2;
local SellID_Text 	= Items[SellID];
local BuyID			=	5;
function Core:Buy(Name, Number) 
	for i = 1, 5 do 
		if Name == GetMerchantItemInfo(i) then 
			BuyMerchantItem(i, Number);
		end 
	end 
end; 
-- 
function Core:OnClick(Number)
	for i = SellID + 1, BuyID do
		local Name = select(1, GetItemInfo(self.BJ[i]));
		self:Buy(Name, Number);
	end;
	self.EditBox:SetText("");
end;
--
local function Initialize(self, level, menuList)
	local info = UIDropDownMenu_CreateInfo()
	if (level or 1) == 1 then
		for i = 1, 4 do
			info.text = Items[i];
			info.checked = Items[i] == SellID_Text;
			info.menuList = i;
			info.hasArrow = true;
			UIDropDownMenu_AddButton(info);
		end
	else
		info.func = self.SetValue
		SellID = menuList;
		for i = menuList + 1, 5 do
			info.text = Items[i];
			info.arg1 = i;
			info.checked = (SellID_Text == Items[SellID]) and (i == BuyID);
			UIDropDownMenu_AddButton(info, level);
		end
	end
end;
--
function Core:CreateEexchangeFrame()
	self:SetPoint("TOPLEFT", MerchantFrame, 70, -35);
	self:SetSize(160, 37);
	self:Hide();
	--
	self.EditBox = CreateFrame("EditBox", nil, self,"InputBoxTemplate");
	self.EditBox:SetSize(35, 25);
	self.EditBox:SetPoint("LEFT", self, 10, 0);
	self.EditBox:SetFont(STANDARD_TEXT_FONT, 10, "OUTLINE");
	self.EditBox:SetAutoFocus(false);
	self.EditBox:SetMaxLetters(3);
	self.EditBox:SetNumeric(true);
	--
	self.Button = CreateFrame("Button", nil, self, "UIPanelButtonTemplate");
	self.Button:SetSize(70, 23);
	self.Button:SetPoint("LEFT", self.EditBox, "RIGHT", 150, 0);
	self.Button:SetText("Exchange");
	self.Button:SetNormalFontObject("GameFontNormalSmall");
	self.Button:SetHighlightFontObject("GameFontHighlightSmall");
	self.Button:SetScript("OnClick", function(self)
		local Number = tonumber(self:GetParent().EditBox:GetText());
		if Number and Number > 0 then
			if GetItemCount(self:GetParent().BJ[SellID]) >= Number then 
				self:GetParent():OnClick(Number);
			else
				UIErrorsFrame:AddMessage("|cffFF0000"..ErrorText.."|r");
			end;
		end;
	end);
	--
	self.dropDown = CreateFrame("FRAME", "Eexchange_DropDownMenu", self, "UIDropDownMenuTemplate");
	self.dropDown:SetPoint("LEFT", self, "RIGHT", -130, -2);
	UIDropDownMenu_SetWidth(self.dropDown, 130);
	UIDropDownMenu_SetText(self.dropDown, Items[SellID].." / " ..Items[BuyID]);
	UIDropDownMenu_Initialize(self.dropDown, Initialize);
	function self.dropDown:SetValue(newValue)
		BuyID = newValue;
		SellID_Text = Items[SellID];
		UIDropDownMenu_SetText(Core.dropDown, Items[SellID].." / " ..Items[BuyID]);
		CloseDropDownMenus();
	end;
end;
--
function Core:ADDON_LOADED()
	self:CreateEexchangeFrame();
	self:RegisterEvent("MERCHANT_SHOW");
	self:RegisterEvent("MERCHANT_CLOSED");
	self:UnregisterEvent("ADDON_LOADED");
end;
--
function Core:MERCHANT_SHOW()
	if MerchantNameText:GetText() == NPCName then self:Show(); end;
end;
--
function Core:MERCHANT_CLOSED()
	if self:IsShown() then 
		self:Hide(); 
		self.EditBox:SetText("");
		SellID = 2;
		SellID_Text = Items[SellID];
		BuyID =	5;
		UIDropDownMenu_SetText(self.dropDown, Items[SellID].." / " ..Items[BuyID]);
	end;
end;