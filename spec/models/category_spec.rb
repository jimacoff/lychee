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
    it { is_expected.to have_db_column(:generated_slug).of_type(:string) }
    it { is_expected.to have_db_column(:specified_slug).of_type(:string) }

    it { is_expected.to have_db_index([:site_id, :name]).unique }
    it { is_expected.to have_db_index([:site_id, :generated_slug]).unique }
    it { is_expected.to have_db_index([:site_id, :specified_slug]).unique }
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

  describe '#render' do
    it 'Not implemented.'
  end

  describe '#path' do
    subject { create(:category) }

    context 'using a generated_slug' do
      it 'equals reserved_paths category preferences / generated_slug' do
        expect(subject.path)
          .to eq("#{subject.site.preferences.reserved_paths['categories']}" \
                 "/#{subject.generated_slug}")
      end
    end

    context 'using a specified_slug' do
      it 'equals reserved_paths category preferences / specified_slug' do
        subject.specified_slug = "#{Faker::Lorem.word}-#{Faker::Lorem.word}"
        expect(subject.path)
          .to eq("#{subject.site.preferences.reserved_paths['categories']}" \
                 "/#{subject.specified_slug}")
      end
    end

    context 'with one or more parent categories' do
      it 'builds path as a tree'
    end
  end
end
