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

    # TODO only for staging testing - remove this after the fact!
    def staging_email_tokens
      user = User.find_by(email: params[:email])
      user.email_tokens.each { |t| t.destroy }
      render json: {email: user.email, email_tokens: user.reload.email_tokens}
    end

  end
end

