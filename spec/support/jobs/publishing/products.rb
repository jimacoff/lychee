RSpec.shared_examples 'jobs::publishing::products' do
  def product_json(p)
    {
      id: p.id,
      name: p.name,
      short_description: p.short_description,
      path: p.path,
      updated_at: p.updated_at.iso8601,
      price_cents: p.price_cents,
      currency: p.currency,
      weight: p.weight
    }
  end

  # rubocop:disable Metrics/MethodLength
  def variation_json(v)
    {
      id: v.id,
      order: v.order,
      render_as: v.render_as,
      trait: {
        id: v.trait.id,
        name: v.trait.name,
        display_name: v.trait.display_name,
        description: v.trait.description
      },
      values: variation_values_json(v)
    }
  end
  # rubocop:enable Metrics/MethodLength

  def variation_values_json(v)
    values = []
    v.variation_values.each do |vi|
      values << {
        id: vi.id,
        name: vi.name,
        description: vi.description
      }
    end
    values
  end

  def specification_json
    {
      categories: [{
        name: Faker::Lorem.word,
        values: [{
          name: Faker::Lorem.word,
          value: Faker::Lorem.word
        }]
      }]
    }
  end

  def categories_json(p)
    categories = []
    p.categories.each do |cat|
      categories << {
        id: cat.id,
        name: cat.name,
        description: cat.description,
        path: cat.path
      }
    end
    categories
  end

  context 'products' do
    let(:builder) do
      Jbuilder.encode do |json|
        described_class.new.product(json, product)
      end
    end
    let(:product) { create :product, site: site }
    let(:json) { product_json(product) }
    subject { JSON.parse(builder, symbolize_names: true) }

    context 'file set' do
      let(:enabled_product_count) { 5 }
      before do
        create_list(:product, enabled_product_count)
        create(:product, enabled: false)
        PublishSiteJob.perform_now(site)
      end

      it 'generates one file per active product' do
        expect(site.products.count)
          .to eq(enabled_product_count + 1)

        expect(Dir.glob("#{products_path}/**/*").length)
          .to eq(enabled_product_count)
      end

      context 'file data' do
        let(:product) { Site.current.products.enabled.sample }
        let(:file) do
          File.read(File.join(products_path, "#{product.id}.html"))
        end
        let(:regex) { /---json\n(.*)---\n\n(.*)\n/m }
        let(:frontmatter) { file.match(regex)[1] }
        let(:description) { file.match(regex)[2] }

        context 'frontmatter' do
          subject { JSON.parse(frontmatter, symbolize_names: true) }
          it { is_expected.to match(json) }
        end

        context 'content' do
          subject { description }
          it { is_expected.to match(product.description) }
        end
      end
    end

    context 'with minimal data' do
      it { is_expected.to match(json) }
    end

    context 'with metadata' do
      let(:metadata) { { key: Faker::Lorem.word } }
      let(:product) do
        create :product, metadata: metadata, site: site
      end
      before { json[:metadata] = metadata }

      it { is_expected.to match(json) }
    end

    context 'with tags' do
      let(:tags) { Faker::Lorem.words(2) }
      let(:product) do
        create :product, tags: tags, site: site
      end
      before { json[:tags] = tags }

      it { is_expected.to match(json) }
    end

    context 'with gtin' do
      let(:gtin) { Faker::Lorem.word }
      let(:product) do
        create :product, gtin: gtin, site: site
      end
      before { json[:gtin] = gtin }

      it { is_expected.to match(json) }
    end

    context 'with sku' do
      let(:sku) { Faker::Lorem.word }
      let(:product) do
        create :product, sku: sku, site: site
      end
      before { json[:sku] = sku }

      it { is_expected.to match(json) }
    end

    context 'with specifications' do
      let(:specs) { specification_json }
      let(:product) do
        create :product, specifications: specs, site: site
      end
      before { json[:specifications] = specs }

      it { is_expected.to match(json) }
    end

    context 'with images' do
      let(:image_count) { 5 }
      before do
        FactoryGirl.create_list :image_instance, 5, imageable: product,
                                                    site: site
      end

      it 'has all child images' do
        expect(subject[:images].size).to eq(image_count)
      end
    end

    context 'with variants' do
      let(:product) do
        create :product, :with_variants, site: site
      end

      before do
        json[:variations] = []
        product.variations.each do |var|
          json[:variations] << variation_json(var)
        end
      end

      it { is_expected.to match(json) }

      context 'variations have metadata' do
        let(:metadata) { { key: Faker::Lorem.word } }
        before do
          product.variations.each { |var| var.metadata = metadata }
          json[:variations].each { |var| var[:metadata] = metadata }
        end

        it { is_expected.to match(json) }
      end

      context 'variation values have image_instance' do
        let(:metadata) { { key: Faker::Lorem.word } }
        before do
          product.variations.each do |var|
            var.variation_values.each do |vv|
              vv.image_instance = create :image_instance, imageable: vv,
                                                          site: site
            end
          end
        end

        it 'has all child images' do
          expect(subject[:variations])
            .to all include(values: all(have_key(:image)))
        end
      end
    end

    context 'with categories' do
      let(:product) do
        create :product, :with_categories, site: site
      end
      before { json[:categories] = categories_json(product) }

      it { is_expected.to match(json) }
    end
  end
end
