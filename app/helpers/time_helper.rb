# frozen_string_literal: true

module TimeHelper
  include ActionView::Helpers::DateHelper

  def local_datetime_tag(datetime, style: :time, **attributes)
    tag.time(**attributes, datetime: datetime.iso8601, data: { local_time_target: style })
  end

  # Creates a time ago display with a tooltip showing the full timestamp
  #
  # @param datetime [Time, DateTime] The time to display
  # @param **attributes [Hash] Additional HTML attributes for the time tag
  # @return [ActiveSupport::SafeBuffer] HTML time tag with time ago text and full datetime tooltip
  #
  # Example:
  #   time_ago_with_tooltip(post.created_at)  # => "3 days ago" with tooltip showing full date
  def time_ago_with_tooltip(datetime, **attributes)
    relative_text = relative_time_in_words(datetime)
    full_datetime = datetime.strftime("%B %d, %Y at %l:%M %p").strip

    # Merge any custom classes with our base classes
    css_classes = "cursor-help"
    css_classes += " #{attributes[:class]}" if attributes[:class].present?

    tag.time(
      relative_text,
      title: full_datetime,
      datetime: datetime.iso8601,
      class: css_classes,
      **attributes.except(:class)
    )
  end
end
