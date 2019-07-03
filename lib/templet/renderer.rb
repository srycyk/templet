
require "ostruct"

require "templet/renderers/helpers"
require "templet/renderers/list_presenter"
require "templet/renderers/tag"

module Templet
  # Performs the rendition
  class Renderer < BasicObject
    include Renderers::Helpers

    # +contexts+ a list of object refererences for method lookups
    #
    # +locals+ named variables passed into the renderer
    def initialize(*contexts, **locals)
      @contexts = contexts.flatten

      # Local variables take precedence
      @contexts.unshift ::OpenStruct.new(**locals) if locals.any?
    end

    # Used for augmenting and overriding method lookups in children
    def new_instance(*contexts, **locals)
      Renderer.new(*(contexts | @contexts), **locals)
    end

    # The block contains the markup
    def call(&block)
      Renderers::ListPresenter.new.(instance_eval(&block))
    end

    def method_missing(name, *args, &block)
      @contexts.each do |context|
        if context.respond_to?(name, true)
          return context.send(name, *args, &block)
        end
      end
      fallback(name, *args, &block)
    end

    def respond_to?(method_name, *)
      @contexts.each do |context|
        return true if context.respond_to?(method_name, true)
      end
      false
    end

    private

    def tag(name, *args, &block)
      Renderers::Tag.new(name).(*args, &block)
    end

    # Allows you to reimplement +fallback+ in a subclass
    # For example, you might use the Rails helper method +content_tag+ instead
    alias fallback tag
  end
end

