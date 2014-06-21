import sys

from splinter import Browser
browser = Browser('phantomjs')

items_normal = {}
items_veteran = {}

class ItemInfo:
  def __init__(self):
    self.id = 0
    self.name = ""
    self.level = 0
    self.ilevel = 0

def parse_adventure(id):
  global browser
  browser.visit("http://www.jabbithole.com/zones/" + id)
  parse_normal()
  parse_veteran()

def parse_normal():
  global browser
  if not browser.is_text_present("Normal rewards"):
    return
  link_id = 3
  table_id = 2
  if browser.is_text_present("Quests"):
    link_id = link_id + 1
    table_id = table_id + 1
  if browser.is_text_present("Veteran NPCs"):
    link_id = link_id + 1
    table_id = table_id + 1
  browser.find_by_id("ui-id-" + str(link_id))[0].click()
  while not browser.is_element_present_by_id("DataTables_Table_" + str(table_id)):
    continue
  parse_drops_normal("DataTables_Table_" + str(table_id))
  pages = num_pages("DataTables_Table_" + str(table_id))
  for i in range(1, pages):
    go_to_page("DataTables_Table_" + str(table_id), i)
    parse_drops_normal("DataTables_Table_" + str(table_id))

def parse_veteran():
  global browser
  if not browser.is_text_present("Veteran rewards"):
    return
  link_id = 4
  table_id = 3
  if browser.is_text_present("Quests"):
    link_id = link_id + 1
    table_id = table_id + 1
  if browser.is_text_present("Veteran NPCs"):
    link_id = link_id + 1
    table_id = table_id + 1
  browser.find_by_id("ui-id-" + str(link_id))[0].click()
  while not browser.is_element_present_by_id("DataTables_Table_" + str(table_id)):
    continue
  parse_drops_veteran("DataTables_Table_" + str(table_id))
  pages = num_pages("DataTables_Table_" + str(table_id))
  for i in range(1, pages):
    go_to_page("DataTables_Table_" + str(table_id), i)
    parse_drops_veteran("DataTables_Table_" + str(table_id))

def num_pages(table_id):
  global browser
  paginate = browser.find_by_id(table_id + "_paginate")[0]
  span = paginate.find_by_tag("span")[0]
  return len(span.find_by_tag("a"))

def go_to_page(table_id, page):
  global browser
  paginate = browser.find_by_id(table_id + "_paginate")[0]
  span = paginate.find_by_tag("span")[0]
  span.find_by_tag("a")[page].click()
  while not browser.is_element_present_by_id(table_id):
    continue

def parse_drops_normal(table_id):
  global browser
  global items_normal
  table = browser.find_by_id(table_id)[0]
  tbody = table.find_by_tag("tbody")[0]
  for row in tbody.find_by_tag("tr"):
    item = ItemInfo()
    item.id = int(row.find_by_tag("a")[0]["href"].split("-")[-2])
    item.name = row.find_by_tag("a")[1].text
    item.level = int(row.find_by_tag("td")[4].text)
    item.ilevel = int(row.find_by_tag("td")[5].text)
    if not item.id in items_normal:
      items_normal[item.id] = item

def parse_drops_veteran(table_id):
  global browser
  global items_veteran
  table = browser.find_by_id(table_id)[0]
  tbody = table.find_by_tag("tbody")[0]
  for row in tbody.find_by_tag("tr"):
    item = ItemInfo()
    item.id = int(row.find_by_tag("a")[0]["href"].split("-")[-2])
    item.name = row.find_by_tag("a")[1].text
    item.level = int(row.find_by_tag("td")[4].text)
    item.ilevel = int(row.find_by_tag("td")[5].text)
    if not item.id in items_veteran:
      items_veteran[item.id] = item

if len(sys.argv) < 2:
  print "Usage: %s <adventure id>" % sys.argv[0]
else:
  parse_adventure(sys.argv[1])
  with open(sys.argv[1] + ".txt", "w") as file:
    item_ids = items_normal.keys()
    item_ids.sort()
    for item_id in item_ids:
      file.write(str(item_id) + ", -- " + items_normal[item_id].name + "\n")
  with open(sys.argv[1] + "-veteran.txt", "w") as file:
    item_ids = items_veteran.keys()
    item_ids.sort()
    for item_id in item_ids:
      file.write(str(item_id) + ", -- " + items_veteran[item_id].name + "\n")
  print "[Normal] Total items found: %d" % len(items_normal)
  print "[Veteran] Total items found: %d" % len(items_veteran)
