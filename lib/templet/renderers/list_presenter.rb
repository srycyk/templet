
module Templet
  module Renderers
  # Converts lists of strings and/or callable objects into a multiline string
    class ListPresenter
      def call(*elements)
        elements.flatten.compact.map do |element|
          element = recall(element)

          Array === element ? call(*element) : element.to_s
        end * EOL
      end

      private

      def recall(element)
        element.respond_to?(:call) ? recall(element.call) : element
      end
    end
  end
end

