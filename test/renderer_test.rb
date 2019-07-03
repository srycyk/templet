
require 'minitest/autorun'

require "templet"

require "test_helpers/xml_predicates"
require "test_helpers/renderer_mixin"

  describe Templet::Renderer do
    include XmlPredicates

    def renderer(*args)
      Templet::Renderer.new(*args)
    end

    def render(*args, &block)
      renderer(*args).(&block)
    end

    def html_list
      proc { ul(:list_unstyled) { [ li('One'), li('Two') ] } }
    end

    def own_helper_method
      'own helper method'
    end

    def class_apart
      Class.new do
        def different_helper_method
          'different class'
        end
      end 
    end

    it 'renders a simple tag' do
      assert tag?(render { div }, 'div')
    end

    it 'renders an attribute of a simple tag' do
      rendered = render { div data_structure: 'x' }

      assert tag?(rendered, 'div')
      assert att?(rendered, 'data-structure', 'x')
    end

    it 'renders base tag of an html unordered list' do
      rendered = render(&html_list)

      assert tag?(rendered, 'ul')
      assert att?(rendered, 'class', 'list-unstyled')
    end

    it 'renders nested item of an html unordered list' do
      rendered = render(&html_list)

      assert tag?(rendered, 'li')
      assert content?(rendered, 'Two')
    end

    it 'calls helper method from self' do
      rendered = render(self) { div own_helper_method }

      assert content?(rendered, 'own helper method')
    end

    it 'calls helper method from a different class' do
      rendered = render(class_apart.new) { div different_helper_method }

      assert content?(rendered, 'different class')
    end

    it 'calls mixin helper method' do
      rendered = render(self, ::RendererMixin) do
                   [ div(own_helper_method), div(mixin_helper_method) ]
                 end

      assert content?(rendered, 'own helper method')
      assert content?(rendered, 'mixin helper method')
    end

    it 'calls method from locals' do
      rendered = render(local: 'local variable') { div local }

      assert content?(rendered, 'local variable')
    end

    it 'calls renderer helper method: list' do
      rendered = render(local: 'local variable') { div list local }

      assert content?(rendered, 'local variable')
    end

    it '#respond_to? success' do
      assert renderer(class_apart.new).respond_to? :different_helper_method
    end

    it '#respond_to? failure' do
      refute renderer(class_apart.new).respond_to? :no_such_method
    end
  end

