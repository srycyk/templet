
require 'erb'
require 'ostruct'

module Templet
  module Renderers
    # For rendering a supplied block within an ERb template
    class ERb
      attr_accessor :erb, :context

      # template_path can be a local ERb file, or template text
      #
      # locals are local variables for the ERb template alone
      def initialize(template, **locals)
        self.erb = ERB.new get_template(template)

        self.context = OpenStruct.new(**locals)
      end

      # The return value from the block in substituted in <%= yield %>
      def call(&block)
        locals_binding = context.instance_eval { binding }

        erb.result locals_binding, &block
      end

      # Shortcut to instance method
      def self.call(template_path, **locals, &block)
        new(template_path, **locals).(&block)
      end

      private

      def get_template(template)
        if template =~ /<%/
          template
        else
          IO.read template
        end
      end
    end
  end
end

