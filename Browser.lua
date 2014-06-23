require "GameLib"
require "Item"
require "Window"

Catalog.Browser = {}

Catalog.Browser.ItemColor = {
  [Item.CodeEnumItemQuality.Inferior] = ApolloColor.new("ItemQuality_Inferior"),
  [Item.CodeEnumItemQuality.Average] = ApolloColor.new("ItemQuality_Average"),
  [Item.CodeEnumItemQuality.Good] = ApolloColor.new("ItemQuality_Good"),
  [Item.CodeEnumItemQuality.Excellent] = ApolloColor.new("ItemQuality_Excellent"),
  [Item.CodeEnumItemQuality.Superb] = ApolloColor.new("ItemQuality_Superb"),
  [Item.CodeEnumItemQuality.Legendary] = ApolloColor.new("ItemQuality_Legedary"),
  [Item.CodeEnumItemQuality.Artifact] = ApolloColor.new("ItemQuality_Artifact")
}

function Catalog.Browser:Init()
  self.Xml = XmlDoc.CreateFromFile("Forms/Browser.xml")
  self.Xml:RegisterCallback("OnDocumentReady", self)
end

function Catalog.Browser:OnDocumentReady()
  if self.Xml == nil then
    Apollo.AddAddonErrorText(Catalog, "Could not load the Catalog browser")
    return
  end
  self.Window = Apollo.LoadForm(self.Xml, "CatalogBrowser", nil, self)
  self.Window:FindChild("HeaderText"):SetText("Catalog v"..Catalog.Version)
  self:Close()
  self:Localize()
  self:BuildLocationTypeList()
end

function Catalog.Browser:Open()
  if self.Window and self.Window:IsValid() then
    local left = Catalog.Options.Position.X
    local top = Catalog.Options.Position.Y
    local form = Apollo.LoadForm(self.Xml, "CatalogBrowser", nil, self)
    local _, _, right, bottom = form:GetAnchorOffsets()
    form:Destroy()
    self.Window:SetAnchorOffsets(left, top, left + right, top + bottom)
    if not Catalog.Options.Locked then
      self.Window:AddStyle("Moveable")
    else
      self.Window:RemoveStyle("Moveable")
    end
    self.Window:Show(true)
  end
end

function Catalog.Browser:Close()
  if self.Window and self.Window:IsValid() then
    local left, top = self.Window:GetAnchorOffsets()
    Catalog.Options.Position.X = left
    Catalog.Options.Position.Y = top
    self.Window:Show(false)
  end
end

function Catalog.Browser:Localize()
  local locale = Catalog:GetLocale()
  self.Window:FindChild("VeteranText"):SetText(locale["veteran"])
end

function Catalog.Browser:BuildLocationTypeList()
  local locale = Catalog:GetLocale()
  local types = { "adventure", "dungeon", "raid" }
  local list = self.Window:FindChild("LocationTypeList")
  list:DestroyChildren()
  for _, type in ipairs(types) do
    local name = Catalog.Utility:Capitalize(locale[type][2])
    local form = Apollo.LoadForm(self.Xml, "LocationType", list, self)
    form:SetData(type)
    form:FindChild("LocationTypeText"):SetText(name)
    self:BuildLocationList(type, form)
    local left, top, right, bottom = form:GetAnchorOffsets()
    form:SetAnchorOffsets(left, top, right, bottom + 2)
  end
  list:ArrangeChildrenVert()
end

function Catalog.Browser:BuildLocationList(type, parent)
  local list = parent:FindChild("LocationList")
  list:DestroyChildren()
  local locations = {}
  for _, location in pairs(Catalog.Database) do
    if location.type == type then
      local tbl = Catalog.Utility:TableCopyRecursive(location)
      tbl.name = location.name[Catalog.Options.Locale]
      table.insert(locations, tbl)
    end
  end
  for name, location in Catalog.Utility:TableSortPairs(locations, "name") do
    local form = Apollo.LoadForm(self.Xml, "Location", list, self)
    form:SetData(location)
    form:FindChild("LocationText"):SetText(name)
    self:BuildBossList(location, form)
  end
  self:SizeToFit(list)
  list:ArrangeChildrenVert()
end

function Catalog.Browser:BuildBossList(location, parent)
  local list = parent:FindChild("BossList")
  list:DestroyChildren()
  for _, boss in ipairs(location.bosses) do
    local form = Apollo.LoadForm(self.Xml, "Boss", list, self)
    form:SetData(boss)
    form:FindChild("BossText"):SetText(boss.name[Catalog.Options.Locale])
  end
  self:SizeToFit(list)
  list:ArrangeChildrenVert()
end

