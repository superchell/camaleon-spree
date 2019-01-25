module Plugins::CamaleonSpree::PrivateHelper
  # custom fields support for Spree Products
  def camaleon_spree_custom_field_models(args)
    args[:models] << Spree::Product
  end
end
