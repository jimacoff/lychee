class Preference < ActiveRecord::Base
  include ParentSite
  include Metadata

  REQUIRED_RESERVED_PATHS = %w(blog blog_articles blog_categories blog_tags
                               products categories)

  enum tax_basis: { delivery: 0, customer: 1, subscriber: 2 }

  # TODO: prices_include_tax likey means order_subtotal_include_tax should
  # also be false, i.e. American orders - when create pref screen.

  has_paper_trail
  valhammer

  validate :subtotal_must_include_taxes_when_prices_tax_inclusive,
           :all_reserved_paths,
           :unique_reserved_paths

  def subtotal_must_include_taxes_when_prices_tax_inclusive
    return unless prices_include_tax && !order_subtotal_include_tax

    errors.add(:order_subtotal_include_tax)
  end

  def all_reserved_paths
    return if reserved_paths &&
              REQUIRED_RESERVED_PATHS.all? { |k| reserved_paths.key? k }

    errors.add(:reserved_paths,
               'Must include all required reserved paths: ' \
               "#{REQUIRED_RESERVED_PATHS.join(', ')}")
  end

  def unique_reserved_paths
    return if reserved_paths &&
              reserved_paths.values.uniq.size == reserved_paths.values.size

    errors.add(:reserved_paths, 'Reserved paths must be unique')
  end
end
