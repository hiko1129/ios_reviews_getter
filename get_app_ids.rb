# frozen_string_literal: truerequire 'sqlite3'
$LOAD_PATH << '.'
require 'request_reviews'
require 'uri'
require 'open-uri'
require 'json'
require 'pp'

# IDの取得を行う
class IDGetter
  def initialize(type)
    @type = type
    @request = Request.new
  end
  # TODO
  # IDを取得する部分とランキングを取得する部分を分ける

  def get_ids(term, offset)
    classification = @type.value
    return get_app_ids(term, offset) if classification == 'apps'
    # return get_audiobook_id(term) if classification == 'audiobooks'
    return get_ebook_ids(term, offset) if classification == 'ebooks'
    # return get_movie_id(term) if classification == 'topmovies'
    # return get_song_id(term) if classification == 'songs'
  end

  private

  def configure_request_params(term, media, entity = nil)
    entity = media if entity.nil?
    {
      term: URI.encode(term), country: 'jp', media: media,
      entity: entity, attribute: nil, callback: nil,
      limit: 1, offset: nil, lang: 'ja_jp'
    }
  end

  def get_app_ids(term, offset)
    params = configure_request_params(term, 'software')
    params[:offset] = offset
    @request.send(create_request_url(params))
  end

  # def get_audiobook_id(term)
  #   params = configure_request_params(term, 'audiobook')
  #   @request.send(create_request_url(params))
  # end

  def get_ebook_ids(term, offset)
    params = configure_request_params(term, 'ebook')
    params[:offset] = offset
    @request.send(create_request_url(params))
  end

  # def get_movie_id(term)
  #   params = configure_request_params(term, 'movie')
  #   @request.send(create_request_url(params))
  # end

  # def get_song_id(term)
  #   params = configure_request_params(term, 'music', 'song')
  #   @request.send(create_request_url(params))
  # end

  # パラメータ付きのリクエストURLを生成
  def create_request_url(params_hash)
    url = 'https://itunes.apple.com/search'
    temp_array = []
    params_hash.each do |k, v|
      temp_array << "#{k}=#{v}" unless v.nil?
    end
    params = temp_array.join('&')
    "#{url}?#{params}"
  end
end

# Rankingの処理を行う
class RankProcessor
  def initialize
    @type = Type.new
  end

  def get_ranking(input_type)
    feed_type = @type.find(input_type)
    @ranking = configure_url_params(feed_type)
    nil
  end

  def find_id
    id_getter = IDGetter.new(@type)
    reviews_processor = ReviewsProcessor.new
    parse_ranking(id_getter, reviews_processor)
  end

  private

  def parse_ranking(id_getter, reviews_processor)
    # pp @ranking
    @ranking['feed']['entry'].each do |data|
      # pp data['im:name']['label']
      content = id_getter.get_ids(data['im:name']['label'], 0)
      content['results'].each do |result|
        puts result['trackName']
        reviews_processor.send_request(result['trackId'])
        reviews_processor.show
      end
      show_notice
    end
  end

  def show_notice
    puts 'wait 3 seconds'
    sleep(3)
  end

  def configure_url_params(feed_type)
    base_url = 'https://itunes.apple.com/jp/rss'
    size = '/limit=200'
    file_type = '/json'
    rss_feed_url = base_url + feed_type + size + file_type
    request = Request.new
    request.send(rss_feed_url)
  end
end

# Requestを送信するのみ
class Request
  # apiにリクエストを送信して、レスポンスとしてjsonを受け取る
  def send(request_url)
    res = open(request_url)
    code, message = res.status
    return JSON.parse(res.read) if code == '200'
    puts "#{code} #{message}"
  end
end

# 種類、分類の処理を行い保持する
class Type
  attr_reader :value

  def find(type)
    @value = type.to_s.split('_')[-1]
    classify(@value, type)
  end

  private

  def classify_apps(type)
    return '/topfreeapplications' if type == :top_free_apps
    '/toppaidapplications'
  end

  def classify_books(type)
    return '/topfreeebooks' if type == :top_free_ebooks
    # '/toppaidebooks'
  end

  def classify(classification, type)
    return classify_apps(type) if classification == 'apps'
    # return '/topaudiobooks' if classification == 'audiobooks'
    return classify_books(type) if classification == 'ebooks'
    # return '/topmovies' if classification == 'movies'
    # return '/topsongs' if classification == 'songs'
  end
end
