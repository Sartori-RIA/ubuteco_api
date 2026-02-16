json.meta do
  json.page @pagy.page
  json.count @pagy.count
  json.pages @pagy.pages
  json.previous @pagy.previous
  json.last @pagy.last
end
