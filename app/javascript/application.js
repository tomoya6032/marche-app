// app/javascript/application.js

import "@hotwired/turbo-rails";
import "controllers";

// jQuery をグローバルに設定 (必要なら残す)
import $ from "jquery";
window.$ = $;
window.jQuery = $;

// slick-carousel のJSをインポート (CSSはここではインポートしない)
import "slick-carousel";

// ここにメニュー切り替えとSlick Carouselの初期化コードを追加
document.addEventListener("turbo:load", () => {
  // menuToggle, spnav のコード
  const menuToggle = document.querySelector(".menu-toggle");
  const spnav = document.querySelector(".spnav");
  if (menuToggle && spnav) {
    menuToggle.addEventListener("click", () => {
      spnav.classList.toggle("active");
    });
  }

  // Slick Carousel の初期化コード
  // `.top-slider` はあなたのHTML要素のセレクタに合わせてください
  if ($('.top-slider').length) { // 要素が存在するか確認
    $('.top-slider').slick({
      autoplay: true,
      autoplaySpeed: 3000,
      speed: 1500,
      infinite: true,
      slidesToShow: 1,
      slidesToScroll: 1,
      arrows: true,
      prevArrow: '.slider-navigation .prev', // もしこの要素が別にあるなら
      nextArrow: '.slider-navigation .next', // もしこの要素が別にあるなら
      dots: true
    });
  }
});

