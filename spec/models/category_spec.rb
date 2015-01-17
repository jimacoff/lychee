require 'rails_helper'

RSpec.describe Category, type: :model do
  has_context 'metadata'
  has_context 'slug' do
    subject { create :category }
  end

  context 'table structure' do
    it { is_expected.to have_db_column(:name).of_type(:string) }
    it { is_expected.to have_db_column(:description).of_type(:text) }
    it { is_expected.to have_db_column(:generated_slug).of_type(:string) }
    it { is_expected.to have_db_column(:specified_slug).of_type(:string) }
  end

  context 'relationships' do
    it { is_expected.to belong_to(:parent_category) }
    it { is_expected.to have_many(:subcategories) }
    it { is_expected.to have_and_belong_to_many :products }
    it { is_expected.to have_and_belong_to_many :variants }
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
