// app/javascript/application.js

// 純粋なJavaScriptで動作（jQuery, Turbo, Slick不使用）
// event_likes と hosts_event_slider は個別にページで読み込む

// 純粋なJavaScriptでメニュー切り替え機能
function initializeMenuToggle() {
  const menuToggle = document.querySelector(".menu-toggle");
  const spnav = document.querySelector(".spnav");
  if (menuToggle && spnav) {
    menuToggle.addEventListener("click", () => {
      spnav.classList.toggle("active");
    });
  }
}

// DOMContentLoadedで初期化
document.addEventListener("DOMContentLoaded", initializeMenuToggle);

// 即座に実行（ページが既に読み込み済みの場合）
if (document.readyState !== 'loading') {
  initializeMenuToggle();
}

