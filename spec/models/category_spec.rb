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

  describe '#create_default_path' do
    subject { create :category }

    shared_examples 'category path behaviours' do
      it 'creates a valid path' do
        expect(subject.path).to be_valid
      end

      it 'creates a path which routes to us' do
        expect(subject.path.routable).to eq(subject)
      end
    end

    context 'When category has parent with path' do
      let(:parent_category) { create :category, :routable }
      before do
        parent_category.subcategories << subject
        subject.create_default_path
      end

      include_examples 'category path behaviours'

      it 'sets path uri to include parent category path' do
        expect(subject.uri_path).to eq(
          "#{parent_category.uri_path}" \
          "/#{subject.name.to_url}")
      end
    end

    context 'When category has parent with no path' do
      let(:parent_category) { create :category }
      before do
        parent_category.subcategories << subject
        subject.create_default_path
      end

      include_examples 'category path behaviours'

      it 'sets path uri to include parent category path' do
        expect(subject.uri_path).to eq(
          "#{subject.site.preferences.reserved_paths['categories']}" \
          "/#{subject.name.to_url}")
      end
    end

    context 'When site has reserved category assets path' do
      before { subject.create_default_path }

      include_examples 'category path behaviours'

      it 'sets path uri to include site category assets path' do
        expect(subject.uri_path).to eq(
          "#{subject.site.preferences.reserved_paths['categories']}" \
          "/#{subject.name.to_url}")
      end
    end

    context 'When site has no reserved category assets path' do
      before do
        subject.site.preferences.reserved_paths.delete('categories')
        subject.create_default_path
      end

      include_examples 'category path behaviours'

      it 'sets path uri to include site category assets path' do
        expect(subject.uri_path).to eq("/#{subject.name.to_url}")
      end
    end
  end
end
