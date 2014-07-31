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
    self.Window:Show(true)
  end
end

function Catalog.Wishlist:Close()
  if self.Window and self.Window:IsValid() then
    self.Window:Show(false)
  end
end

function Catalog.Wishlist:Localize()
  local locale = Catalog:GetLocale()
end
