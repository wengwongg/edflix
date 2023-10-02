get "/accessibility" do
  @title = "Accessibility"
  erb :'pages/other/accessibility', layout: :'templates/layout'
end
