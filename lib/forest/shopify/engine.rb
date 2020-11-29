module Forest
  module Shopify
    class Engine < ::Rails::Engine
      isolate_namespace Forest::Shopify
    end
  end
end
