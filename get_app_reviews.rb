# frozen_string_literal: truerequire 'sqlite3'
$LOAD_PATH << '.'
require 'get_app_ids'

# メインのプログラム
# IDに対応したアプリケーションのレビューを取得する
rank_processor = RankProcessor.new
rank_processor.get_ranking(:top_free_apps)
rank_processor.find_id
