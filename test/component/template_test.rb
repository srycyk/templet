
require 'minitest/autorun'

require "templet"

require "test_helpers/xml_predicates"
require "test_helpers/template_end"

  describe Templet::Component::Template do
    include XmlPredicates

    let(:renderer) { Templet::Renderer.new }

    let(:template_with_content) { '<div><%= content  %></div>' }
    let(:template_with_name) { '<div><%= name  %></div>' }
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
        locals = { content: 'Whatever' }

        SimpleTemplate.new(renderer, template_with_content, **locals).call
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

    it 'renders value from instance method' do
      erb = SimpleTemplate.new(renderer, template_with_name)

      def erb.name
        'Calling'
      end

      rendered = erb.call

      assert tag?(rendered, 'div')
      assert content?(rendered, 'Calling')
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

    it 'renders from in-line erb after __END__' do
      erb = TemplateEnd.new(renderer)

      rendered = erb.call { 'END' }

      assert tag?(rendered, 'div')
      assert content?(rendered, 'END')
    end

    it 'renders from erb in overridden template method' do
      rendered = StandardLayout.new.call do |renderer|
        erb = SimpleTemplate.new(renderer)

        def erb.template
          <<~'ERB'
            <span>Attention</span>
          ERB
        end

        erb.call
      end

      assert tag?(rendered, 'body')
      assert tag?(rendered, 'span')
      assert content?(rendered, 'Attention')
    end
  end

