get "/" do
  @title = "Home page"
  @trending_courses = Course.get_trending_courses(3)
  @logged_user = User.first(id: session[:id])

  erb :'pages/other/home_page', layout: :'templates/layout'
end
