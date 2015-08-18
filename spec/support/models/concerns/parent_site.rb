RSpec.shared_examples 'parent site' do
  let(:site_factory_instances) { 0 }

  it { is_expected.to be_a_kind_of(ParentSite) }

  context 'table structure' do
    it 'should have non nullable column site_id of type bigint' do
      expect(subject).to have_db_column(:site_id)
        .of_type(:integer)
        .with_options(limit: 8, null: false)
    end
    it { is_expected.to have_db_index(:site_id) }
  end

  context 'relationships' do
    it { is_expected.to belong_to(:site).class_name('Site') }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :site }
  end

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
    let(:scoped_instances) { 1 }
    let(:unscoped_instances) { site_factory_instances + 2 }

    def run
      create(*factory)
      create(*factory, site: site)
    end

    subject { -> { run } }

    it { is_expected.to change(described_class, :count).by(scoped_instances) }
    it do
      is_expected.to change(described_class.unscoped, :count)
        .by(unscoped_instances)
    end
  end
end
