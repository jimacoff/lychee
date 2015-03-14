RSpec.shared_examples 'taggable' do
  it { is_expected.to be_a_kind_of(Taggable) }

  it 'has defined tags field as text array' do
    expect(subject).to have_db_column(:tags)
      .of_type(:text).with_options(array: false, default: [])
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

RSpec.shared_examples 'pricing' do
  it { is_expected.to be_a_kind_of(Pricing) }

  describe '#price_cents=' do
    it 'is not callable' do
      expect { (subject.price_cents = 1) }.to raise_error
        .with_message('price_cents cannot be directly set, use #price')
    end
  end
  describe '#price_currency=' do
    it 'is not callable' do
      expect { subject.price_currency = 'JPY' }.to raise_error
        .with_message('Currency cannot be set, use Site.current#currency')
    end
  end

  describe '#price=' do
    it 'sets price by decimal' do
      subject.price = 1.11
      expect(subject.price.fractional).to eq(111)
      expect(subject.price.currency).to eq(Site.current.currency)
    end
    it 'sets price by cents' do
      subject.price = 999
      expect(subject.price.fractional).to eq(999)
      expect(subject.price.currency).to eq(Site.current.currency)
    end
    context 'currency' do
      before do
        subject.site.currency = 'CAD'
        subject.site.save!
        subject.price = 111
      end
      it 'has the same currency as parent site' do
        expect(subject.price.currency).to eq(Site.current.currency)
      end
      it 'has a site currency of CAD' do
        expect(Site.current.currency.iso_code).to eq('CAD')
      end
      after do
        subject.site.currency = 'AUD'
        subject.site.save!
      end
    end
  end

  describe '#price' do
    it 'returns dollars as Money' do
      expect(subject.price).to be_a Money
    end
    # Ensure any future library change doesn't bite us as this got
    # modified between 5.y and 6.y
    it 'returns dollars as BigDecimal' do
      expect(subject.price.dollars).to be_a BigDecimal
    end
    it 'returns amount as BigDecimal' do
      expect(subject.price.dollars).to be_a BigDecimal
    end
  end
end
