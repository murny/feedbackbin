# frozen_string_literal: true

# Include RecordIdentifier in ActionText Tags so Lexxy can use dom_id
Rails.application.config.to_prepare do
  ActionView::Helpers::Tags::ActionText.include(ActionView::RecordIdentifier)
end
