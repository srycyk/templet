
require "templet/renderers/list_presenter"

module Templet
  module Renderers
    # Renders an XML tag
    class Tag < Struct.new(:tag_name, :default_atts)
      @@level = 0

      # A shortcut for calling directly.
      def self.call(*args, &block)
        new(args.shift).(*args, &block)
      end

      # +args+:: The first element becomes the tag's name.
      #
      # +args+:: The remaining elements are the tag's body and/or HTML class.
      #
      # +atts+:: An optional final (Hash) argument are rendered as the tag's attributes.
      #
      # If a block is given:
      # The tag's body is what the block returns
      # If there's an argument (String Symbol) then it's added to the tag's HTML class.
      #
      # If NO block is given:
      # The tag's body is the first argument.
      # If there's a second (String Symbol) argument it's added to the tag's HTML class.
      #
      #   Note that in attribute (and tag) names underscores are replaced
      #   with dashes.
      def call(*args, **atts)
        content, html_class = block_given? ? [ yield, args.first ] : args

        attributes = set_html_class all_atts(atts), html_class

        render tag_name, content, attributes
      end

      alias to_s call

      private

      def render(name, content, **atts)
        name = dashit name.to_s.sub(/^_+/, '')

        content = ListPresenter.new.(content)

        "<#{name}#{atts_to_s atts}>#{content}</#{name}>#{EOL}"
      end

      # Change underscores to dashes when specifying
      #   XML tag names, attribute names and html classes.
      # For a single underscore, put in two.
      def dashit(name)
        (name || '').to_s.tr('_', '-').gsub(/--/, '_') # could be better!
      end

      def dash_symbol(value)
        Symbol === value ? dashit(value) : value
      end

      def atts_to_s(atts)
        atts.reduce '' do |acc, (key, value)|
          acc << " #{dashit key}='#{dash_symbol value}'"
        end
      end

      def all_atts(atts)
        (default_atts || {}).merge atts
      end

      # If there's already an HTML class then append to it
      def set_html_class(atts, html_class)
        unless (new_html_class = dashit(html_class)).empty?
          atts[:class] = existing_html_class(atts) << new_html_class
        end
        atts
      end

      def existing_html_class(atts)
        atts.key?(:class) ? "#{dash_symbol atts[:class]} " : ''
      end
    end
  end
end

