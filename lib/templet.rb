
require "templet/version"
require "templet/renderer"
require "templet/renderers/erb"

require "templet/component"
require "templet/html"

module Templet
  EOL = "\n"

  def self.call(*contexts, &block)
    renderer = Renderer.new(*contexts)

    block ? renderer.(&block) : renderer
  end

  def self.erb(template_path, **locals, &block)
    Renderers::Erb.(template_path, **locals, &block)
  end
end
