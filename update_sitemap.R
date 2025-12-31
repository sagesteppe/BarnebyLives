# update_sitemap.R
library(xml2)

sitemap <- read_xml("docs/sitemap.xml")
today <- format(Sys.Date(), "%Y-%m-%d")

# Update all lastmod dates to today
lastmod_nodes <- xml_find_all(sitemap, "//d1:lastmod", xml_ns(sitemap))
xml_text(lastmod_nodes) <- today

write_xml(sitemap, "docs/sitemap.xml")
