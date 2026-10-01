# frozen_string_literal: true

module Ideas
  class CardComponent < Elements::BaseComponent
    PARTICIPANTS_LIMIT = 5

    def initialize(idea:)
      @idea = idea
    end

    private

      def participant_avatars
        @idea.participants(limit: PARTICIPANTS_LIMIT).map do |user|
          { src: helpers.fresh_user_avatar_path(user), alt: user.name, fallback: user.initials, href: helpers.user_path(user), title: user.name }
        end
      end
  end
end
