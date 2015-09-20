require 'rails_helper'

RSpec.describe Metadata do
  before(:all) do
    Temping.create :metadata_model do
      include Metadata

      with_columns do |t|
        t.hstore :metadata
      end
    end
  end

  let!(:key) { Faker::Lorem.word }
  let!(:value) { Faker::Lorem.sentence }

  subject { MetadataModel.new(metadata: { key => value }) }

  context 'read/write' do
    it 'stores json backed metadata' do
      expect(subject).to be_valid
    end

    it 'can retrieve stored json value' do
      expect(subject.metadata[key]).to eq(value)
    end
  end
end
