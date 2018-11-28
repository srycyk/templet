
module XmlPredicates
  def tag?(xml, name)
    xml.to_s =~ /<#{name}.*>.*<\/#{name}>/m
  end

  def att?(xml, name, value=false)
    if value == false
      xml.to_s =~ /\s+#{name}=['"].*?['"]/
    else
      xml.to_s =~ /\s+#{name}=['"]#{value}['"]/
    end
  end

  def content?(xml, content)
    xml.to_s =~ />.*#{content}.*<\//
  end

  def num_matches(text, substring)
    text.scan(/#{substring}/m).size
  end
end

