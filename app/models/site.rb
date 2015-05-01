class Site < ActiveRecord::Base
  include Metadata

  has_many :whitelisted_countries
  has_many :blacklisted_countries

  has_many :prioritized_countries

  has_many :tax_categories
  has_one :primary_tax_category, class_name: 'TaxCategory',
                                 foreign_key: 'site_primary_tax_category_id'

  has_many :products
  has_many :variants
  has_many :categories
  has_many :primary_categories, -> { primary }, foreign_key: :site_id,
                                                class_name: 'Category'

  has_one :subscriber_address, class_name: 'Address',
                               foreign_key: 'site_subscriber_address_id'
  delegate :country, to: :subscriber_address

  has_one :preferences, class_name: 'Preference'

  has_paper_trail
  valhammer

  validate :only_whitelisted_or_blacklisted_countries
  validate :prioritized_countries_are_valid
  validates :subscriber_address, presence: true, on: :update
  validates :primary_tax_category, presence: true, on: :update
  validates :preferences, presence: true, on: :update

  after_save :reload_current

  def restricts_countries?
    whitelisted_countries.present? || blacklisted_countries.present?
  end

  def only_whitelisted_or_blacklisted_countries
    return unless whitelisted_countries.present? &&
                  blacklisted_countries.present?
    errors.add(:base, 'Cannot specify whitelisted and blacklisted countries')
  end

  def prioritized_countries_are_valid
    return unless whitelisted_countries.present? ||
                  blacklisted_countries.present?

    if  prioritized_not_in_whitelist?
      errors.add(:base, 'All prioritized countries must appear in whitelist')
    end

    return unless prioritized_in_blacklist?
    errors.add(:base, 'Prioritized countries must not appear in blacklist')
  end

  def prioritized_not_in_whitelist?
    return false unless whitelisted_countries.present?

    intersection(whitelisted_countries).count != prioritized_countries.count
  end

  def prioritized_in_blacklist?
    return false unless blacklisted_countries.present?

    intersection(blacklisted_countries).count > 0
  end

  def currency=(currency)
    cur = Money::Currency.new(currency)
    write_attribute(:currency_iso_code, cur.iso_code)
  end

  def currency
    Money::Currency.new(currency_iso_code)
  end

  def currency_iso_code=(_code)
    fail 'Site#currency_iso_code= cannot be called, used Site#currency='
  end

  class << self
    def current
      Thread.current[:current_site]
    end

    def current=(site)
      Thread.current[:current_site] = site
    end
  end

  private

  def reload_current
    Site.current.reload if Site.current == self
  end

  def intersection(country_type)
    country_type.where(country_id: prioritized_country_ids)
  end

  def prioritized_country_ids
    prioritized_countries.select(:country_id)
  end
end
