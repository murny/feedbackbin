# frozen_string_literal: true

# Permit the `target` attribute on links rendered through ActionText so that
# `target="_top"` on a `<a>` inside an attachment partial survives sanitization
# and can break out of an enclosing `<turbo-frame>` on click.
#
# Without this, ActionText's default sanitizer strips `target` (it is not in
# `Rails::HTML::SafeListSanitizer::DEFAULT_ALLOWED_ATTRIBUTES`), which causes
# mention links inside a comment's turbo-frame to navigate inside the frame
# and produce a "Content missing" error instead of a top-level navigation to
# `/users/:id`.
Rails.application.config.to_prepare do
  default_attributes = ActionText::ContentHelper.sanitizer.class.allowed_attributes
  ActionText::ContentHelper.allowed_attributes =
    (default_attributes + ActionText::Attachment::ATTRIBUTES + %w[target]).to_set
end
