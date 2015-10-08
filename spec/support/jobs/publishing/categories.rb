RSpec.shared_examples 'jobs::publishing::categories' do
  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def category_member_json(cm)
    p = cm.product
    {
      id: cm.id,
      order: cm.order,
      description: cm.description || p.description,
      product: {
        name: p.name,
        uri_path: p.uri_path,
        currency: p.currency,
        weight: p.weight,
        product_id: p.id,
        price_cents: p.price_cents
      }
    }.compact
  end

  def category_json(c)
    category = {
      template: 'category',
      format: 'html',
      id: c.id,
      name: c.name,
      description: c.description,
      uri_path: c.uri_path,
      updated_at: c.updated_at.iso8601,
      category_members:
        c.category_members.map { |e| category_member_json(e) },
      parent: c.parent_category.try(:id)
    }.compact

    if c.subcategories.present?
      category[:subcategories] =
        c.subcategories.map { |e| category_json(e) if e.routable? }.compact
    end
    category
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  context 'categories' do
    let(:builder) do
      Jbuilder.encode do |json|
        described_class.new.category(json, category)
      end
    end
    let(:json) { category_json(category) }

    context 'file set' do
      let(:file_path) { File.join(categories_path, "#{category.id}.json") }
      let(:file_content) do
        File.read(file_path)
      end

      context 'routable category' do
        context 'file data' do
          context 'delimiters' do
            let!(:category) { create :category, :routable }

            before { PublishSiteJob.perform_now }

            it 'starts with three dash + json delimiter' do
              expect(file_content).to start_with("---json\n")
            end

            it 'ends with three dash delimiter' do
              expect(file_content).to end_with("---\n")
            end

            context 'json' do
              let(:file_content) do
                File.read(file_path).gsub(/---(json)?/, '')
              end
              subject { JSON.parse(file_content, symbolize_names: true) }
              it { is_expected.to match(json) }
            end
          end
        end
      end

      context 'nonroutable categories' do
        let(:routable_category_count) { 5 }
        before do
          create_list(:category, routable_category_count, :routable)
          create(:category, :routable, enabled: false)
          create(:category)
          PublishSiteJob.perform_now
        end

        it 'generates one file per routable primary category' do
          expect(site.primary_categories.count)
            .to eq(routable_category_count + 2)

          # Non routable categories are not rendered
          expect(Dir.glob("#{categories_path}/**/*").length)
            .to eq(routable_category_count)
        end
      end
    end

    context 'category' do
      let(:category) { create :category, :routable, site: site }
      subject { JSON.parse(builder, symbolize_names: true) }

      context 'with minimal data' do
        it { is_expected.to match(json) }
      end

      context 'with metadata' do
        let(:metadata) { { key: Faker::Lorem.word } }
        let(:category) do
          create :category, :routable, metadata: metadata, site: site
        end
        before { json[:metadata] = metadata }

        it { is_expected.to match(json) }
      end

      context 'with tags' do
        let(:tags) { Faker::Lorem.words(2) }
        let(:category) do
          create :category, :routable, tags: tags, site: site
        end
        before { json[:tags] = tags }

        it { is_expected.to match(json) }
      end

      context 'with parent' do
        let(:parent_category) { create :category }
        let(:category) do
          create :category, :routable, parent_category: parent_category,
                                       site: site
        end

        it { is_expected.to match(json) }
      end

      context 'category members' do
        let(:count) { 3 }
        let!(:category_members) do
          create_list :category_member, count, category: category, site: site
        end

        it 'has all category_members where product is active' do
          expect(subject[:category_members].size).to eq(count)
        end

        it 'has the local description' do
          expect(subject[:category_members][0][:description])
            .to eq(category_members.first.description)
        end

        it { is_expected.to match(json) }

        context 'disabled products' do
          before { category_members.sample.product.update(enabled: false) }
          it 'has only category_members where product is active' do
            expect(subject[:category_members].size).to eq(count - 1)
          end
        end

        context 'without local description' do
          before { category_members.each { |cm| cm.update(description: nil) } }
          it 'has products description' do
            expect(subject[:category_members][0][:description])
              .to eq(category_members.first.product.description)
          end

          it { is_expected.to match(json) }
        end

        context 'with product images' do
          before do
            category_members.each do |cm|
              create :image_instance, imageable: cm, site: site
            end
          end

          it 'has image json' do
            expect(subject[:category_members]).to all(have_key(:image_instance))
          end
        end

        context 'with product metadata' do
          let(:metadata) { { key: Faker::Lorem.word } }
          let!(:category_members) do
            create_list :category_member, count, category: category, site: site
          end
          before do
            category_members.each do |cm|
              cm.product.update!(metadata: metadata)
            end
            json[:category_members].each do |p|
              p[:product][:metadata] = metadata
            end
          end

          it { is_expected.to match(json) }
        end

        context 'with product tags' do
          let(:tags) { Faker::Lorem.words(2) }
          let!(:category_members) do
            create_list :category_member, 3, category: category, site: site
          end
          before do
            category_members.each { |cm| cm.product.update!(tags: tags) }
            json[:category_members].each { |p| p[:product][:tags] = tags }
          end

          it { is_expected.to match(json) }
        end
      end

      context 'subcategories' do
        let(:count) { 4 }
        let(:category) do
          create :category, :routable
        end

        before do
          category.subcategories =
            create_list(:category, count, :routable, parent_category: category)

          category.subcategories << create(:category)
          category
            .subcategories << create(:category, :routable, enabled: false)
        end

        it 'has all active subcategories' do
          expect(subject[:subcategories].size).to eq(count)
        end

        it { is_expected.to match(json) }
      end
    end
  end
end
