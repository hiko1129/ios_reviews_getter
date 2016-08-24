$LOAD_PATH << '.'
require 'get_app_ids'

# メインのプログラム
# IDに対応したアプリケーションのレビューを取得する
free_apps = acquire_top_free_apps
free_apps['feed']['entry'].each do |data|
  get_app_ids(data['im:name']['label'])['results'].each do |result|
    puts result['trackName']
    review_data = send_request(result['trackId'])
    if review_data.nil?
      puts 'review data is nil'
    else
      review_data.each do |h|
        puts "rate:#{h[:rate]}"
        puts "title:#{h[:title]}"
        puts "content:#{h[:content]}"
        puts
      end
    end
  end
end
