# frozen_string_literal: true

require 'spec_helper'

RSpec.describe BulkLoader::Loader do
  describe '#load' do
    subject { -> { loader.load([lazy_obj]) } }

    let(:loader) do
      described_class.new(:to_i, &block)
    end

    context 'when block result is not include lazy_obj target' do
      let(:block) { ->(_) { {} } }

      let(:lazy_obj) { BulkLoader::Lazy.new(1) }

      it { is_expected.to change { lazy_obj.loaded? }.from(false).to(true) }
    end

    context 'when block result is include lazy_obj target' do
      let(:block) { ->(_) { { 1 => true, 2 => false, 3 => true } } }
      let(:lazy_obj) { BulkLoader::Lazy.new(2) }

      it 'should set false to lazy_obj' do
        subject.call
        expect(lazy_obj.get).to be(false)
      end
    end

    context 'when lazy_obj has already loaded' do
      let(:block) { ->(_) { { 1 => true } } }

      let(:lazy_obj) { BulkLoader::Lazy.new(1) }

      before do
        lazy_obj.set(false)
      end

      it 'should load again' do
        is_expected.to change { lazy_obj.get }.from(false).to(true)
      end
    end
  end
end
