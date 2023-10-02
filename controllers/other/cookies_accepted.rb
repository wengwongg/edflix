get "/cookies-accepted" do
  @title = "Cookies Accepted"
  @logged_user = User.first(id: session[:id])
  session[:cookies_accepted] = true

  erb :'pages/other/cookies_accepted', layout: :'templates/layout'
end
