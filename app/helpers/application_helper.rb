# frozen_string_literal: true

module ApplicationHelper
  ActionView::Base.default_form_builder = FormBuilders::CustomFormBuilder

  def first_page?(page)
    page == 1
  end

  def unwatch_token_for(idea, recipient)
    watch = idea.watch_for(recipient)
    return nil unless watch

    Rails.application.message_verifier(:watch_unsubscribe).generate(
      { watch_id: watch.id, user_id: recipient.id, idea_id: idea.id },
      expires_in: 30.days
    )
  end
end
