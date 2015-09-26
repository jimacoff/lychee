require 'json'

class PublishSiteJob < ActiveJob::Base
  queue_as :publishing

  START_JSON_DELIMITER = '---json'.freeze
  END_JSON_DELIMITER = '---'.freeze

  include Publishing::Images
  include Publishing::Categories
  include Publishing::Products

  def perform(site)
    Site.current = site
    categories
    products
  end

  private

  def optional_fields(json, obj, fields)
    fields.each do |f|
      var = obj.send(f)
      if var.respond_to?(:empty?)
        json.set! f, var unless var.empty?
      else
        json.set! f, var if var
      end
    end
  end
end
