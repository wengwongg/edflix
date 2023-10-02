get "/cookies" do
  @title = "Cookies"
  @logged_user = User.first(id: session[:id])

  erb :'pages/other/cookies', layout: :'templates/layout'
end
