# config/importmap.rb

# Pin the application entry so `javascript_importmap_tags` can safely import "application"
pin "application", to: "application.js"

# Railsがデフォルトで生成するが、Stimulusを使わない場合は削除すべきピン
# pin "application"
# pin "controllers/hello_controller", to: "controllers/hello_controller.js"
# pin "controllers/index", to: "controllers/index.js"