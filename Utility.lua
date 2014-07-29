if not Catalog then
  Catalog = {}
end

Catalog.Utility = {}

function Catalog.Utility:Capitalize(str)
  return string.gsub(tostring(str), "^%l", string.upper)
end

function Catalog.Utility:TableSortPairs(tbl, key)
  local keys = {}
  for _, v in pairs(tbl) do
    if v[key] ~= nil then
      table.insert(keys, v[key])
    end
  end
  table.sort(keys)
  local i = 0
  local iterator = function()
    i = i + 1
    if keys[i] ~= nil then
      for _, v in pairs(tbl) do
        if v[key] == keys[i] then
          return keys[i], v
        end
      end
      return nil
    else
      return nil
    end
  end
  return iterator
end

function Catalog.Utility:TableCopyRecursive(source, destination)
  destination = destination or {}
  for k, v in pairs(source) do
    if type(k) ~= "table" then
      if type(v) ~= "table" then
        destination[k] = v
      else
        destination[k] = self:TableCopyRecursive(v, destination[k])
      end
    end
  end
  return destination
end
