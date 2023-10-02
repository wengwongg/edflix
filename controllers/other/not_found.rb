not_found do
  status 404

  @title = "Not found"
  erb :'pages/other/not_found', layout: :'templates/layout'
end
