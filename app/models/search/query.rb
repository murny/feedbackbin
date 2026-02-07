# frozen_string_literal: true

class Search::Query < ApplicationRecord
  self.table_name = "search_queries"

  belongs_to :account
  belongs_to :user

  scope :recent, -> { order(updated_at: :desc).limit(5) }

  def self.track(terms, user:)
    sanitized = sanitize(terms)
    return if sanitized.blank?

    record = find_or_initialize_by(
      account: Current.account,
      user: user,
      terms: sanitized
    )
    record.save! if record.new_record?
    record.touch unless record.new_record?
    record
  end

  def self.sanitize(terms)
    return "" if terms.blank?

    sanitized = terms.to_s.strip
    sanitized = sanitized.gsub(/[^\w\s"*-]/u, "")
    sanitized = fix_unbalanced_quotes(sanitized)
    sanitized.squish
  end

  def self.fix_unbalanced_quotes(str)
    if str.count('"').odd?
      str.delete('"')
    else
      str
    end
  end

  private_class_method :fix_unbalanced_quotes
end
