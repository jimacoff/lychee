require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper, site_scoped: true do
  describe '#responsive_image' do
    let(:sizes) { '(min-width 40em) 100vw, 50vw' }
    let(:classes) { Faker::Lorem.word.to_s }
    let(:ii) { create :image_instance, :routable }
    let(:default_image) { ii.image.image_files.default_image }
    let(:expected_html_src) do
      "<img src=\"#{default_image.uri_path}\" " \
      "srcset=\"#{ii.image.srcset_path}\" " \
      "sizes=\"#{sizes}\" alt=\"#{ii.description}\" " \
      "class=\"#{classes}\"></img>"
    end
    it 'provides an img tag with responsive elements' do
      expect(helper.responsive_image(ii, sizes, classes))
        .to eq(expected_html_src)
    end
  end
end
