
module Templet
  module Component
    # Used for ERb support
    class Template < Templet::Renderers::ERb
      # +template+:: Given as string or file or at __END__
      # +locals+:: Objects you can reference by the name given as the key
      def initialize(renderer, template=nil, **locals)
        self.proto_template = template

        self.context = renderer.new_instance(self, **locals)
      end
    end
  end
end

