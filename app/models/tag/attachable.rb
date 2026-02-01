# frozen_string_literal: true

# Tag::Attachable enables tags to be embedded in ActionText rich text content.
# Include this module in the Tag model to make tags mentionable with #tag syntax.
#
# Example:
#   class Tag < ApplicationRecord
#     include Tag::Attachable
#   end
class Tag
  module Attachable
    extend ActiveSupport::Concern

    included do
      include ActionText::Attachable
    end

    def attachable_plain_text_representation(caption = nil)
      "##{name}"
    end

    def to_attachable_partial_path
      "tags/reference"
    end

    def to_rich_text_content_attachment_partial_path
      "tags/reference"
    end
  end
end
