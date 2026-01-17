# frozen_string_literal: true

module RichTextHelper
  def mentions_prompt
    content_tag "lexxy-prompt", "", trigger: "@", src: prompts_users_path, name: "mention"
  end

  def code_language_picker
    content_tag "lexxy-code-language-picker"
  end

  def rich_text_prompts
    safe_join([ mentions_prompt, code_language_picker ])
  end
end
