
require 'minitest/autorun'

require "templet/component"

require "test_helpers/xml_predicates"

  describe Templet::Component::Partial do
    include XmlPredicates

    def renderer(*args)
      Templet::Renderer.new(*args)
    end
    def render(*args, &block)
      renderer(*args).(&block)
    end

    class TitlePartial < Templet::Component::Partial
      def call
        super do
          _title title
        end
      end

      private

      def title
        'Title'
      end
    end

    class YieldingPartial < Templet::Component::Partial
      def call
        super do
          h1 yield
        end
      end
    end

    it 'renders from itself' do
      rendered = Templet::Component::Partial.new(renderer).() { h1 }

      assert tag?(rendered, 'h1')
    end

    it 'renders tag' do
      rendered = renderer.() { Templet::Component::Partial.(self) { h1 } }

      assert tag?(rendered, 'h1')
    end

    it 'renders a title tag' do
      rendered = renderer.() { TitlePartial.new(self) }

      assert tag?(rendered, 'title')
    end

    it 'renders a title tag from internal method' do
      rendered = TitlePartial.new(renderer).()

      assert content?(rendered, 'Title')
    end

    it 'renders a title tag from locals' do
      rendered = TitlePartial.new(renderer, title: 'Heading').()

      assert content?(rendered, 'Heading')
    end

    it 'yields an inner section' do
      rendered = renderer.() { YieldingPartial.(self) { b 'Heading' } }

      assert tag?(rendered, 'h1')
      assert tag?(rendered, 'b')
      assert content?(rendered, 'Heading')
    end
  end

