require 'spec_helper'
require 'dasherized_routes'

RSpec.describe DasherizedRoutes do
  let(:base) do
    Class.new do
      def resource(*args)
        args
      end

      def resources(*args)
        args
      end
    end
  end

  let(:klass) { Class.new(base) { include DasherizedRoutes } }
  subject { klass.new }

  context '#resource' do
    it 'adds the path to the route' do
      route = subject.resource(:test_object)
      expect(route).to eq([:test_object, path: 'test-object'])
    end

    it 'respects an explicit path in the route' do
      route = subject.resource(:test_object, path: 'xyz')
      expect(route).to eq([:test_object, path: 'xyz'])
    end

    it 'passes other options through' do
      route = subject.resource(:test_object, only: %i(get))
      expect(route).to eq([:test_object, path: 'test-object', only: %i(get)])
    end
  end

  context '#resources' do
    it 'adds the path to the route' do
      route = subject.resources(:test_objects)
      expect(route).to eq([:test_objects, path: 'test-objects'])
    end

    it 'respects an explicit path in the route' do
      route = subject.resources(:test_objects, path: 'xyz')
      expect(route).to eq([:test_objects, path: 'xyz'])
    end

    it 'passes other options through' do
      route = subject.resources(:test_objects, only: %i(get))
      expect(route).to eq([:test_objects, path: 'test-objects', only: %i(get)])
    end
  end
end
