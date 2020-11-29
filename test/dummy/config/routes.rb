Rails.application.routes.draw do
  mount Forest::Shopify::Engine => "/forest-shopify"
end
