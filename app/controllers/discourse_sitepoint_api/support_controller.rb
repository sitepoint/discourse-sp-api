module DiscourseSitepointApi
  class SupportController < ApplicationController

    before_action :ensure_logged_in
    before_action :ensure_staff

    def daily_log_outs
      users = UserCustomField.joins(:user)
        .select("users.id, users.email, value::timestamp AS last_logged_out_at")
        .where("user_custom_fields.name = 'last_logged_out_at' AND value::timestamp > CURRENT_DATE - INTERVAL '1' DAY AND last_seen_at <= value::timestamp")

      render json: {users: users}, status: 200
    end

  end
end

