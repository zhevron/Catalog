import sys

from splinter import Browser
browser = Browser('phantomjs')

items = {}

class ItemInfo:
  def __init__(self):
    self.id = 0
    self.name = ""
    self.level = 0
    self.ilevel = 0

def parse_npc(id, max_level = 10000):
  global browser
  browser.visit("http://www.jabbithole.com/npcs/" + id)
  parse_drops(max_level)
  pages = num_pages()
  for i in range(1, pages):
    go_to_page(i)
    parse_drops(max_level)

def num_pages():
  global browser
  paginate = browser.find_by_id("DataTables_Table_0_paginate")[0]
  span = paginate.find_by_tag("span")[0]
  return len(span.find_by_tag("a"))

def go_to_page(page):
  global browser
  paginate = browser.find_by_id("DataTables_Table_0_paginate")[0]
  span = paginate.find_by_tag("span")[0]
  span.find_by_tag("a")[page].click()
  while not browser.is_element_present_by_id("DataTables_Table_0"):
    continue

def parse_drops(max_level):
  global browser
  global items
  table = browser.find_by_id("DataTables_Table_0")[0]
  tbody = table.find_by_tag("tbody")[0]
  for row in tbody.find_by_tag("tr"):
    item = ItemInfo()
    item.id = int(row.find_by_tag("a")[0]["href"].split("-")[-2])
    item.name = row.find_by_tag("a")[1].text
    item.level = int(row.find_by_tag("td")[4].text)
    item.ilevel = int(row.find_by_tag("td")[5].text)
    if not item.id in items and item.level <= max_level:
      items[item.id] = item

if len(sys.argv) < 2:
  print "Usage: %s <npc id> [max level req]" % sys.argv[0]
else:
  if len(sys.argv) > 2:
    parse_npc(sys.argv[1], int(sys.argv[2]))
  else:
    parse_npc(sys.argv[1])
  with open(sys.argv[1] + ".txt", "w") as file:
    item_ids = items.keys()
    item_ids.sort()
    for item_id in item_ids:
      file.write(str(item_id) + ", -- " + items[item_id].name + "\n")
  print "Total items found: %d" % len(items)
