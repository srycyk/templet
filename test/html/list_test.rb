
require 'minitest/autorun'

require "templet/html"

require "test_helpers/xml_predicates"

  describe Templet::Html::List do
    HTML_CLASS = 'classy'

    include XmlPredicates

    def render(items=%w(First Second Third), **options)
      renderer = Templet::Renderer.new

      Templet::Html::List.new(renderer).(items, **options)
    end

    it 'renders ul' do
      assert tag?(render, 'ul')
    end

    it 'renders ul class' do
      html = render(html_class: HTML_CLASS)

      assert att? html, :class, HTML_CLASS

      assert_equal 1, num_matches(html, HTML_CLASS)
    end

    it 'renders li tag' do
      assert tag?(render, 'li')
    end

    it 'renders li content' do
      assert content?(render, 'First')
    end

    it 'renders item class' do
      html = render(item_class: HTML_CLASS)

      assert att? html, :class, HTML_CLASS

      assert_equal 3, num_matches(html, HTML_CLASS)
    end

    [ 'First', /irst/, 0 ].each do |selection|
      it "renders selected class for #{selection}" do
        html = render(selection: selection, selected_class: HTML_CLASS)

        assert att? html, :class, HTML_CLASS

        assert_equal 1, num_matches(html, HTML_CLASS)
      end
    end

    it 'adds selected html class to existing class' do
      html = render(selection: 0, item_class: HTML_CLASS)

      assert att? html, :class, "#{HTML_CLASS} active"
    end

    it 'changes name selected html class' do
      html = render(selection: 0, selected_class: HTML_CLASS)

      assert att? html, :class, HTML_CLASS

      assert_equal 1, num_matches(html, HTML_CLASS)
    end
  end

