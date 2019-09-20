# frozen_string_literal: true

require 'spec_helper'

RSpec.describe BulkLoader::DSL do
  class Model
    include BulkLoader::DSL

    bulk_loader :test, ->(i) { i } do
      {}
    end
  end

  class ModelChild < Model
    bulk_loader :test_child, ->(i) { i } do
      {}
    end
  end

  let(:model) { Model.new }
  let(:model_child) { ModelChild.new }

  it { expect(Model.bulk_loader).to be_kind_of(BulkLoader::ClassAttribute) }
  it { expect(Model.bulk_loader).to be_respond_to(:test) }
  it { expect(ModelChild.bulk_loader).to be_kind_of(BulkLoader::ClassAttribute) }
  it { expect(ModelChild.bulk_loader).to be_respond_to(:test) }
  it { expect(Model.bulk_loader.test).to be_kind_of(BulkLoader::Loader) }
  it { expect(Model.bulk_loader).not_to eq(ModelChild.bulk_loader) }

  it { expect(model.bulk_loader).to be_kind_of(BulkLoader::Attribute) }
  it { expect(model.bulk_loader.lazy(:test)).to be_kind_of(BulkLoader::Lazy) }
  it { expect(model.bulk_loader.lazy(:test_child)).to be_kind_of(BulkLoader::Lazy) }
  it { expect(model).to be_respond_to(:test) }
  it { expect(model).not_to be_respond_to(:test_child) }

  it { expect(model_child.bulk_loader.lazy(:test)).to be_kind_of(BulkLoader::Lazy) }
  it { expect(model_child).to be_respond_to(:test) }

  it { expect { model.test }.to_not raise_exception }
  it { expect { model_child.test }.to_not raise_exception }
  it { expect { model_child.test_child }.to_not raise_exception }

  it do
    Model.bulk_loader.load(:test, [model.bulk_loader])
    expect(model.bulk_loader).to be_loaded(:test)
    expect(model.bulk_loader.lazy(:test)).to be_loaded
    expect(model.test).to be_nil
  end

  it do
    expect do
      Model.bulk_loader.load(:test_child, [model.bulk_loader])
    end.to raise_error(BulkLoader::LoaderNotFoundError)
  end

  it do
    ModelChild.bulk_loader.load(:test, [model_child.bulk_loader])
    expect(model_child.bulk_loader.lazy(:test)).to be_loaded
    expect(model_child.test).to be_nil
  end

  it do
    ModelChild.bulk_loader.load(:test_child, [model_child.bulk_loader])
    expect(model_child.bulk_loader.lazy(:test_child)).to be_loaded
    expect(model_child.test_child).to be_nil
  end

  it 'should be marshalable' do
    ModelChild.bulk_loader.load(:test, [model_child.bulk_loader])
    result = nil
    expect { result = Marshal.load(Marshal.dump(model_child)) }.not_to raise_error
    expect(result.bulk_loader.lazy(:test)).to be_loaded
    expect(result.test).to be_nil

    expect(result.bulk_loader.lazy(:test_child)).not_to be_loaded
  end
end
