
require 'minitest/autorun'

require "templet"
require "test_helpers/xml_predicates"
#require "test_helpers/renderer_mixin"

  describe Templet::Renderers::ERb do
    include XmlPredicates

    def render(layout=html_layout, **locals, &block)
      Templet::Renderers::ERb.new(layout, **locals).(&block)
    end

    def html_layout(title='<title><%= title %></title>')
      %(
        <html>
          <head>
            #{title}
          </head>
          <body>
            <%= yield %>
          </body>
        </html>
      )
    end

    it 'renders a layout' do
      rendered = render { '' }

      assert tag?(rendered, 'html')
      assert tag?(rendered, 'head')
    end

    it 'renders a simple div tag' do
      rendered = render(html_layout '') { '<div></div>' }

      assert tag?(rendered, 'div')
    end

    it 'renders a title in tag' do
      rendered = render(title: 'sir') { '' }

      assert tag?(rendered, 'title')
      assert content?(rendered, 'sir')
    end

    it 'renders without a given block' do
      erb = '<tag><%= content %></tag>'

      rendered = render(erb, content: 'race')

      assert tag?(rendered, 'tag')
      assert content?(rendered, 'race')
    end
  end

