module Forest
  module Shopify
    class Engine < ::Rails::Engine
      isolate_namespace Forest::Shopify

      initializer 'forest-shopify.checking_migrations' do
        Migrations.new(config, engine_name).check
      end
    end
  end
end
