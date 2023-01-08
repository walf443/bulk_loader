# frozen_string_literal: true

require 'spec_helper'

RSpec.describe BulkLoader::Lazy do
  describe '#set' do
    let(:lazy) { described_class.new(nil, name: :lazy) }

    it { expect { lazy.set(true) }.to change { lazy.loaded? }.to(true) }
  end

  describe '#get' do
    let(:lazy) { described_class.new(nil, name: :lazy) }

    context 'when it was not set' do
      it { expect { lazy.get }.to raise_error(BulkLoader::UnloadAccessError) }
    end

    context 'wehn value was set' do
      before do
        lazy.set(true)
      end

      it { expect(lazy.get).to be(true) }
    end
  end

  describe '#clear' do
    let(:lazy) { described_class.new(nil, name: :lazy) }

    before do
      lazy.set(true)
    end

    it { expect { lazy.clear }.to change { lazy.loaded? }.to(false) }
  end
end
