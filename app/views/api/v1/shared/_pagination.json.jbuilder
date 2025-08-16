# Metadatos de paginación
json.pagination do
  json.page @pagy.page
  json.count @pagy.count
  json.pages @pagy.pages
  json.prev @pagy.prev
  json.next @pagy.next
end
