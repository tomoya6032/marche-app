# config/importmap.rb

# application.js はデフォルトで読み込まれるため、通常は明示的にピンする必要はありません。
# もし application.js を明示的にピンしたい場合は、to: "application.js" のように指定します。
# しかし、ここでは削除を推奨します。

pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin_all_from "app/javascript/controllers", under: "controllers"

# jQuery と Slick Carousel は CDN からピン留め
pin "jquery", to: "https://code.jquery.com/jquery-3.6.0.min.js", preload: true
pin "slick-carousel", to: "https://cdnjs.cloudflare.com/ajax/libs/slick-carousel/1.8.1/slick.min.js", preload: true

# ★削除すべき行（またはコメントアウト）★
# pin "application"
# pin "controllers/hello_controller", to: "controllers/hello_controller.js"
# pin "controllers/index", to: "controllers/index.js"