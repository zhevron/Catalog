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
    self.Window:Show(true)
  end
end

function Catalog.Wishlist:Close()
  if self.Window and self.Window:IsValid() then
    Catalog.Browser.Window:FindChild("WishlistButton"):SetCheck(false)
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
  self.Window:SetAnchorOffsets(right - 15 - offset, top, right - 15 -offset + width, top + height)
  self.Window:SetScale(Catalog.Browser.Window:GetScale())
end
