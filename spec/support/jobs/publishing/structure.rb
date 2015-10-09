RSpec.shared_examples 'jobs::publishing::structure' do
  def site_structure_json(site)
    {
      id: site.id,
      name: site.name,
      currency: currency_json(site.currency),
      preferences: preferences_json(site.preferences),
      categories: [],
      products: [],
      images: []
    }.compact
  end

  def currency_json(currency)
    keys = [:decimal_mark, :iso_code, :iso_numeric, :name,
            :priority, :subunit, :subunit_to_unit, :symbol,
            :symbol_first, :thousands_separator]

    keys.reduce({}) { |a, e| a.merge(e => currency.send(e)) }
  end

  def preferences_json(preferences)
    keys = [:tax_basis, :prices_include_tax,
            :order_subtotal_include_tax]

    json = keys.reduce({}) { |a, e| a.merge(e => preferences.send(e)) }
    json[:reserved_uri_paths] = preferences.reserved_uri_paths.symbolize_keys
    json
  end

  context 'site structure' do
    let(:json) { site_structure_json(Site.current) }
    let(:builder) do
      Jbuilder.encode do |json|
        described_class.new.structure(json)
      end
    end
    subject { JSON.parse(builder, symbolize_names: true) }

    context 'file output' do
      let(:structure_file) do
        paths = Rails.configuration.zepily.publishing.paths
        File.join(paths.base, Site.current.id.to_s, 'site_structure.json')
      end

      before do
        PublishSiteJob.perform_now
      end

      it 'generates a site_structure.json' do
        expect(File.exist?(structure_file)).to be_truthy
      end

      context 'json' do
        let(:data) do
          File.read(File.join(structure_file))
        end
        subject { JSON.parse(data, symbolize_names: true) }
        it { is_expected.to match(json) }
      end
    end

    context 'with minimal data' do
      it { is_expected.to match(json) }
    end

    context 'preferences' do
      context 'with metadata' do
        let(:metadata) { { key: Faker::Lorem.word } }
        before do
          Site.current.preferences.metadata = metadata
          json[:preferences][:metadata] = metadata
        end

        it { is_expected.to match(json) }
      end
    end

    context 'categories' do
      let(:routable_count) { 4 }
      before do
        create_list :category, routable_count, :routable
        create :category, :routable, enabled: false
        create :category
      end

      it 'create all categories' do
        expect(Category.count).to eq(routable_count + 2)
      end

      it 'has all active primary categories' do
        expect(subject[:categories].size).to eq(routable_count)
      end
    end

    context 'products' do
      let(:routable_count) { 4 }
      before do
        create_list :standalone_product, routable_count, :routable
        create :standalone_product, :routable, enabled: false
        create :standalone_product
      end

      it 'create all products' do
        expect(Product.count).to eq(routable_count + 2)
      end

      it 'has all active products' do
        expect(subject[:products].size).to eq(routable_count)
      end
    end

    context 'images' do
      let(:routable_count) { 4 }
      before do
        create_list :image, routable_count, :routable
        create :image
        create :image, enabled: false
        disabled_image_file = create :image
        disabled_image_file.image_files.default_image.update(enabled: false)
      end

      it 'create all images' do
        expect(Image.count).to eq(routable_count + 3)
      end

      it 'has all images' do
        expect(subject[:images].size).to eq(routable_count)
      end
    end
  end
end
