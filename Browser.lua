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
  [Item.CodeEnumItemQuality.Legendary] = ApolloColor.new("ItemQuality_Legendary"),
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
  self.Window:FindChild("AdventureButton"):SetData("adventure")
  self.Window:FindChild("DungeonButton"):SetData("dungeon")
  self.Window:FindChild("RaidButton"):SetData("raid")
  self.Window:FindChild("NormalButton"):SetCheck(true)
  self:Close()
end

function Catalog.Browser:Open()
  if self.Window and self.Window:IsValid() then
    local left = Catalog.Options.Position.X
    local top = Catalog.Options.Position.Y
    local form = Apollo.LoadForm(self.Xml, "CatalogBrowser", nil, self)
    local _, _, right, bottom = form:GetAnchorOffsets()
    form:Destroy()
    self.Window:SetAnchorOffsets(left, top, left + right, top + bottom)
    self.Window:SetScale(Catalog.Options.Scale)
    if Catalog.Options.Locked then
      self.Window:RemoveStyle("Moveable")
    end
    self.Window:Show(true)
  end
end

function Catalog.Browser:Close()
  if self.Window and self.Window:IsValid() then
    Catalog.Settings:Close()
    Catalog.Wishlist:Close()
    self.Window:Show(false)
  end
end

function Catalog.Browser:Toggle()
  if self.Window and self.Window:IsValid() then
    if self.Window:IsShown() then
      self:Close()
    else
      self:Open()
    end
  end
end

function Catalog.Browser:BuildSubcategoryList()
  local list = self.Window:FindChild("SubcategoryList")
  list:DestroyChildren()
  local entries = {}
  for _, entry in pairs(Catalog.Database) do
    if entry.type == self.Window:FindChild("CategoryButton"):GetData() then
      local tbl = Catalog.Utility:TableCopyRecursive(entry)
      tbl.name = entry.name[Catalog.Options.Locale]
      table.insert(entries, tbl)
    end
  end
  for name, entry in Catalog.Utility:TableSortPairs(entries, "name") do
    local form = Apollo.LoadForm(self.Xml, "Subcategory", list, self)
    form:SetText(name)
    form:SetData(entry)
  end
  list:ArrangeChildrenVert()
  self:SizeToFit(list, 3)
end

function Catalog.Browser:BuildBossList(subcategory)
  local list = self.Window:FindChild("BossList")
  list:DestroyChildren()
  if subcategory == nil then
    return
  end
  for _, boss in ipairs(subcategory.bosses) do
    local form = Apollo.LoadForm(self.Xml, "Boss", list, self)
    form:SetData(boss)
    form:FindChild("BossText"):SetText(boss.name[Catalog.Options.Locale])
  end
  list:ArrangeChildrenVert()
end

