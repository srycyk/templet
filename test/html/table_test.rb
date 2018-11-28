
require 'minitest/autorun'

require "templet/html"

require "test_helpers/xml_predicates"

  describe Templet::Html::Table do
    include XmlPredicates

    def render(control=-> (renderer, item, _) { item },
               items=%w(First Second), **options)
      controls = { column: control }

      renderer = Templet::Renderer.new

      Templet::Html::Table.new(renderer).(controls, items, **options)
    end

    it 'renders table' do
      assert tag?(render, 'table')
    end

    it 'renders th tag' do
      assert tag?(render, 'th')
    end

    it 'renders th content' do
      assert content?(render, 'Column')
    end

    it 'renders td tag' do
      assert tag?(render, 'td')
    end

    it 'renders td content' do
      assert content?(render, 'First')
    end

    it 'adds table class' do
      assert att? render(html_class: 'classy'), :class, 'classy'
    end

    it 'renders td content with a nil control' do
      assert content?(render(nil), 'First')
    end

    it 'renders td content with a nil control on a list of a list' do
      assert content?(render(nil, [%w(One Two)]), 'One')
    end

    it 'renders td content with an index control' do
      assert content?(render(1, [%w(One Two)]), 'Two')
    end
  end

