
require 'templet/component/partial'

module Templet
  module Html
    # Renders an HTML dl from a Hash
    class DefinitionList < Component::Partial
      # +controls+ [Hash]
      #   The key is the field's title
      #   The value is the field value || a Proc which calls the record's method
      def call(controls, record=nil, html_class: nil)
        super() do
          dl(html_class || default_html_class) do
            controls.to_h.map do |title, data|
              title = title.to_s.capitalize.tr('_', ' ')

              if data.respond_to?(:call)
                data = data.(record)
              elsif Symbol === data
                data = if record and record.respond_to?(:[])
                         record[data]
                       else
                         data.to_s.capitalize.tr('_', ' ')
                       end
              end

              dt(title) + dd(data)
            end
          end
        end
      end

      def default_html_class
      end
    end
  end
end

