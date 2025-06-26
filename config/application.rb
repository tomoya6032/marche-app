require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Marche
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0

    if Rails.env.development? || Rails.env.test?
      Bundler.require(*Rails.groups)
      Dotenv::Rails.load
    end

    config.i18n.default_locale = :ja
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.yml').to_s]
    
    # Sassファイルの自動コンパイルを有効化
    config.assets.precompile += %w( .js .css .scss .sass )
    # アセットパイプラインでSassを使用
    
   
    config.active_job.queue_adapter = :solid_queue

    config.eager_load_paths << Rails.root.join('lib')
    
    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # タイムゾーンを設定
    config.time_zone = 'Tokyo' # 日本時間に設定
    config.active_record.default_timezone = :local # データベースの時間もローカル時間に合わせる
    # config.eager_load_paths << Rails.root.join("extras")
    config.active_job.queue_adapter = :solid_queue
   
  end
end
