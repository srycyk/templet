
require 'minitest/autorun'

require "templet"

require "test_helpers/xml_predicates"

  describe Templet::Renderers::Tag do
    include XmlPredicates

    let (:tag_name) { 'dog' } 

    let (:tag_atts) { { class: :poodle } } 

    let (:tag) { new_tag tag_name, tag_atts } 

    def new_tag(name, **atts)
      Templet::Renderers::Tag.new name, atts
    end

    it 'renders name' do
      assert tag?(tag, tag_name)
    end

    it 'renders attributes' do
      assert att?(tag, *tag_atts.to_a.first)
    end

    it 'renders content as string' do
      assert content?(tag.('middle'), 'middle')
    end

    it 'renders content as string array' do
      assert content?(tag.(%w(one two three)), "one\ntwo\nthree")
    end

    it 'renders content as block' do
      assert content?(tag.() { 'middle' }, 'middle')
    end

    it 'renders content in block returning array' do
      tag = self.tag.() { [ %w(one two), %w(three) ] }

      assert content?(tag, "one\ntwo\nthree")
    end

    it 'renders content in block returning array with callable' do
      tag = self.tag.() { [ %w(one two), -> { 'three'} ] }

      assert content?(tag, "one\ntwo\nthree")
    end

    it 'renders content as block with nested tag' do
      tag = self.tag.() { new_tag 'nested' }

      assert tag?(tag, 'nested')
    end

    it 'adds attribute: "class" if content in block' do
      tag = self.new_tag(tag_name).('parlour') {}

      assert att?(tag, 'class', 'parlour')
    end

    it 'renders string (1st arg) and adds attribute "class" (2nd arg)' do
      tag = self.new_tag(tag_name).('middle', 'parlour')

      assert content?(tag, 'middle')

      assert att?(tag, 'class', 'parlour')
    end

    it 'ignores nil attribute: "class" if content in block' do
      tag = self.new_tag(tag_name).(nil) {}

      refute att?(tag, 'class')
    end

    it 'renders string (1st arg) and ignores nil attribute "class" (2nd arg)' do
      tag = self.new_tag(tag_name).('middle', nil)

      assert content?(tag, 'middle')

      refute att?(tag, 'class')
    end

    it 'appends to attribute: "class" if content in block' do
      tag = self.tag.('parlour') {}

      assert att?(tag, 'class', 'poodle parlour')
    end

    it 'renders string (1st arg) and appends to attribute "class" (2nd arg)' do
      tag = self.tag.('middle', 'parlour')

      assert content?(tag, 'middle')

      assert att?(tag, 'class', 'poodle parlour')
    end

    it 'strips leading underscore from tag name)' do
      assert tag?(new_tag(:_xxx).(), 'xxx')
    end

    it 'strips leading underscores from tag name)' do
      assert tag?(new_tag(:___xxx).(), 'xxx')
    end

    it 'substitutes dash for underscore in tag name' do
      assert tag?(new_tag(:a_b).(), 'a-b')
    end

    it 'substitutes one underscore for three in tag name' do
      assert tag?(new_tag(:a___b).(), 'a_b')
    end

    it 'substitutes dash for underscore in tag attribute name' do
      assert att?(tag().(data_dump: 'x'), 'data-dump', 'x')
    end

    it 'substitutes dash for underscore in tag attribute "class"' do
      assert att?(tag.(:hound_dog) {}, 'class', 'poodle hound-dog')
    end
  end

