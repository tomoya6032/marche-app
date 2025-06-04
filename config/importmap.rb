# config/importmap.rb

pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true

# ★以下3行はStimulusを使わないため削除★
# pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
# pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true

# ★以下1行はapp/javascript/controllersディレクトリを削除するため削除★
# pin_all_from "app/javascript/controllers", under: "controllers"

# jQuery と Slick Carousel は CDN からピン留め
pin "jquery", to: "https://code.jquery.com/jquery-3.6.0.min.js", preload: true
pin "slick-carousel", to: "https://cdnjs.cloudflare.com/ajax/libs/slick-carousel/1.8.1/slick.min.js", preload: true

# app/javascript/image_slider.js を個別にモジュールとして使いたい場合
# application.js で import している場合は不要です。
# pin "image_slider", to: "image_slider.js"

# Railsがデフォルトで生成するが、Stimulusを使わない場合は削除すべきピン
# pin "application"
# pin "controllers/hello_controller", to: "controllers/hello_controller.js"
# pin "controllers/index", to: "controllers/index.js"