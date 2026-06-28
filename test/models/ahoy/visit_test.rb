# frozen_string_literal: true

require "test_helper"

class Ahoy::VisitTest < ActiveSupport::TestCase
  test "can persist a visit" do
    visit = Ahoy::Visit.create!(
      visit_token: SecureRandom.uuid,
      visitor_token: SecureRandom.uuid,
      started_at: Time.current
    )

    assert_predicate visit, :persisted?
    assert_instance_of Ahoy::Visit, visit
  end

  test "events belong to a visit" do
    visit = Ahoy::Visit.create!(
      visit_token: SecureRandom.uuid,
      visitor_token: SecureRandom.uuid,
      started_at: Time.current
    )

    event = visit.events.create!(name: "$view", time: Time.current)

    assert_equal visit, event.visit
  end
end
