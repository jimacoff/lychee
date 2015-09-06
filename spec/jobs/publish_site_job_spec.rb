require 'rails_helper'

require 'fakefs/spec_helpers'

RSpec.describe PublishSiteJob, type: :job do
  include FakeFS::SpecHelpers

  let(:site) { create :site }
  let(:categories_path) do
    paths = Rails.configuration.zepily.publishing.paths
    File.join(paths.base, site.id.to_s, paths.categories)
  end

  before(:all) { FakeFS::FileSystem.clone(Rails.root.join('app')) }
  before(:each) { Site.current = site }

  include_examples 'jobs::publishing::categories'
end
