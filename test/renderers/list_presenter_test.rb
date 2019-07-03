
require 'minitest/autorun'

require "templet"

  describe Templet::Renderers::ListPresenter do
    let(:list) { [ 'a', -> { 'b' }, %w(c) ]  }

    let(:renderer) { Templet::Renderers::ListPresenter.new }

    it 'renders nothing' do
      assert_equal '', renderer.()
    end

    it 'renders empty list' do
      assert_equal '', renderer.([ nil ])
    end

    it 'renders string' do
      assert_equal 'x', renderer.('x')
    end

    it 'renders block' do
      assert_equal 'x', renderer.(-> { 'x' })
    end

    it 'renders list' do
      list_re = /^a.?b.?c/m

      assert_match list_re, renderer.(list)
    end

    it 'renders a nested callable' do
      assert_equal 'x', renderer.(-> { -> { 'x' } })
    end

    it 'renders nested callables' do
      assert_equal renderer.(list), renderer.([ -> { [ nil, -> { list } ] } ])
    end
  end

