json.news @news do |news_item|
  json.partial! 'news_item', news: news_item
end
