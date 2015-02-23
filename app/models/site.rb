class Site < ActiveRecord::Base
  has_paper_trail

  validates :name, presence: true

  has_many :whitelisted_countries
  has_many :blacklisted_countries
  has_many :countries, through: :whitelisted_countries
  has_many :countries, through: :blacklisted_countries

  has_many :prioritized_countries

  validate :only_whitelisted_or_blacklisted_countries

  def restricts_countries?
    whitelisted_countries.present? || blacklisted_countries.present?
  end

  def only_whitelisted_or_blacklisted_countries
    return unless whitelisted_countries.present? &&
                  blacklisted_countries.present?
    errors.add(:base, 'Cannot specify whitelisted and blacklisted countries')
  end

  class << self
    def current
      Thread.current[:current_site]
    end

    def current=(site)
      Thread.current[:current_site] = site
    end
  end
end
