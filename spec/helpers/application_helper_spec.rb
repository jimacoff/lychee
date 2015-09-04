require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  context '#icon_tag' do
    it 'returns a FontAwesome icon tag' do
      expect(helper.icon_tag('xyz')).to eq('<i class="fa fa-xyz"></i>')
    end
  end
end
