Catalog.Wishlist = {}

Catalog.Wishlist.RecentAlerts = {}

function Catalog.Wishlist:Init()
  self.Xml = XmlDoc.CreateFromFile("Forms/Wishlist.xml")
  self.Xml:RegisterCallback("OnDocumentReady", self)
end

function Catalog.Wishlist:OnDocumentReady()
  if self.Xml == nil then
    Apollo.AddAddonErrorText(Catalog, "Could not load the Catalog wishlist window")
    return
  end
  self.Window = Apollo.LoadForm(self.Xml, "CatalogWishlist", nil, self)
  self:Close()
  self:Localize()
end

function Catalog.Wishlist:Open()
  if self.Window and self.Window:IsValid() then
    Catalog.Settings:Close()
    self:Position()
    self:BuildItemList()
    self.Window:Show(true)
  end
end

function Catalog.Wishlist:Close()
  if self.Window and self.Window:IsValid() then
    Catalog.Browser.Window:FindChild("OpenWishlistButton"):SetCheck(false)
    self.Window:Show(false)
  end
end

function Catalog.Wishlist:Localize()
  local locale = Catalog:GetLocale()
end

function Catalog.Wishlist:Position()
  local _, top, right = Catalog.Browser.Window:GetAnchorOffsets()
  local offset = (right - 15) * (1 - Catalog.Browser.Window:GetScale())
  local form = Apollo.LoadForm(self.Xml, "CatalogWishlist", nil, self)
  local _, _, width, height = form:GetAnchorOffsets()
  form:Destroy()
  self.Window:SetAnchorOffsets(right - 15 - offset, top, right - 15 - offset + width, top + height)
  self.Window:SetScale(Catalog.Browser.Window:GetScale())
end

function Catalog.Wishlist:BuildItemList()
  local list = self.Window:FindChild("ItemList")
  list:DestroyChildren()
  for _, i in pairs(Catalog.Options.Character.Wishlist) do
    local item = Item.GetDataFromId(i["Id"])
    local form = Apollo.LoadForm(self.Xml, "Item", list, self)
    form:SetData(item)
    form:FindChild("ItemIcon"):SetSprite(item:GetIcon())
    form:FindChild("ItemText"):SetText(item:GetName())
    form:FindChild("ItemText"):SetTextColor(Catalog.Browser.ItemColor[item:GetItemQuality()])
    local tooltip = ""
    for _, drop in pairs(Catalog.Utility:FindDropLocations(i["Id"])) do
      tooltip = tooltip..drop["Boss"].."\n"..drop["Location"].."\n\n"
    end
    form:FindChild("InfoButton"):SetTooltip(tooltip)
  end
  list:ArrangeChildrenVert()
end

function Catalog.Wishlist:OnWishlistRemove(handler, control)
  local item = control:GetParent():GetData()
  local info = item:GetDetailedInfo()
  for k, i in ipairs(Catalog.Options.Character.Wishlist) do
    if i["Id"] == info.tPrimary.nId then
      table.remove(Catalog.Options.Character.Wishlist, k)
    end
  end
  self:BuildItemList()
  Catalog.Browser:BuildItemList(Catalog.Browser.Window:FindChild("ItemList"):GetData())
end

function Catalog.Wishlist:OnGroupLoot()
  for _, roll in pairs(GameLib.GetLootRolls()) do
    self:OnItemLooted(roll.itemDrop, 1)
  end
end

function Catalog.Wishlist:OnItemLooted(item, count)
  if item ~= nil and count > 0 then
    if item:GetItemQuality() >= Item.CodeEnumItemQuality.Good then
      Print("Catalog: Looted "..item:GetName().." x"..count)
    end
    local info = item:GetDetailedInfo()
    local found = nil
    for _, i in pairs(Catalog.Options.Character.Wishlist) do
      if i["Id"] == info.tPrimary.nId then
        found = i
      end
    end
    if found ~= nil and found["Alert"] then
      local last = self.RecentAlerts[tostring(found["Id"])]
      if last ~= nil and (last + 300) < os.time() then
        -- local form = Apollo.LoadForm(self.Xml, "ItemDropAlert", nil, self)
        -- form:FindChild("ItemIcon"):SetSprite(item:GetIcon())
        -- form:FindChild("ItemName"):SetText(item:GetName())
        -- form:FindChild("ItemName"):SetTextColor(Catalog.Browser.ItemColor[item:GetItemQuality()])
        -- ApolloTimer.Create(5, false, "Close", form)
        self.RecentAlerts[tostring(found["Id"])] = os.time()
      end
    end
  end
end

function Catalog.Wishlist:OnGenerateTooltip(handler, control)
  Catalog.Browser:OnGenerateTooltip(handler, control)
end
