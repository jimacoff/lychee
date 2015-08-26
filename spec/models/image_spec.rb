require 'rails_helper'

RSpec.describe Image, type: :model, site_scoped: true do
  has_context 'parent site' do
    let(:factory) { :image }
  end
  has_context 'versioned'
  has_context 'metadata'
  has_context 'taggable'

  context 'table structure' do
    it { is_expected.to have_db_column(:description).of_type(:string) }
  end

  context 'relationships' do
    it { is_expected.to have_many :image_files }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :description }

    context 'instance validations' do
      subject { create :image }
      it { is_expected.to be_valid }
    end
  end
end
