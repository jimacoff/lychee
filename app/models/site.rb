class Site < ActiveRecord::Base
  has_paper_trail

  validates :name, presence: true

  has_many :whitelisted_countries
  has_many :blacklisted_countries

  has_many :prioritized_countries

  validate :only_whitelisted_or_blacklisted_countries
  validate :prioritized_countries_are_valid

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

  class << self
    def current
      Thread.current[:current_site]
    end

    def current=(site)
      Thread.current[:current_site] = site
    end
  end

  private

  def intersection(country_type)
    country_type.where(country_id: prioritized_country_ids)
  end

  def prioritized_country_ids
    prioritized_countries.select(:country_id)
  end
end
