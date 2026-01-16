# frozen_string_literal: true

module Account::Seedable
  extend ActiveSupport::Concern

  def setup_template
    Account::Seeder.new(self, users.admin.first).seed
  end
end
