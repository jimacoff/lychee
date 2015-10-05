require 'rails_helper'

RSpec.describe PublishSiteJob, type: :job do
  let(:site) { create :site }
  let(:categories_path) do
    paths = Rails.configuration.zepily.publishing.paths
    File.join(paths.base, site.id.to_s, paths.categories)
  end
  let(:products_path) do
    paths = Rails.configuration.zepily.publishing.paths
    File.join(paths.base, site.id.to_s, paths.products)
  end

  before(:each) { Site.current = site }

  it_behaves_like 'jobs::publishing::structure'
  it_behaves_like 'jobs::publishing::images'
  it_behaves_like 'jobs::publishing::categories'
  it_behaves_like 'jobs::publishing::products'
end
