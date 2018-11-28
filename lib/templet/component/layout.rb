
module Templet
  module Component
    # For composing views - the first step
    class Layout < Partial
      # +contexts+:: A list containing objects whose methods will be looked up
      # +locals+:: Objects you can reference by the given name
      def initialize(*contexts, **locals)
        contexts = [ self, *contexts ]

        self.renderer = Renderer.new(*contexts, **locals)
      end

      def self.call(*contexts, **locals, &block)
        new(*contexts, **locals).(&block)
      end
    end
  end
end

