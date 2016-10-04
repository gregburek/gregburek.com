###
# Page options, layouts, aliases and proxies
###

Time.zone = "America/Los_Angeles"

# Per-page layout changes:
#
# With no layout
page '/*.xml', layout: false
page '/*.json', layout: false
page '/*.txt', layout: false
page "/feed.xml", layout: false

###
# Helpers
###

set :js_dir, 'js'
set :images_dir, 'images'
set :relative_links, true
set :fonts_dir,  "fonts"

activate :syntax, wrap: true
activate :directory_indexes

set :markdown_engine, :redcarpet
set :markdown, :layout_engine => :erb,
  :fenced_code_blocks => true,
  :tables => true,
  :autolink => true,
  :smartypants => true,
  :with_toc_data => true


activate :blog do |blog|
  blog.taglink = "tags/{tag}.html"
  blog.layout = "post"

  blog.tag_template = "tag.html"
  blog.calendar_template = "calendar.html"

  blog.summary_separator = /READMORE/

  blog.paginate = true
  blog.per_page = 30
  blog.page_link = "page/{num}"
end

set :relative_links, true
activate :livereload

# Build-specific configuration
configure :build do
  activate :minify_css
  activate :minify_javascript
end
