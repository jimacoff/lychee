require 'rails_helper'

RSpec.describe Content do
  before(:all) do
    Temping.create :content_model do
      include Content
    end
  end

  let(:subject) { ContentModel.new }

  describe '#render' do
    it 'throws a failure when not overloaded' do
      expect { subject.render }.to raise_exception('not implemented')
    end
  end

  describe '#path' do
    it 'throws a failure when not overloaded' do
      expect { subject.path }.to raise_exception('not implemented')
    end
  end
end
