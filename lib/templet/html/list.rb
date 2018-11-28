
require 'templet/component/partial'

module Templet
  module Html
    class List < Component::Partial
      def call(*items, html_class: nil,
                       item_class: nil,
                       selection: nil,
                       selected_class: 'active')
        super() do
          ul html_class do
            items.flatten.map.with_index do |item, index|
              li item, li_class(selection, item, index,
                                item_class, selected_class)
            end
          end
        end
      end

      private

      def selected?(selection, item, index)
        case selection
        when nil, false
          false
        when Integer
          index == selection
        when Regexp
          selection === item
        else
          selection.to_s == item.to_s
        end
      end

      def li_class(selection, item, index, item_class, selected_class)
        if selected?(selection, item, index)
          if item_class and not item_class.empty?
            "#{item_class} #{selected_class}"
          else
            selected_class
          end
        else
          item_class
        end
      end
    end
  end
end

