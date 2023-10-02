require_relative '../spec_helper'

def login(email, pass)
  visit "/login"
  fill_in 'email', with: email
  fill_in 'password', with: pass
  click_on 'Login'
end
