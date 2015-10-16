require 'rails_helper'

RSpec.describe Metadata do
  before do
    Temping.create :metadata_model do
      include Metadata

      with_columns do |t|
        t.hstore :metadata
        t.json :metadata_fields
      end
    end
  end

  after { Temping.teardown }

  let!(:key) { Faker::Lorem.word }
  let!(:value) { Faker::Lorem.sentence }
  let!(:json_type) { Faker::Lorem.word }
  let!(:json_value) { Faker::Lorem.word }

  subject do
    MetadataModel.new(metadata: { key => value },
                      metadata_fields: [{ type: json_type,
                                          value: json_value }])
  end

  context 'read/write' do
    it 'provides hstore backed metadata' do
      expect(subject).to be_valid
    end

    it 'can retrieve stored metadata value' do
      expect(subject.metadata[key]).to eq(value)
    end

    it 'can retrieve stored json value' do
      expect(subject.metadata_fields[0]['type']).to eq(json_type)
      expect(subject.metadata_fields[0]['value']).to eq(json_value)
    end
  end
end
