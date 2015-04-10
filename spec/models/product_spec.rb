require 'rails_helper'

RSpec.describe Product, type: :model, site_scoped: true do
  has_context 'parent site' do
    let(:factory) { :standalone_product }
  end

  has_context 'versioned'
  has_context 'specification'
  has_context 'metadata'
  has_context 'slug' do
    subject { create :product }
  end
  has_context 'taggable'
  has_context 'monies',
              :standalone_product,
              [{ field: :price, calculated: false }]

  context 'table structure' do
    it { is_expected.to have_db_column(:name).of_type(:string) }
    it { is_expected.to have_db_column(:description).of_type(:text) }
    it { is_expected.to have_db_column(:generated_slug).of_type(:string) }
    it { is_expected.to have_db_column(:specified_slug).of_type(:string) }
    it { is_expected.to have_db_column(:gtin).of_type(:string) }
    it { is_expected.to have_db_column(:sku).of_type(:string) }
    it { is_expected.to have_db_column(:price_cents).of_type(:integer) }
    it { is_expected.to have_db_column(:grams).of_type(:integer) }
    it { is_expected.to have_db_column(:active).of_type(:boolean) }
    it { is_expected.to have_db_column(:not_before).of_type(:datetime) }
    it { is_expected.to have_db_column(:not_after).of_type(:datetime) }
  end

  context 'relationships' do
    it { is_expected.to belong_to :tax_override }

    it { is_expected.to have_many :variants }
    it { is_expected.to have_many :variations }
    it { is_expected.to have_many :traits }
    it { is_expected.to have_one :inventory }
    it { is_expected.to have_many :category_members }
    it { is_expected.to have_many :categories }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_presence_of :description }

    context 'instance validations' do
      context 'inventory' do
        subject { create :product }
        context 'without variants' do
          it 'is invalid without inventory specified' do
            expect(subject).not_to be_valid
            expect(subject.errors.full_messages)
              .to include('Inventory must be provided if product '\
                          'does not define variants')
          end
          it 'is valid with inventory specified' do
            subject.inventory = create(:tracked_inventory)
            expect(subject).to be_valid
          end
        end

        context 'with variants' do
          before { create_list(:variant, 2, product: subject) }
          it 'is valid with inventory specified' do
            expect(subject).to be_valid
          end
          it 'is invalid without inventory specified' do
            subject.inventory = create(:tracked_inventory)
            expect(subject).not_to be_valid
            expect(subject.errors.full_messages)
              .to include('Inventory must not be provided if product '\
                          'defines variants')
          end
        end
      end
    end
  end

  context 'categories' do
    subject { create(:standalone_product, :with_categories) }
    it 'associated two subcategories' do
      expect(subject.categories.size).to eq(2)
    end
    it 'category contains product' do
      expect(subject.categories.first.products.first).to eq(subject)
    end
  end

  context 'tax override' do
    let(:tax_category) { create :tax_category }
    subject { create(:standalone_product, tax_override: tax_category) }
    it { is_expected.to be_valid }
    it 'has a unique tax_category' do
      expect(subject.tax_override).not_to eq(Site.current.primary_tax_category)
    end
  end
end
