Catalog.Wishlist = {}

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
  for _, id in pairs(Catalog.WishlistItems) do
    local item = Item.GetDataFromId(id)
    local form = Apollo.LoadForm(self.Xml, "Item", list, self)
    form:SetData(item)
    form:FindChild("ItemIcon"):SetSprite(item:GetIcon())
    form:FindChild("ItemText"):SetText(item:GetName())
    form:FindChild("ItemText"):SetTextColor(Catalog.Browser.ItemColor[item:GetItemQuality()])
    local tooltip = ""
    for _, drop in pairs(Catalog.Utility:FindDropLocations(id)) do
      tooltip = tooltip..drop["Boss"].."\n"..drop["Location"].."\n\n"
    end
    form:FindChild("InfoButton"):SetTooltip(tooltip)
  end
  list:ArrangeChildrenVert()
end

function Catalog.Wishlist:OnWishlistRemove(handler, control)
  local item = control:GetParent():GetData()
  local info = item:GetDetailedInfo()
  for k, id in ipairs(Catalog.WishlistItems) do
    if id == info.tPrimary.nId then
      table.remove(Catalog.WishlistItems, k)
    end
  end
  self:BuildItemList()
  Catalog.Browser:BuildItemList(Catalog.Browser.Window:FindChild("ItemList"):GetData())
end

function Catalog.Wishlist:OnGenerateTooltip(handler, control)
  Catalog.Browser:OnGenerateTooltip(handler, control)
end
