# frozen_string_literal: true

class User
  module Mentionable
    include ActionText::Attachable

    def to_attachable_partial_path
      "users/mention"
    end

    def to_rich_text_content_attachment_partial_path
      "users/mention"
    end

    def attachable_plain_text_representation(caption)
      "@#{name}"
    end
  end
end
