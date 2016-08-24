$LOAD_PATH << '.'
require 'request_reviews'
require 'uri'
require 'open-uri'
require 'json'

# パラメータ付きのリクエストURLを生成
def create_request_url(url, params_hash)
  temp_array = []
  params_hash.each do |k, v|
    temp_array << "#{k}=#{v}" unless v.nil?
  end
  params = temp_array.join('&')

  request_url = "#{url}?#{params}"
  request_url
end

# apiにリクエストを送信して、レスポンスとしてjsonを受け取る
def return_response(request_url)
  res = open(request_url)
  code, message = res.status

  if code == '200'
    response_body = JSON.parse(res.read)
  else
    puts "#{code} #{message}"
    response_body = nil
  end
  response_body
end

# アプリケーションに関するデータを取得する
# アプリケーションのIDを取得するためのメソッド
def get_app_ids(term)
  base_url = 'https://itunes.apple.com/search'
  params = {
    term: URI.encode(term), country: 'jp', media: 'software',
    entity: 'software', attribute: nil, callback: nil,
    limit: 1, offset: nil, lang: 'ja_jp'
  }
  return_response(create_request_url(base_url, params))
end

# アプリケーションのランキングを取得する
def acquire_top_free_apps
  base_url = 'https://itunes.apple.com/jp/rss'
  feed_type = '/topfreeapplications'
  size = '/limit=200'
  file_type = '/json'
  rss_feed_url = base_url + feed_type + size + file_type
  return_response(rss_feed_url)
end
