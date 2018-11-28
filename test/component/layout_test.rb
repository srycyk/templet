
require 'minitest/autorun'

require "templet/component"

require "test_helpers/xml_predicates"

  describe Templet::Component::Layout do
    include XmlPredicates

    class HtmlLayout < Templet::Component::Layout
      def call
        super do
          html do
            [ head { _title title }, body { yield self } ]
          end
        end
      end

      private

      def title
        'Title'
      end
    end

    it 'renders a title tag' do
      rendered = HtmlLayout.new.() { '' }

      assert tag?(rendered, 'title')
      assert content?(rendered, 'Title')
    end

    it 'renders a heading tag' do
      rendered = HtmlLayout.new.() do |renderer|
                   renderer.() { h1 'Heading' }
                 end

      assert tag?(rendered, 'h1')
      assert content?(rendered, 'Heading')
    end

    it 'renders a title from locals' do
      rendered = HtmlLayout.new(self, title: 'Local').() { '' }

      assert tag?(rendered, 'title')
      assert content?(rendered, 'Local')
    end
  end

