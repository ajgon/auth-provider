# frozen_string_literal: true
# Be sure to restart your server when you modify this file.

# Rails.application.config.session_store :active_record_store, key: '_auth_provider', tld_length: 3
Rails.application.config.session_store :cookie_store, key: '_auth_provider', tld_length: 3
