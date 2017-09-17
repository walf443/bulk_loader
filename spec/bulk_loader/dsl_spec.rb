# frozen_string_literal: true

require 'spec_helper'

RSpec.describe BulkLoader::DSL do
  class Model
    include BulkLoader::DSL

    bulk_loader :test, ->(i) { i } do
      {}
    end
  end

  let(:model) { Model.new }

  it { expect(Model.bulk_loader).to be_kind_of(BulkLoader::ClassAttribute) }
  it { expect(Model.bulk_loader).to be_respond_to(:test) }
  it { expect(Model.bulk_loader.test).to be_kind_of(BulkLoader::Loader) }

  it { expect(model.bulk_loader).to be_kind_of(BulkLoader::Attribute) }
  it { expect(model.bulk_loader.lazy(:test)).to be_kind_of(BulkLoader::Lazy) }
  it { expect(model).to be_respond_to(:test) }

  it { expect { model.test }.to_not raise_exception }

  it do
    Model.bulk_loader.load(:test, [model.bulk_loader])
    expect(model.bulk_loader.lazy(:test)).to be_loaded
    expect(model.test).to be_nil
  end
end
