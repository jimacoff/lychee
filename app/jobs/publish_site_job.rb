require 'json'

class PublishSiteJob < ActiveJob::Base
  queue_as :publishing

  START_JSON_DELIMITER = '---json'.freeze
  END_JSON_DELIMITER = '---'.freeze

  include Publishing::Categories

  def perform(site)
    @site = site
    categories
  end
end
