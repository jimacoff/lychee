require 'rails_helper'

RSpec.describe Routable do
  before do
    Temping.create :Routable_model do
      include Routable
    end
  end

  after { Temping.teardown }

  subject { RoutableModel.new }

  describe '#create_default_path' do
    it 'throws when not implemented' do
      expect { subject.create_default_path }
        .to raise_error.with_message('not implemented')
    end
  end
end
