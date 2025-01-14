# frozen_string_literal: true

Devise.setup do |config|
  # ==> Configuration for :database_authenticatable
  config.authentication_keys = [:username]
  config.case_insensitive_keys = [:username]
  config.strip_whitespace_keys = [:username]

  # ==> ORM configuration
  require 'devise/orm/active_record'

  # ==> Configuration for :recoverable
  config.reset_password_keys = [:username]
  config.confirmation_keys = [:username]

  # ==> Configuration for any authentication mechanism
  config.secret_key = Rails.application.credentials.secret_key_base

  # ==> Configuration for :validatable
  config.password_length = 6..128

  # ==> Navigation configuration
  config.sign_out_via = [:delete, :get]
  config.navigational_formats = ['*/*', :html, :turbo_stream]
  config.responder.error_status = :unprocessable_entity
  config.responder.redirect_status = :see_other

  # ==> Mailer Configuration
  config.mailer_sender = 'please-change-me-at-config-initializers-devise@example.com'

  # ==> Scopes configuration
  # Turn scoped views on. Before rendering "sessions/new", it will first check for
  # "users/sessions/new". It's turned off by default because it's slower if you
  # are using only default views.
  config.scoped_views = true
end
