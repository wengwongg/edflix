get "/logout" do
  session.clear

  @title = "Log out"
  erb :'pages/other/logout', layout: :'templates/layout'
end
