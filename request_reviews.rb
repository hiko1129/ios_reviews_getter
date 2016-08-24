require 'open-uri'
require 'json'

# リクエストを送信する
def send_request(ios_app_id)
  url = "https://itunes.apple.com/jp/rss/customerreviews/id=#{ios_app_id}/json"
  response = open(url)
  confirm_response(response)
end

# レスポンスを確認する
def confirm_response(response)
  code, message = response.status
  if code.to_i == 200
    result = response.read
    # save_reviews(result)
    extract_review(result)
  else
    puts "#{code} #{message}"
  end
end

# レビューを抽出する
def extract_review(result)
  reviews = JSON.parse(result)
  review_data = []
  reviews['feed']['entry'].each do |review|
    rate = fetch_review(review, 'im:rating', 'label')
    title = fetch_review(review, 'title', 'label')
    content = fetch_review(review, 'content', 'label')
    review_data << { rate: rate, title: title, content: content }
  end
  review_data
end

# nilを確認する部分の抽象化を行う
def fetch_review(review, key_1, key_2)
  data = review[key_1][key_2] unless review[key_1].nil?
  data
end

# レビュー全体（レスポンス）を保存する
# def save_reviews(result)
#   file_path = './reviews.json'
#   open(file_path, 'w') do |io|
#     io.write(result)
#     puts 'saved'
#   end
# end
