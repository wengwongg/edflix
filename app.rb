# Gems
require "require_all"
require "sinatra"
require 'active_support/time'

# So we can escape HTML special characters in the view
include ERB::Util

# Sessions
enable :sessions
set :session_secret, ENV.fetch("SESSION_SECRET_ENV", "bQeThWmZq4t7w!z%C*F)J@NcRfUjXn2r5u8x/A?D(G+KaPdSgVkYp3s6v9y$B&E)")

# App
require_rel "db/db", "models", "controllers", "helpers"
