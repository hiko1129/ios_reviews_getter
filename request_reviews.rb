# frozen_string_literal: truerequire 'sqlite3'
require 'open-uri'
require 'json'
require 'pp'

# レビューを取得する
class ReviewsProcessor
  # リクエストを送信する
  def send_request(id)
    base_url = 'https://itunes.apple.com'
    url = "#{base_url}/jp/rss/customerreviews/id=#{id}/json"
    response = open(url)
    @review_data = confirm_response(response)
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

  # TODO
  # 分類に応じてキーが異なるため対処する
  # appsとtopfreebooksは問題ない
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
    review[key_1][key_2] unless review[key_1].nil?
  end

  def show
    puts 'review data is nil' if @review_data.nil?
    @review_data.each do |h|
      puts "rate:#{h[:rate]}"
      puts "title:#{h[:title]}"
      puts "content:#{h[:content]}"
      puts
    end
  end
end
