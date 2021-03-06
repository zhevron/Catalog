import json, urllib2

http_headers = {
  "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.9; rv:30.0) Gecko/20100101 Firefox/30.0"
}

class Exporter:
  def adventure(self, data):
    for k, v in enumerate(data["bosses"]):
      data["bosses"][k]["drops"] = []
    return data

  def dungeon(self, data):
    for k, v in enumerate(data["bosses"]):
      data["bosses"][k]["drops"] = self.get_items_by_npc(v)
    return data

  def raid(self, data):
    for k, v in enumerate(data["bosses"]):
      data["bosses"][k]["drops"] = self.get_items_by_npc(v)
    return data

  # Uses the WildHeap API to get item drops from a specified NPC name.
  def get_items_by_npc(self, npc):
    items = []
    url = "https://api.wildheap.com/items?droppedby=" + npc["name"]["enUS"].replace(" ", "%20") + "&limit=100"
    req = urllib2.Request(url, headers = http_headers)
    data = json.load(urllib2.urlopen(req))
    if data["total"] > 0:
      for iteminfo in data["items"]:
        items.append(int(iteminfo["id"]))
    return items
