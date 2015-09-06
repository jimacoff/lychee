RSpec.shared_examples 'jobs::publishing::categories' do
  context 'categories' do
    context 'file set' do
      let(:category_count) { 5 }
      before do
        create_list(:category, category_count)
        create(:category, enabled: false)
      end

      it 'generates one file per active primary category' do
        expect(site.primary_categories.count)
          .to eq(category_count + 1)

        PublishSiteJob.perform_now(site)

        expect(Dir.glob("#{categories_path}/**/*").length)
          .to eq(category_count)
      end
    end

    context 'file data' do
      context 'delimiters' do
        let!(:primary_category) { create :category, site: site }
        let(:file) do
          File.read(File.join(categories_path, "#{primary_category.id}.json"))
        end

        before { PublishSiteJob.perform_now(site) }

        it 'starts with three dash + json delimiter' do
          expect(file).to start_with("---json\n")
        end
        it 'ends with three dash delimiter' do
          expect(file).to end_with("---\n")
        end
      end

      context 'json' do
        let(:metadata) { nil }
        let(:tags) { [] }
        let(:subcategories) { false }
        let!(:primary_category) do
          if subcategories
            return create :category, :with_subcategories, site: site,
                                                          metadata: metadata,
                                                          tags: tags
          end
          create :category, site: site, metadata: metadata, tags: tags
        end
        let(:file) do
          File.read(File.join(categories_path, "#{primary_category.id}.json"))
            .gsub(/---(json)?/, '')
        end

        shared_examples 'common category fields' do
          it { is_expected.to include(id: category.id) }
          it { is_expected.to include(name: category.name) }
          it { is_expected.to include(description: category.description) }
          it { is_expected.to include(path: category.path) }
          it { is_expected.to include(updated_at: category.updated_at.iso8601) }

          it { is_expected.not_to include(:metadata) }
          it { is_expected.not_to include(:tags) }
          it { is_expected.not_to include(:subcategories) }
        end

        context 'category' do
          let(:category) { primary_category }
          subject do
            JSON.parse(file, symbolize_names: true)
          end

          context 'without subcategories' do
            before { PublishSiteJob.perform_now(site) }
            include_examples 'common category fields'

            context 'with metadata' do
              let(:metadata) { { key: Faker::Lorem.word } }
              it { is_expected.to include(metadata: metadata) }
            end

            context 'with tags' do
              let(:tags) { %W(#{Faker::Lorem.word} #{Faker::Lorem.word}) }
              it { is_expected.to include(tags: tags) }
            end
          end

          context 'with subcategories' do
            let(:subcategories) { true }
            before(:each) do
              category.subcategories.last.update!(enabled: false)
              PublishSiteJob.perform_now(site)
            end

            it { is_expected.to include(:subcategories) }

            it 'includes all active subcategories' do
              expect(subject[:subcategories].length)
                .to eq(category.subcategories.length - 1)
            end
          end

          context 'category members' do
            pending
          end
        end

        context 'subcategory' do
          let(:subcategories) { true }
          let(:json) do
            JSON.parse(file, symbolize_names: true)
          end

          let(:category) { primary_category.subcategories.first }
          subject { json[:subcategories].first }

          before { PublishSiteJob.perform_now(site) }

          include_examples 'common category fields'
          it { is_expected.to include(parent: primary_category.id) }
        end
      end
    end
  end
end
