
require 'erb'
require 'ostruct'

module Templet
  module Renderers
    # For rendering a supplied block within an ERb template
    class ERb
      attr_accessor :context, :proto_template

      # template_path can be a local ERb file, template string, or DATA append
      #
      # locals are local variables for the ERb template alone
      def initialize(proto_template=nil, **locals)
        self.proto_template = proto_template

        self.context = OpenStruct.new(**locals)
      end

      # The return value from the block in substituted in <%= yield %>
      def call(&block)
        context_binding = context.instance_eval { ::Kernel.binding }

        erb.result context_binding, &block
      end

      # Shortcut to instance method
      def self.call(template=nil, **locals, &block)
        new(template, **locals).(&block)
      end

      private

      def erb
        @erb ||= ERB.new get_template
      end

      def get_template
        if proto_template
          if proto_template =~ /(<%)|(\s\s)|(\n)/m
            proto_template
          else
            IO.read proto_template
          end
        else
          template or ''
        end
      end

      def template(read_from=false)
        if read_from
          call_stack = caller

          read_erb(call_stack) or read_end(call_stack)
        end
      end

      def read_erb(call_stack)
        path = erb_path(call_stack)

        IO.read(path) if File.file?(path)
      end

      def erb_path(call_stack)
        source_path(call_stack, 0).sub(/\.rb$/, '.erb')
      end

      def read_end(call_stack)
        if defined? DATA
          DATA.read
        else
          path = source_path(call_stack, 0)

          IO.read(path).split(/\s__END__\s/, 2)&.last
        end
      end

      def source_path(call_stack, index)
        call_stack[index].split(":").first
      end
    end
  end
end

