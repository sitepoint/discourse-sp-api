DiscourseSitepointApi::Engine.routes.draw do
  get "/daily_log_outs" => "support#daily_log_outs"
  delete "/staging_email_tokens" => "support#staging_email_tokens"
end

