RSpec.shared_examples 'jobs::publishing::products' do
  # rubocop:disable Metrics/MethodLength
  def product_json(p)
    {
      template: 'product',
      format: p.markup_format,
      id: p.id,
      name: p.name,
      description: p.description,
      uri_path: p.uri_path,
      updated_at: p.updated_at.iso8601,
      price_cents: p.price_cents,
      currency: p.currency,
      weight: p.weight
    }
  end

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
    let(:json) { product_json(product) }

    context 'file set' do
      let(:enabled_product_count) { 5 }
      let(:file_path) { File.join(products_path, "#{product.id}.html") }
      let(:file_content) do
        File.read(file_path)
      end
      before do
        create_list(:product, enabled_product_count, :routable)
        create(:product)
        PublishSiteJob.perform_now
      end

      context 'routable product' do
        context 'file data' do
          let(:product) { Site.current.products.enabled.sample }
          let(:regex) { /---json\n(.*)---\n\n(.*)\n/m }
          let(:frontmatter) { file_content.match(regex)[1] }
          let(:description) { file_content.match(regex)[2] }

          context 'frontmatter' do
            subject { JSON.parse(frontmatter, symbolize_names: true) }
            it { is_expected.to match(json) }
          end

          context 'content' do
            subject { description }
            it { is_expected.to match(product.markup) }
          end
        end
      end

      it 'generates one file per routable product' do
        expect(site.products.count)
          .to eq(enabled_product_count + 1)

        expect(Dir.glob("#{products_path}/**/*").length)
          .to eq(enabled_product_count)
      end
    end

    context 'product' do
      let(:product) { create(:product, :routable, site: site) }
      subject { JSON.parse(builder, symbolize_names: true) }

      context 'with minimal data' do
        it { is_expected.to match(json) }
      end

      context 'with metadata' do
        let(:metadata) { { key: Faker::Lorem.word } }
        let(:product) do
          create :product, :routable, metadata: metadata, site: site
        end
        before { json[:metadata] = metadata }

        it { is_expected.to match(json) }
      end

      context 'with tags' do
        let(:tags) { Faker::Lorem.words(2) }
        let(:product) do
          create :product, :routable, tags: tags, site: site
        end
        before { json[:tags] = tags }

        it { is_expected.to match(json) }
      end

      context 'with gtin' do
        let(:gtin) { Faker::Lorem.word }
        let(:product) do
          create :product, :routable, gtin: gtin, site: site
        end
        before { json[:gtin] = gtin }

        it { is_expected.to match(json) }
      end

      context 'with sku' do
        let(:sku) { Faker::Lorem.word }
        let(:product) do
          create :product, :routable, sku: sku, site: site
        end
        before { json[:sku] = sku }

        it { is_expected.to match(json) }
      end

      context 'with specifications' do
        let(:specs) { specification_json }
        let(:product) do
          create :product, :routable, specifications: specs, site: site
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
          expect(subject[:image_instances].size).to eq(image_count)
        end
      end

      context 'with variants' do
        let(:product) do
          create :product, :routable, :with_variants, site: site
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
              .to all include(values: all(have_key(:image_instance)))
          end
        end
      end

      context 'with categories' do
        let(:product) do
          create :product, :routable, :with_categories, site: site
        end
        before { json[:categories] = categories_json(product) }

        it { is_expected.to match(json) }
      end
    end
  end
end
