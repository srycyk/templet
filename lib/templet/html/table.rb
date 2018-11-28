
require 'templet/component/partial'

module Templet
  module Html
    # Renders an HTML table from a Hash
    class Table < Component::Partial
      # +controls+ [Hash]
      #   The key is a Proc || a field name (if it begins with _ it's not shown)
      #   The value is a Proc || an index || nil (for a single column table)
      def call(controls, records, opaque_heading: nil, opaque_row: nil,
                                  html_class: nil, footer: '')
        controls = controls.to_h

        super() do
          _table(html_class || default_html_class) do
            [ thead do
                tr do
                  controls.keys.map do |title|
                    if title.respond_to?(:call)
                      th title.(self, opaque_heading, opaque_row)
                    else
                      th heading(title.to_s)
                    end
                  end
                end
              end,

              tbody do
                records.map do |record|
                  tr do
                    controls.values.map.with_index do |value, index|
                      if value.respond_to?(:call)
                        td value.(self, record, opaque_row)
                      elsif value
                        td record[value]
                      else
                        Array === record ? record[index] : record
                      end
                    end
                  end
                end
              end,

              tfoot do
                tr do
                  td(colspan: controls.size) { footer }
                end
              end
            ]
          end
        end
      end

      def default_html_class
      end

      def heading(title)
        title[0] == '_' ? '' : title.capitalize.tr('_', ' ')
      end
    end
  end
end

