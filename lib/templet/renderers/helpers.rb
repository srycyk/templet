
module Templet
  # For general purpose methods, it's included in the Renderer class
  module Renderers
    module Helpers
      private

      def echo(*elements)
        elements
      end

      alias returns echo
    end
  end
end