function Catalog.Browser:BuildItemList(boss)
  local locale = Catalog:GetLocale()
  local list = self.Window:FindChild("ItemList")
  list:DestroyChildren()
  list:SetData(boss)
  local mode = "normal"
  if self.Window:FindChild("VeteranButton"):IsChecked() then
    mode = "veteran"
  end
  for i = Item.CodeEnumItemQuality.Legendary, Item.CodeEnumItemQuality.Inferior, -1 do
    for _, id in ipairs(boss[mode]) do
      local item = Item.GetDataFromId(id)
      if item ~= nil and item:GetItemQuality() == i then
        local form = Apollo.LoadForm(self.Xml, "Item", list, self)
        form:SetData(item)
        form:FindChild("ItemIcon"):SetSprite(item:GetIcon())
        form:FindChild("ItemText"):SetText(item:GetName())
        form:FindChild("ItemText"):SetTextColor(self.ItemColor[item:GetItemQuality()])
        form:FindChild("ItemLevelText"):SetText(locale["level"].." "..item:GetRequiredLevel())
        form:FindChild("ItemTypeText"):SetText(item:GetItemTypeName())
      end
    end
  end
  list:ArrangeChildrenVert()
end

function Catalog.Browser:SizeToFit(list)
  if #list:GetChildren() > 0 then
    local height = 0
    for _, child in pairs(list:GetChildren()) do
      local _, _, _, bottom = child:GetAnchorOffsets()
      height = height + bottom
    end
    local left, top, right, bottom = list:GetAnchorOffsets()
    list:SetAnchorOffsets(left, top, right, bottom + height)
  end
end

function Catalog.Browser:Expand(list, sublist)
  local left, top, right, bottom = list:GetAnchorOffsets()
  local _, _, _, height = sublist:GetAnchorOffsets()
  list:SetAnchorOffsets(left, top, right, bottom + height)
end

function Catalog.Browser:Collapse(list, sublist)
  local left, top, right, bottom = list:GetAnchorOffsets()
  local _, _, _, height = sublist:GetAnchorOffsets()
  list:SetAnchorOffsets(left, top, right, bottom - height)
end

function Catalog.Browser:OnLocationTypeOpen(handler, control)
  self:Expand(control:GetParent(), control:GetParent():FindChild("LocationList"))
  self.Window:FindChild("LocationTypeList"):ArrangeChildrenVert()
end

function Catalog.Browser:OnLocationTypeClose(handler, control)
  self:Collapse(control:GetParent(), control:GetParent():FindChild("LocationList"))
  self.Window:FindChild("LocationTypeList"):ArrangeChildrenVert()
end

function Catalog.Browser:OnLocationOpen(handler, control)
  self:Expand(control:GetParent(), control:GetParent():FindChild("BossList"))
  self:Expand(control:GetParent():GetParent(), control:GetParent():FindChild("BossList"))
  self:Expand(control:GetParent():GetParent():GetParent(), control:GetParent():FindChild("BossList"))
  control:GetParent():GetParent():ArrangeChildrenVert()
  self.Window:FindChild("LocationTypeList"):ArrangeChildrenVert()
end

function Catalog.Browser:OnLocationClose(handler, control)
  self:Collapse(control:GetParent(), control:GetParent():FindChild("BossList"))
  self:Collapse(control:GetParent():GetParent(), control:GetParent():FindChild("BossList"))
  self:Collapse(control:GetParent():GetParent():GetParent(), control:GetParent():FindChild("BossList"))
  control:GetParent():GetParent():ArrangeChildrenVert()
  self.Window:FindChild("LocationTypeList"):ArrangeChildrenVert()
end

function Catalog.Browser:OnBossSelect(handler, control)
  self.Window:FindChild("ItemListHeaderText"):SetText(control:GetParent():GetData().name[Catalog.Options.Locale])
  self:BuildItemList(control:GetParent():GetData())
end

function Catalog.Browser:OnMouseButtonDown(handler, control, button)
  if button ~= GameLib.CodeEnumInputMouse.Right then
    return
  end
  if Apollo.IsControlKeyDown() then
    if control:GetParent():GetData():GetHousingDecorInfoId() ~= nil then
      Event_FireGenericEvent("DecorPreviewOpen", control:GetParent():GetData():GetHousingDecorInfoId())
    else
      Event_FireGenericEvent("ShowItemInDressingRoom", control:GetParent():GetData())
    end
  elseif Apollo.IsShiftKeyDown() then
    Event_FireGenericEvent("ItemLink", control:GetParent():GetData())
  end
end

function Catalog.Browser:OnModeChange(handler, control)
  self:BuildItemList(self.Window:FindChild("ItemList"):GetData())
end

function Catalog.Browser:OnToggleSettings(handler, control)
  if control:IsChecked() then
    Catalog.Settings:Open()
  else
    Catalog.Settings:Close()
  end
end

function Catalog.Browser:OnGenerateTooltip(handler, control)
  local equipped = control:GetParent():GetData():GetEquippedItemForItemType()
  Tooltip.GetItemTooltipForm(self, control, control:GetParent():GetData(), {
    bPrimary = true,
    bSelling = false,
    itemCompare = equipped
  })
end
