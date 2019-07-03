
require 'minitest/autorun'

require 'ostruct'

require "templet"

require "test_helpers/xml_predicates"

  describe Templet::Html::DefinitionList do
    include XmlPredicates

    ITEMS = { "First" => 'One', "Second" => 'Two' }

    def render(items=ITEMS, record=nil)
      renderer = Templet::Renderer.new

      Templet::Html::DefinitionList.new(renderer).(items, record)
    end

    def render_with_record
      record = OpenStruct.new(field_1: 'Value 1', field_2: 'Value 2')

      field_2_proc = -> (record) { record.send :field_2 }
      controls = { first: :field_1, second: field_2_proc }

      render(controls, record)
    end

    it 'renders dl' do
      assert tag?(render, 'dl')
    end

    it 'renders dt tag' do
      assert tag?(render, 'dt')
    end

    it 'renders dt content' do
      assert content?(render, 'First')
    end

    it 'renders dd tag' do
      assert tag?(render, 'dd')
    end

    it 'renders dd content' do
      assert content?(render, 'One')
    end

    it 'renders a record value by key' do
      assert content?(render_with_record, 'Value 1')
    end

    it 'renders a record value by key' do
      assert content?(render_with_record, 'Value 2')
    end
  end

