# frozen_string_literal: true

require 'spec_helper'

RSpec.describe BulkLoader::Lazy do
  describe '#set' do
    subject { -> { lazy.set(true) } }
    let(:lazy) { described_class.new(nil, name: :lazy) }

    it { is_expected.to change { lazy.loaded? }.to(true) }
  end

  describe '#get' do
    subject { -> { lazy.get } }

    let(:lazy) { described_class.new(nil, name: :lazy) }

    context 'when it was not set' do
      it { is_expected.to raise_error(BulkLoader::UnloadAccessError) }
    end

    context 'wehn value was set' do
      subject { lazy.get }
      before do
        lazy.set(true)
      end

      it { is_expected.to be(true) }
    end
  end

  describe '#clear' do
    let(:lazy) { described_class.new(nil, name: :lazy) }

    subject { -> { lazy.clear } }

    before do
      lazy.set(true)
    end

    it { is_expected.to change { lazy.loaded? }.to(false) }
  end
end
