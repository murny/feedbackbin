# frozen_string_literal: true

class Search::Query
  attr_reader :terms

  def self.wrap(query)
    query.is_a?(self) ? query : new(query)
  end

  def initialize(terms)
    @terms = sanitize(terms)
  end

  def valid?
    terms.present?
  end

  def blank?
    !valid?
  end

  def present?
    valid?
  end

  def to_s
    terms.to_s
  end

  private

    def sanitize(terms)
      return "" if terms.blank?

      sanitized = terms.to_s.strip
      sanitized = sanitized.gsub(/[^\w\s"*-]/u, "")
      sanitized = fix_unbalanced_quotes(sanitized)
      sanitized = strip_bare_operators(sanitized)
      sanitized.squish
    end

    def fix_unbalanced_quotes(str)
      str.count('"').odd? ? str.delete('"') : str
    end

    def strip_bare_operators(str)
      str.gsub(/(?<!\w)[*-](?!\w)/, "")
    end
end
