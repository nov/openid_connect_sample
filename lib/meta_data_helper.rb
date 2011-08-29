module MetaDataHelper
  def meta_tag(name, content, options = {})
    tag :meta, options.merge(name: name, content: content)
  end

  def link_tag(rel, href, options = {})
    tag :link, options.merge(rel: rel, href: href)
  end
end