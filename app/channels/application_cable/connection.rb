# frozen_string_literal: true

module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      set_current_account
      set_current_user || reject_unauthorized_connection
    end

    private

      def set_current_account
        # Account is set by middleware and stored in env
        if (account = env["feedbackbin.account"])
          Current.account = account
        end
      end

      def set_current_user
        if (session = Session.find_by(id: cookies.signed[:session_id]))
          self.current_user = session.user
        end
      end
  end
end
