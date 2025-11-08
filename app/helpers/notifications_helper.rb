# frozen_string_literal: true

module NotificationsHelper
  def notification_icon(notification)
    case notification.type
    when "PostCommentedNotification"
      "message-circle"
    when "CommentRepliedNotification"
      "reply"
    when "PostStatusChangedNotification"
      "refresh-cw"
    when "NewPostCreatedNotification"
      "plus-circle"
    else
      "bell"
    end
  end
end
