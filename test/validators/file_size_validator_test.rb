# frozen_string_literal: true

require "test_helper"

class FileSizeValidatorTest < ActiveSupport::TestCase
  class FakeBlob
    attr_reader :byte_size

    def initialize(byte_size)
      @byte_size = byte_size
    end
  end

  class FakeAttachment
    attr_reader :blob, :attached

    def initialize(attached:, byte_size: nil)
      @attached = attached
      @blob = FakeBlob.new(byte_size) if byte_size
    end

    def attached?
      @attached
    end
  end

  class TestModel
    include ActiveModel::Model
    include ActiveModel::Validations

    attr_accessor :file

    validates :file, file_size: { maximum: 2.megabytes }
  end

  setup do
    @model = TestModel.new
  end

  test "allows files under maximum size" do
    @model.file = FakeAttachment.new(attached: true, byte_size: 1.megabyte)

    assert_predicate @model, :valid?
  end

  test "allows files at exactly maximum size" do
    @model.file = FakeAttachment.new(attached: true, byte_size: 2.megabytes)

    assert_predicate @model, :valid?
  end

  test "rejects files over maximum size" do
    @model.file = FakeAttachment.new(attached: true, byte_size: 3.megabytes)

    assert_not @model.valid?
    assert_equal("exceeds maximum size of 2 MB", @model.errors[:file].first)
  end

  test "skips validation when file is not attached" do
    @model.file = FakeAttachment.new(attached: false)

    assert_predicate @model, :valid?
  end

  test "skips validation when file is nil" do
    @model.file = nil

    assert_predicate @model, :valid?
  end
end
