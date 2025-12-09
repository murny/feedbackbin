# frozen_string_literal: true

require "test_helper"

class ContentTypeValidatorTest < ActiveSupport::TestCase
  ALLOWED_TYPES = %w[ image/jpeg image/png ].freeze

  class FakeAttachment
    attr_reader :content_type, :attached

    def initialize(attached:, content_type: nil)
      @attached = attached
      @content_type = content_type
    end

    def attached?
      @attached
    end
  end

  class TestModel
    include ActiveModel::Model
    include ActiveModel::Validations

    attr_accessor :file

    validates :file, content_type: { in: ALLOWED_TYPES }
  end

  setup do
    @model = TestModel.new
  end

  test "allows content types in the allowed list" do
    @model.file = FakeAttachment.new(attached: true, content_type: "image/jpeg")

    assert_predicate @model, :valid?

    @model.file = FakeAttachment.new(attached: true, content_type: "image/png")

    assert_predicate @model, :valid?
  end

  test "rejects content types not in the allowed list" do
    @model.file = FakeAttachment.new(attached: true, content_type: "image/gif")

    assert_not @model.valid?
    assert_equal("file type is not supported", @model.errors[:file].first)
  end

  test "rejects completely different content types" do
    @model.file = FakeAttachment.new(attached: true, content_type: "application/pdf")

    assert_not @model.valid?
    assert_equal("file type is not supported", @model.errors[:file].first)
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
