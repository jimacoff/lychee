require 'rails_helper'

RSpec.describe Product, type: :model, site_scoped: true do
  has_context 'parent site' do
    let(:factory) { :standalone_product }
  end

  has_context 'versioned'
  has_context 'specification'
  has_context 'monies',
              :standalone_product,
              [{ field: :price, calculated: false }]
  has_context 'enablement' do
    let(:factory) { :standalone_product }
  end
  has_context 'content' do
    let(:factory) { :standalone_product }
  end
  has_context 'markup'

  context 'table structure' do
    it { is_expected.to have_db_column(:name).of_type(:string) }
    it { is_expected.to have_db_column(:description).of_type(:string) }
    it { is_expected.to have_db_column(:gtin).of_type(:string) }
    it { is_expected.to have_db_column(:sku).of_type(:string) }
    it { is_expected.to have_db_column(:price_cents).of_type(:integer) }
    it do
      is_expected.to have_db_column(:weight).of_type(:integer)
        .with_options(default: 0)
    end
    it { is_expected.to have_db_column(:active).of_type(:boolean) }
    it { is_expected.to have_db_column(:not_before).of_type(:datetime) }
    it { is_expected.to have_db_column(:not_after).of_type(:datetime) }

    it 'should have non nullable column tax_override_id of type bigint' do
      expect(subject).to have_db_column(:tax_override_id)
        .of_type(:integer)
        .with_options(limit: 8, null: true)
    end
    it { is_expected.to have_db_index(:tax_override_id) }

    it { is_expected.to have_db_index([:site_id, :name]).unique }
  end

  context 'relationships' do
    it { is_expected.to belong_to(:tax_override).class_name('TaxCategory') }

    it { is_expected.to have_many :variants }
    it { is_expected.to have_many :variations }
    it { is_expected.to have_many :traits }
    it { is_expected.to have_one :inventory }
    it { is_expected.to have_many :category_members }
    it { is_expected.to have_many :categories }
    it { is_expected.to have_many :image_instances }
    it { is_expected.to have_many :images }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_presence_of :description }
    it { is_expected.to validate_numericality_of(:weight).allow_nil }

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
            subject.inventory = create(:tracked_inventory, product: subject)
            expect(subject).to be_valid
          end
        end

        context 'with variants' do
          before { create_list(:variant, 2, product: subject) }
          it 'is valid without inventory specified' do
            expect(subject).to be_valid
          end
          it 'is invalid with inventory specified' do
            subject.inventory = create(:tracked_inventory, product: subject)
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

  describe '#variant' do
    let!(:product) { create(:product) }

    let(:size_trait) do
      create(:trait, name: 'size', default_values: %w(small medium large))
    end

    let(:color_trait) do
      create(:trait, name: 'color', default_values: %w(azure taupe indigo))
    end

    let(:size) { create(:variation, product: product, trait: size_trait) }
    let(:color) { create(:variation, product: product, trait: color_trait) }

    def create_default_values(trait)
      trait.default_values.reduce({}) do |hash, value|
        attrs = { name: value, order: 1, description: 'x' }
        hash.merge(value => size.variation_values.create!(attrs))
      end
    end

    let(:size_values)  { create_default_values(size_trait) }
    let(:color_values) { create_default_values(color_trait) }

    let(:opts1) do
      { size.id => size_values['small'], color.id => color_values['azure'] }
    end

    let(:opts2) do
      { size.id => size_values['medium'], color.id => color_values['taupe'] }
    end

    def variant_with(opts)
      create(:variant, product: product).tap do |variant|
        opts.each do |k, v|
          attrs = { variation_id: k, variation_value: v }
          variant.variation_instances.create!(attrs)
        end
      end
    end

    context 'with a matching variant' do
      let!(:variant1) { variant_with(opts1) }
      let!(:variant2) { variant_with(opts2) }

      it 'returns the variant' do
        expect(product.variant(opts1)).to eq(variant1)
        expect(product.variant(opts2)).to eq(variant2)
      end

      it 'returns in a single query' do
        expect { product.variant(opts1) }.not_to exceed_query_limit(1)
      end
    end

    context 'with a partially matched variant' do
      let!(:variant) { variant_with(opts1) }

      it 'returns nil' do
        expect(product.variant(opts1.slice(size.id))).to be_nil
      end
    end

    context 'with no matching variant' do
      it 'returns nil' do
        expect(product.variant(opts1)).to be_nil
      end
    end
  end

  describe '#create_default_path' do
    subject { create :product }

    shared_examples 'product path behaviours' do
      it 'creates a valid path' do
        expect(subject.path).to be_valid
      end

      it 'creates a path which routes to us' do
        expect(subject.path.routable).to eq(subject)
      end
    end

    context 'When site has reserved product assets path' do
      before { subject.create_default_path }

      include_examples 'product path behaviours'

      it 'sets path uri to include site product assets path' do
        expect(subject.uri_path).to eq(
          "#{subject.site.preferences.reserved_paths['products']}" \
          "/#{subject.name.to_url}")
      end
    end

    context 'When site has no reserved product assets path' do
      before do
        subject.site.preferences.reserved_paths.delete('products')
        subject.create_default_path
      end

      include_examples 'product path behaviours'

      it 'sets path uri to include site product assets path' do
        expect(subject.uri_path).to eq("/#{subject.name.to_url}")
      end
    end
  end

  describe '#default_parent_path' do
    let(:product_reserved_path) do
      product.site.preferences.reserved_path('products')
    end
    let(:product) { create :product }
    subject { product.default_parent_path }

    context 'no site default' do
      before do
        product.site.preferences.reserved_paths.delete('products')
      end
      it { is_expected.to be_nil }
    end

    context 'with site default' do
      it { is_expected.to eq(Path.find_by_path(product_reserved_path)) }
    end
  end
end
