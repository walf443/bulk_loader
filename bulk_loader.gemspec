# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "bulk_loader/version"

Gem::Specification.new do |spec|
  spec.name          = "bulk_loader"
  spec.version       = BulkLoader::VERSION
  spec.authors       = ["Keiji Yoshimi"]
  spec.email         = ["walf443@gmail.com"]

  spec.summary       = %q{utility to avoid N+1 queries}
  spec.description   = %q{utility to avoid N+1 queries}
  spec.homepage      = "https://github.com/walf443/bulk_loader"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rubocop", "~> 0.49"
  spec.add_development_dependency "guard", "~> 2.14"
  spec.add_development_dependency "guard-rspec", "~> 4.7.3"
  spec.add_development_dependency "guard-rubocop", "~> 1.3.0"
end
