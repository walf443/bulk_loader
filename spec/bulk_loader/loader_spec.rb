# frozen_string_literal: true

require 'spec_helper'

RSpec.describe BulkLoader::Loader do
  describe '#load' do
    let(:loader) do
      described_class.new(->(i) { i }, &block)
    end

    context 'when block argument is exist' do
      let(:block) { ->(_, _) { {} } }
      let(:lazy_obj1) { BulkLoader::Lazy.new(1, name: :obj1) }
      let(:lazy_obj2) { BulkLoader::Lazy.new(1, name: :obj2) }

      it { expect { loader.load([lazy_obj1, lazy_obj2]) }.to raise_error(ArgumentError) }
    end

    context 'when block result is not include lazy_obj target' do
      let(:block) { ->(_) { {} } }

      let(:lazy_obj1) { BulkLoader::Lazy.new(1, name: :obj1) }
      let(:lazy_obj2) { BulkLoader::Lazy.new(1, name: :obj2) }

      it { expect { loader.load([lazy_obj1, lazy_obj2]) }.to change { lazy_obj1.loaded? }.from(false).to(true) }
      it { expect { loader.load([lazy_obj1, lazy_obj2]) }.to change { lazy_obj2.loaded? }.from(false).to(true) }
    end

    context 'when block result is include lazy_obj target' do
      let(:block) { ->(_) { { 1 => true, 2 => false, 3 => true } } }
      let(:lazy_obj1) { BulkLoader::Lazy.new(2, name: :obj1) }
      let(:lazy_obj2) { BulkLoader::Lazy.new(2, name: :obj2) }

      it 'should set false to lazy_obj' do
        loader.load([lazy_obj1, lazy_obj2])

        expect(lazy_obj1.get).to be(false)
        expect(lazy_obj2.get).to be(false)
      end
    end

    context 'when lazy_obj has already loaded' do
      let(:block) { ->(_) { { 1 => true } } }

      let(:lazy_obj1) { BulkLoader::Lazy.new(1, name: :obj1) }
      let(:lazy_obj2) { BulkLoader::Lazy.new(1, name: :obj2) }

      before do
        lazy_obj1.set(false)
        lazy_obj2.set(false)
      end

      it 'should load again' do
        expect { loader.load([lazy_obj1, lazy_obj2]) }.to change { lazy_obj1.get }.from(false).to(true)
      end

      it 'should load again' do
        expect { loader.load([lazy_obj1, lazy_obj2]) }.to change { lazy_obj2.get }.from(false).to(true)
      end
    end
  end
end
