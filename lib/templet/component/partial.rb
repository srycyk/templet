
module Templet
  module Component
    # Used for composing views, either within a Layout or another Parial
    class Partial
      attr_accessor :renderer

      # +contexts+:: A list containing objects whose methods will be looked up
      # +locals+:: Objects you can reference by the name given as the key
      def initialize(renderer, *contexts, **locals)
        self.renderer = if renderer
                          renderer.new_instance(self, *contexts, **locals)
                        else
                          Renderer.new(self, *contexts, **locals)
                        end
      end

      # Entry point - the block returns markup
      def call(&block)
        renderer.(&block)
      end

      # Shortcut
      def self.call(renderer, *contexts, **locals, &block)
        new(renderer, *contexts, **locals).(&block)
      end

      private

      # If +call+ gets overriden then use +compose+ instead
      alias compose call
    end
  end
end

