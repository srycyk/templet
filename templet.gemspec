
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "templet/version"

Gem::Specification.new do |spec|
  spec.name          = "templet"
  spec.version       = Templet::VERSION
  spec.authors       = ["stephen"]
  spec.email         = ["stephen@googlemail.com"]

  spec.summary       = %q{DSL to render XML/HTML}
  spec.description   = %q{Generates HTML tags from pure Ruby, using a method name as a tag's name, via method_missing. Also renders HTML components.}
  spec.homepage      = "https://github.com/srycyk/templet"
  spec.license       = "MIT"

=begin
  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end
=end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "minitest", "~> 5.0"
end
