# frozen_string_literal: true

module IdeaScoped
  extend ActiveSupport::Concern

  included do
    before_action :set_idea
  end

  private

    def set_idea
      @idea = Current.account.ideas.find(params[:idea_id])
    end

    def ensure_permission_to_administer_idea
      head :forbidden unless Current.user&.can_administer_idea?(@idea)
    end
end
