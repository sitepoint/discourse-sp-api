# name: discourse-sp-api
# about: TODO
# version: 0.1
# authors: @nec286

load File.expand_path('../lib/discourse_sitepoint_api.rb', __FILE__)
load File.expand_path('../lib/discourse_sitepoint_api/engine.rb', __FILE__)

Discourse::Application.routes.append do
  mount ::DiscourseSitepointApi::Engine, at: '/sitepoint/api'
end

