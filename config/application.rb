require_relative 'boot'#開発環境（development）、テスト環境(test)、本番環境(production)のすべての環境に共通の設定を記述したファイル

require 'rails/all'
require 'csv'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module AttendanceTutorial2
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1
    config.time_zone = 'Asia/Tokyo'#Time.current
    config.i18n.default_locale = :ja # 言語設定この設定を行なっていないと日本語を表示してくれない。# デフォルトは:enになっている
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}').to_s]# 複数ロケールファイルが読み込む設定　参照するファイルのパスを設定している。
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
  end
end
