require 'rails_helper'

RSpec.describe PrioritizedCountry, type: :model, site_scoped: true do
  has_context 'parent site' do
    let(:factory) { :prioritized_country }
  end
  has_context 'parent country' do
    let(:factory) { :prioritized_country }
  end
  has_context 'versioned'

  context 'table structure' do
  end

  context 'relationships' do
  end

  context 'validations' do
    context 'instance validations' do
    end
  end
end
