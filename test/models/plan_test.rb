# frozen_string_literal: true

require "test_helper"

class PlanTest < ActiveSupport::TestCase
  test "find_interval_plan" do
    assert_equal annual, monthly.find_interval_plan
    assert_equal monthly, annual.find_interval_plan
  end

  test "monthly?" do
    assert_predicate monthly, :monthly?
    assert_not annual.monthly?
  end

  test "annual?" do
    assert_predicate annual, :annual?
    assert_not monthly.annual?
  end

  test "yearly?" do
    assert_predicate annual, :yearly?
    assert_not monthly.yearly?
  end

  test "monthly_version" do
    assert_equal monthly, annual.monthly_version
  end

  test "yearly_version" do
    assert_equal annual, monthly.yearly_version
  end

  test "annual_version" do
    assert_equal annual, monthly.annual_version
  end

  test "default scope only has visible plans" do
    assert_not_includes Plan.visible, plans(:hidden)
    assert_equal Plan.visible.count, Plan.count - Plan.hidden.count
  end

  test "visible doesn't include hidden plans" do
    assert_includes Plan.visible, plans(:personal)
    assert_not_includes Plan.visible, plans(:hidden)
  end

  test "hidden doesn't include visible plans" do
    assert_includes Plan.hidden, plans(:hidden)
    assert_not_includes Plan.hidden, plans(:personal)
  end

  test "plan converts stripe_tax to boolean" do
    plan = Plan.first
    plan.stripe_tax = "1"

    assert plan.stripe_tax

    plan.stripe_tax = "0"

    assert_not plan.stripe_tax
  end

  test "unit label required if charge_by_unit enabled" do
    plan = Plan.new(charge_per_unit: true, unit_label: "")

    assert_not plan.valid?
    assert_predicate plan.errors[:unit_label], :any?
  end

  private

  def monthly
    @monthly ||= plans(:personal)
  end

  def annual
    @annual ||= plans(:personal_annual)
  end
end
