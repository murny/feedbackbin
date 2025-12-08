# frozen_string_literal: true

require "test_helper"

class UrlValidatorTest < ActiveSupport::TestCase
  # Test models for each validation option
  class BasicUrlModel
    include ActiveModel::Model
    include ActiveModel::Validations
    attr_accessor :url
    validates :url, url: true
  end

  class OptionalUrlModel
    include ActiveModel::Model
    include ActiveModel::Validations
    attr_accessor :url
    validates :url, url: { allow_blank: true }
  end

  class RelativeUrlModel
    include ActiveModel::Model
    include ActiveModel::Validations
    attr_accessor :url
    validates :url, url: { allow_relative: true }
  end

  # Basic URL validation
  test "accepts valid absolute URLs" do
    model = BasicUrlModel.new(url: "https://example.com")

    assert_predicate model, :valid?

    model.url = "http://example.com/path?query=value"

    assert_predicate model, :valid?
  end

  test "rejects invalid URLs and security risks" do
    model = BasicUrlModel.new(url: "not a url")

    assert_not model.valid?

    model.url = "javascript:alert('xss')"

    assert_not model.valid?

    model.url = "ftp://example.com"

    assert_not model.valid?
  end

  test "rejects blank and relative URLs by default" do
    model = BasicUrlModel.new(url: "")

    assert_not model.valid?

    model.url = "/path"

    assert_not model.valid?

    model.url = "//example.com"

    assert_not model.valid?
  end

  test "rejects URLs without hosts" do
    model = BasicUrlModel.new(url: "https://")

    assert_not model.valid?
  end

  # allow_blank option
  test "accepts blank URLs when allow_blank is true" do
    model = OptionalUrlModel.new(url: "")

    assert_predicate model, :valid?

    model.url = nil

    assert_predicate model, :valid?
  end

  test "still validates non-blank URLs when allow_blank is true" do
    model = OptionalUrlModel.new(url: "not a url")

    assert_not model.valid?
  end

  # allow_relative option
  test "accepts relative paths when allow_relative is true" do
    model = RelativeUrlModel.new(url: "/path")

    assert_predicate model, :valid?

    model.url = "/"

    assert_predicate model, :valid?
  end

  test "rejects protocol-relative URLs even when allow_relative is true" do
    model = RelativeUrlModel.new(url: "//example.com")

    assert_not model.valid?
  end

  test "still accepts absolute URLs when allow_relative is true" do
    model = RelativeUrlModel.new(url: "https://example.com")

    assert_predicate model, :valid?
  end
end
