require 'rails_helper'

RSpec.describe Slug do
  before do
    Temping.create :slug_model do
      include Slug

      with_columns do |t|
        t.integer :site_id, null: false
        t.string :name, null: false
        t.string :generated_slug, null: false
        t.string :specified_slug
      end
    end
  end

  after { Temping.teardown }

  subject { SlugModel.new(name: Faker::Lorem.sentence, site_id: rand(1..100)) }
  let(:specified_slug) { Faker::Lorem.sentence.to_url }

  context 'validations' do
    it { is_expected.to validate_presence_of(:name) }
  end

  describe '#slug' do
    it 'provides generated_slug by default' do
      expect(subject.slug).to eq(subject.generated_slug)
    end
    it 'provides specified_slug when set' do
      subject.specified_slug = specified_slug
      expect(subject.slug).to eq(subject.specified_slug)
    end
    it 'updates on name change' do
      subject.name = Faker::Lorem.sentence
      expect { subject.save! }
        .to change(subject, :generated_slug).to(subject.name.to_url)
    end
  end

  describe '#slug=' do
    it 'updates the specified_slug' do
      expect { subject.slug = specified_slug }
        .to change(subject, :specified_slug).to(specified_slug)
        .and change(subject, :slug).to(specified_slug)
        .and not_change(subject, :generated_slug)
    end
  end
end
