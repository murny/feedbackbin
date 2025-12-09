# frozen_string_literal: true

module RichTextHelper
  def mentions_prompt
    content_tag "lexxy-prompt", "",
      trigger: "@",
      src: prompts_users_path,
      name: "mention"
  end
end