function Catalog.Browser:BuildItemList(boss)
  local locale = Catalog:GetLocale()
  local list = self.Window:FindChild("ItemList")
  list:DestroyChildren()
  if boss == nil then
    return
  end
  list:SetData(boss)
  local veteran = self.Window:FindChild("ModeButton"):IsChecked()
  local items = {}
  for i = Item.CodeEnumItemQuality.Legendary, Item.CodeEnumItemQuality.Good, -1 do
    for _, id in pairs(boss.drops) do
      local item = Item.GetDataFromId(id)
      if item ~= nil and item:GetItemQuality() == i then
        if boss.veteran and veteran and item:GetRequiredLevel() < 50 then
          -- Ignore it. Not a veteran drop.
        elseif boss.veteran and not veteran and item:GetRequiredLevel() >= 50 then
          -- Ignore it. Not a normal drop.
        else
          if items[item:GetItemType()] == nil then
            items[item:GetItemType()] = {}
          end
          table.insert(items[item:GetItemType()], item)
        end
      end
    end
  end
  for type, tbl in pairs(items) do
    local formType = Apollo.LoadForm(self.Xml, "ItemType", list, self)
    formType:SetData({})
    local rows = math.ceil(#tbl / 2)
    for row = 1, rows do
      local form = Apollo.LoadForm(self.Xml, "ItemRow", list, self)
      for i = 1, 2 do
        local num = ((row - 1) * 2) + i
        if num <= #tbl then
          local item = tbl[num]
          local info = item:GetDetailedInfo()
          formType:FindChild("ItemTypeButton"):SetText(item:GetItemTypeName())
          formType:FindChild("ItemTypeButton"):SetData(item:GetItemType())
          formType:FindChild("StatusIcon"):SetData(true)
          form:SetName("CatalogItems_"..item:GetItemType().."_"..row)
          form:FindChild("Item"..i):SetData(item)
          form:FindChild("Item"..i):FindChild("ItemIcon"):SetSprite(item:GetIcon())
          form:FindChild("Item"..i):FindChild("ItemText"):SetText(item:GetName())
          form:FindChild("Item"..i):FindChild("ItemText"):SetTextColor(self.ItemColor[item:GetItemQuality()])
          local found = false
          for _, i in pairs(Catalog.WishlistItems) do
            if i["Id"] == info.tPrimary.nId then
              found = true
            end
          end
          form:FindChild("Item"..i):FindChild("WishlistButton"):SetCheck(found)
          form:FindChild("Item"..i):Show(true)
        else
          form:FindChild("Item"..i):Show(false)
        end
      end
      local forms = formType:GetData()
      table.insert(forms, form:GetName())
      formType:SetData(forms)
      local status = Catalog.Options.ItemTypes[tostring(formType:FindChild("ItemTypeButton"):GetData())]
      if status ~= nil then
        form:Show(status)
        formType:FindChild("StatusIcon"):SetData(status)
        if status then
          formType:FindChild("StatusIcon"):SetSprite("achievements:sprAchievements_Icon_Complete")
        else
          formType:FindChild("StatusIcon"):SetSprite("ClientSprites:LootCloseBox_Holo")
          formType:Show(self.Window:FindChild("ShowHiddenButton"):IsChecked())
        end
      end
    end
  end
  list:ArrangeChildrenVert()
end

function Catalog.Browser:SizeToFit(list, offset)
  offset = offset or 0
  if #list:GetChildren() > 0 then
    local height = 0
    for _, child in pairs(list:GetChildren()) do
      local _, top, _, bottom = child:GetAnchorOffsets()
      height = height + (bottom - top)
    end
    local left, top, right = list:GetAnchorOffsets()
    list:SetAnchorOffsets(left, top, right, top + height + offset)
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

function Catalog.Browser:OnToggleItemType(handler, control)
  local status = not control:GetParent():FindChild("StatusIcon"):GetData()
  local type = tostring(control:GetParent():FindChild("ItemTypeButton"):GetData())
  control:GetParent():FindChild("StatusIcon"):SetData(status)
  Catalog.Options.ItemTypes[type] = status
  for _, name in pairs(control:GetParent():GetData()) do
    self.Window:FindChild(name):Show(status)
  end
  self.Window:FindChild("ItemList"):ArrangeChildrenVert()
  if status then
    control:GetParent():FindChild("StatusIcon"):SetSprite("achievements:sprAchievements_Icon_Complete")
  else
    control:GetParent():FindChild("StatusIcon"):SetSprite("ClientSprites:LootCloseBox_Holo")
  end
end

function Catalog.Browser:OnWishlistCheck(handler, control)
  Catalog.Wishlist:Open()
end

function Catalog.Browser:OnWishlistUncheck(handler, control)
  Catalog.Wishlist:Close()
end

function Catalog.Browser:OnWishlistAdd(handler, control)
  local item = control:GetParent():GetData()
  local info = item:GetDetailedInfo()
  table.insert(Catalog.WishlistItems, {
    ["Id"] = info.tPrimary.nId,
    ["Alert"] = true
  })
  if Catalog.Wishlist.Window:IsShown() then
    Catalog.Wishlist:BuildItemList()
  end
end

function Catalog.Browser:OnWishlistRemove(handler, control)
  local item = control:GetParent():GetData()
  local info = item:GetDetailedInfo()
  for k, i in pairs(Catalog.WishlistItems) do
    if i["Id"] == info.tPrimary.nId then
      table.remove(Catalog.WishlistItems, k)
    end
  end
  if Catalog.Wishlist.Window:IsShown() then
    Catalog.Wishlist:BuildItemList()
  end
end

function Catalog.Browser:OnCategoryListOpen(handler, control)
  self.Window:FindChild("CategoryList"):Show(true)
end

function Catalog.Browser:OnCategoryListClose(handler, control)
  self.Window:FindChild("CategoryList"):Show(false)
end

function Catalog.Browser:OnCategoryCheck(handler, control)
  self.Window:FindChild("CategoryButton"):SetText(control:GetText())
  self.Window:FindChild("CategoryButton"):SetData(control:GetData())
  self.Window:FindChild("CategoryButton"):SetCheck(false)
  self.Window:FindChild("SubcategoryButton"):SetText("")
  self.Window:FindChild("SubcategoryButton"):SetData(nil)
  self.Window:FindChild("CategoryList"):Show(false)
  self.Window:FindChild("ModeText"):Show(false)
  self.Window:FindChild("ModeButton"):Show(false)
  self:BuildSubcategoryList()
  self:BuildBossList(nil)
  self:BuildItemList(nil)
end

function Catalog.Browser:OnSubcategoryListOpen(handler, control)
  self.Window:FindChild("SubcategoryList"):Show(true)
end

function Catalog.Browser:OnSubcategoryListClose(handler, control)
  self.Window:FindChild("SubcategoryList"):Show(false)
end

function Catalog.Browser:OnSubcategoryCheck(handler, control)
  self.Window:FindChild("SubcategoryButton"):SetText(control:GetText())
  self.Window:FindChild("SubcategoryButton"):SetData(control:GetData())
  self.Window:FindChild("SubcategoryButton"):SetCheck(false)
  self.Window:FindChild("SubcategoryList"):Show(false)
  self.Window:FindChild("ModeText"):Show(false)
  self.Window:FindChild("ModeButton"):Show(false)
  self:BuildBossList(control:GetData())
  self:BuildItemList(nil)
end

function Catalog.Browser:OnModeChange(handler, control)
  self:BuildItemList(self.Window:FindChild("ItemList"):GetData())
end

function Catalog.Browser:OnBossSelect(handler, control)
  local boss = control:GetParent():GetData()
  self:BuildItemList(boss)
  self.Window:FindChild("ModeText"):Show(boss.veteran)
  self.Window:FindChild("ModeButton"):Show(boss.veteran)
end

function Catalog.Browser:OnMouseButtonDown(handler, control, button)
  if button ~= GameLib.CodeEnumInputMouse.Right then
    return
  end
  local item = control:GetParent():GetData()
  if Apollo.IsControlKeyDown() then
    if item:GetHousingDecorInfoId() ~= nil and item:GetHousingDecorInfoId() ~= 0 then
      Event_FireGenericEvent("DecorPreviewOpen", item:GetHousingDecorInfoId())
    else
      Event_FireGenericEvent("ShowItemInDressingRoom", item)
    end
  elseif Apollo.IsShiftKeyDown() then
    Event_FireGenericEvent("ItemLink", item)
  end
end

function Catalog.Browser:OnToggleHidden(handler, control)
  self:BuildItemList(self.Window:FindChild("ItemList"):GetData())
end

function Catalog.Browser:OnToggleSettings(handler, control)
  if control:IsChecked() then
    Catalog.Settings:Open()
  else
    Catalog.Settings:Close()
  end
end

function Catalog.Browser:OnWindowMove(handler, control)
  local left, top = self.Window:GetAnchorOffsets()
  Catalog.Options.Position.X = left
  Catalog.Options.Position.Y = top
  Catalog.Settings:Position()
end

function Catalog.Browser:OnGenerateTooltip(handler, control)
  local item = control:GetParent():GetData()
  local equipped = item:GetEquippedItemForItemType()
  Tooltip.GetItemTooltipForm(self, control, item, {
    bPrimary = true,
    bSelling = false,
    itemCompare = equipped
  })
end
