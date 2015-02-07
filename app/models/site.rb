class Site < ActiveRecord::Base
  validates :name, presence: true

  class << self
    def current
      Thread.current[:current_site]
    end

    def current=(site)
      Thread.current[:current_site] = site
    end
  end
end
