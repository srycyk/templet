
require 'minitest/autorun'

require "templet"

require "test_helpers/xml_predicates"

  describe Templet::Component::Layout do
    include XmlPredicates

    let(:template_with_local) { '<div><%= content  %></div>' }
    let(:template_with_yield) { '<div><%= yield  %></div>' }

    class StandardLayout < Templet::Component::Layout
      def call
        super do
          html do
            [ head, body { yield renderer } ]
          end
        end
      end
    end

    class SimpleTemplate < Templet::Component::Template
    end

    it 'renders local inside layout' do
      rendered = StandardLayout.new.call do |renderer|
        SimpleTemplate.new(renderer, template_with_local, content: 'Whatever').call
      end

      assert tag?(rendered, 'body')
      assert tag?(rendered, 'div')
      assert content?(rendered, 'Whatever')
    end

    it 'renders yield inside layout' do
      rendered = StandardLayout.new.call do |renderer|
        SimpleTemplate.new(renderer, template_with_yield).call { 'Whatever' }
      end

      assert tag?(rendered, 'body')
      assert tag?(rendered, 'div')
      assert content?(rendered, 'Whatever')
    end

    it 'renders from erb file - alongside class in file system' do
      rendered = StandardLayout.new.call do |renderer|
        erb = SimpleTemplate.new(renderer)

        def erb.template; super true end

        erb.call
      end

      assert tag?(rendered, 'body')
      assert tag?(rendered, 'span')
      assert content?(rendered, 'Bridge')
    end
  end

