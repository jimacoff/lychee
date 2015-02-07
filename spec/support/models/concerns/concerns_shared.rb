RSpec.shared_examples 'taggable' do
  it { is_expected.to be_a_kind_of(Taggable) }

  it 'has defined tags field as text array' do
    expect(subject).to have_db_column(:tags)
      .of_type(:text).with_options(array: false, default: {})
  end
end

RSpec.shared_examples 'metadata' do
  it { is_expected.to be_a_kind_of(Metadata) }

  it { is_expected.to have_db_column(:metadata).of_type(:hstore) }
end

RSpec.shared_examples 'specification' do
  it { is_expected.to be_a_kind_of(Specification) }

  it { is_expected.to have_db_column(:specifications).of_type(:json) }
end

RSpec.shared_examples 'slug' do
  it { is_expected.to be_a_kind_of(Slug) }
  it { is_expected.to have_db_column(:generated_slug).of_type(:string) }
  it { is_expected.to have_db_column(:specified_slug).of_type(:string) }

  context 'generated slug' do
    it 'is generated from name' do
      expect(subject.generated_slug).to eq(subject.name.to_url)
    end
  end
end

RSpec.shared_examples 'parent site' do
  it { is_expected.to be_a_kind_of(ParentSite) }
  it { is_expected.to belong_to(:site) }
  it { is_expected.to validate_presence_of(:site) }

  context 'default_scope' do
    Thread.new do
      before(:each) { Site.current = nil }

      it 'has a default_scope that constrains finders to the active site' do
        expect(described_class.all.where_values_hash).to have_key('site_id')
      end

      it 'has a nil site when not set in Thread.current' do
        expect(described_class.all.where_values_hash['site_id']).to be_nil
      end

      context 'with a site specified as current in Thread.current' do
        let(:site) { create(:site) }
        before { Site.current = site }
        after { Site.current = nil }
        it 'correctly references the active site' do
          expect(described_class.all.where_values_hash['site_id'])
            .to eq(site.id)
        end
      end
    end
  end

  context 'scoping' do
    let(:site) { create(:site) }

    def run
      create(factory)
      create(factory, site: site)
    end

    subject { -> { run } }

    it { is_expected.to change(described_class, :count).by(1) }
    it { is_expected.to change(described_class.unscoped, :count).by(2) }
  end
end
