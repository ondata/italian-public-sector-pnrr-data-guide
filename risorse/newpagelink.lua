function Link (link)
  if link.target:match '^https?%:' then
    link.attributes.target = '_blank'
    return link
  end
end
