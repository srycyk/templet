
class TemplateEnd < Templet::Component::Template
  def template
    super true
  end
end

__END__

<div><%= yield %></div>

