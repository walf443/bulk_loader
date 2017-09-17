# frozen_string_literal: true

require 'spec_helper'

RSpec.describe BulkLoader do
  it 'has a version number' do
    expect(BulkLoader::VERSION).not_to be nil
  end
end
