class Preference < ActiveRecord::Base
  include ParentSite
  include Metadata

  REQUIRED_RESERVED_URI_PATHS = %w(blog blog_articles blog_categories blog_tags
                                   products categories images shopping_bag
                                   checkout)

  FIXED_RESERVED_URI_PATHS = { 'shopping_bag' => '/shop/bag',
                               'checkout' => '/shop/checkout' }

  enum tax_basis: { delivery: 0, customer: 1, subscriber: 2 }
  enum braintree_environment: { sandbox: 0, production: 1 }

  # TODO: prices_include_tax likey means order_subtotal_include_tax should
  # also be false, i.e. American orders - when create pref screen.

  has_paper_trail
  valhammer

  validate :subtotal_must_include_taxes_when_prices_tax_inclusive,
           :all_reserved_uri_paths,
           :unique_reserved_uri_paths,
           :fixed_reserved_uri_paths

  def reserved_uri_path(key)
    reserved_uri_paths[key]
  end

  private

  def subtotal_must_include_taxes_when_prices_tax_inclusive
    return unless prices_include_tax && !order_subtotal_include_tax

    errors.add(:order_subtotal_include_tax)
  end

  def all_reserved_uri_paths
    return if reserved_uri_paths &&
              REQUIRED_RESERVED_URI_PATHS.sort == reserved_uri_paths.keys.sort

    errors.add(:reserved_uri_paths,
               'Must include all required reserved paths: ' \
               "#{REQUIRED_RESERVED_URI_PATHS.join(', ')}")
  end

  def unique_reserved_uri_paths
    return if reserved_uri_paths &&
              reserved_uri_paths.values.uniq.size ==
              reserved_uri_paths.values.size

    errors.add(:reserved_uri_paths, 'Reserved paths must be unique')
  end

  def fixed_reserved_uri_paths
    return unless reserved_uri_paths

    FIXED_RESERVED_URI_PATHS.each do |k, v|
      next if reserved_uri_paths[k] == v
      errors.add(:reserved_uri_paths,
                 "Must used the fixed value `#{v}` for `#{k}`")
    end
  end
end
