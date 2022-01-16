$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "forest/shopify/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = "forest-shopify"
  spec.version     = Forest::Shopify::VERSION
  spec.authors     = ["dylanfisher"]
  spec.email       = ["hi@dylanfisher.com"]
  spec.homepage    = "https://github.com/dylanfisher/forest-shopify"
  spec.summary     = "Shopify support in Forest CMS"
  spec.description = "A Rails engine that uses Shopify's storefront API to sync products to Forest CMS."
  spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "rails"
  spec.add_dependency "graphql-client"
end
