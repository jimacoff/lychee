require 'rails_helper'

RSpec.describe PublishSiteJob, type: :job do
  let(:site) { create :site }
  let(:categories_path) do
    paths = Rails.configuration.zepily.publishing.paths
    File.join(paths.base, site.id.to_s, paths.categories)
  end

  before(:each) { Site.current = site }

  include_examples 'jobs::publishing::categories'
end
