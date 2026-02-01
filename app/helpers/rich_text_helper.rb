# frozen_string_literal: true

module RichTextHelper
  def mentions_prompt
    content_tag "lexxy-prompt", "", trigger: "@", src: prompts_users_path, name: "mention"
  end

  def tags_prompt
    content_tag "lexxy-prompt", "", trigger: "#", src: prompts_tags_path, name: "tag"
  end

  def ideas_prompt
    content_tag "lexxy-prompt", "",
      trigger: "#",
      src: prompts_ideas_path,
      name: "idea",
      "insert-editable-text": true,
      "remote-filtering": true,
      "supports-space-in-searches": true
  end

  def code_language_picker
    content_tag "lexxy-code-language-picker"
  end

  def rich_text_prompts
    safe_join([ mentions_prompt, ideas_prompt, code_language_picker ])
  end

  def rich_text_prompts_with_tags
    safe_join([ mentions_prompt, tags_prompt, ideas_prompt, code_language_picker ])
  end
end
