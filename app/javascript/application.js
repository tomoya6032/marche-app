// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails";
import "controllers";
import Rails from "@rails/ujs";
Rails.start();トエクスポートとしてインポート

// 修正: slick-carousel をインポート
import "slick-carousel";
import "slick-carousel/slick/slick.css";
import "slick-carousel/slick/slick-theme.css";

// jQuery をグローバルに設定
import $ from "jquery";
window.$ = $;
window.jQuery = $;

// slick の初期化
document.addEventListener("turbo:load", () => {
  $(".top-slider").slick({
    autoplay: true,
    autoplaySpeed: 3000,
    dots: true,
    arrows: true,
  });
});