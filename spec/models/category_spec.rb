require 'rails_helper'

RSpec.describe Category, type: :model, site_scoped: true do
  has_context 'parent site' do
    let(:factory) { :category }
  end

  has_context 'versioned'
  has_context 'enablement' do
    let(:factory) { :category }
  end
  has_context 'content' do
    let(:factory) { :category }
  end

  context 'table structure' do
    it { is_expected.to have_db_column(:name).of_type(:string) }
    it { is_expected.to have_db_column(:description).of_type(:text) }

    it { is_expected.to have_db_index([:site_id, :name]).unique }
  end

  context 'relationships' do
    it { is_expected.to belong_to(:parent_category) }
    it { is_expected.to have_many(:subcategories) }
    it { is_expected.to have_many :category_members }
    it { is_expected.to have_many :products }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:description) }
  end

  context 'category hierachy' do
    subject { create :category, :with_subcategories }

    it 'has four subcategories' do
      expect(subject.subcategories.size).to eq(4)
    end
    it 'subcategories correctly identify parent' do
      expect(subject.subcategories.first.parent_category).to eq(subject)
    end
  end
end
