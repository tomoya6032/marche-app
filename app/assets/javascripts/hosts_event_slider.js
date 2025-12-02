// ホストイベントスライダー用JS
// app/assets/javascripts/hosts_event_slider.js

console.log('hosts_event_slider.js loaded');

// グローバルフラグで重複実行を防ぐ
if (window.sliderInitialized) {
  console.log('Slider script already initialized, skipping');
} else {
  window.sliderInitialized = true;
  console.log('Setting global slider initialization flag');
}

function initializeSlider() {
  console.log('Initializing slider...');
  const slider = document.querySelector('.event-slider');
  console.log('slider element found:', slider);
  if (!slider) {
    console.log('No slider element found, exiting');
    return;
  }

  // 既に初期化済みかチェック
  if (slider.classList.contains('slider-initialized')) {
    console.log('Slider already initialized');
    return;
  }
  slider.classList.add('slider-initialized');

  // 既存の矢印ボタンとインジケータを完全に削除
  const existingArrows = document.querySelectorAll('.slider-arrow');
  const existingIndicators = document.querySelectorAll('.slider-indicator');
  
  console.log('Existing arrows found:', existingArrows.length);
  console.log('Existing indicators found:', existingIndicators.length);
  
  // ページ全体から全ての要素を削除
  existingArrows.forEach(arrow => arrow.remove());
  existingIndicators.forEach(indicator => indicator.remove());

  // --- 矢印ボタン生成 ---
  console.log('Creating arrow buttons');
  const leftBtn = document.createElement('button');
  leftBtn.className = 'slider-arrow slider-arrow-left';
  leftBtn.innerHTML = '◀';
  leftBtn.setAttribute('aria-label', '左へスクロール');
  console.log('Left button created:', leftBtn);

  const rightBtn = document.createElement('button');
  rightBtn.className = 'slider-arrow slider-arrow-right';
  rightBtn.innerHTML = '▶';
  rightBtn.setAttribute('aria-label', '右へスクロール');
  console.log('Right button created:', rightBtn);

  slider.parentNode.insertBefore(leftBtn, slider);
  slider.parentNode.insertBefore(rightBtn, slider.nextSibling);
  console.log('Arrow buttons inserted into DOM');

  // --- スクロール量 ---
  const scrollAmount = 320; // 1カード分

  leftBtn.addEventListener('click', function() {
    slider.scrollBy({ left: -scrollAmount, behavior: 'smooth' });
  });
  rightBtn.addEventListener('click', function() {
    slider.scrollBy({ left: scrollAmount, behavior: 'smooth' });
  });

  // --- ドラッグでスライド ---
  let isDown = false;
  let startX;
  let scrollLeft;

  slider.addEventListener('mousedown', (e) => {
    isDown = true;
    slider.classList.add('dragging');
    startX = e.pageX - slider.offsetLeft;
    scrollLeft = slider.scrollLeft;
  });
  slider.addEventListener('mouseleave', () => {
    isDown = false;
    slider.classList.remove('dragging');
  });
  slider.addEventListener('mouseup', () => {
    isDown = false;
    slider.classList.remove('dragging');
  });
  slider.addEventListener('mousemove', (e) => {
    if (!isDown) return;
    e.preventDefault();
    const x = e.pageX - slider.offsetLeft;
    const walk = (x - startX) * 1.5;
    slider.scrollLeft = scrollLeft - walk;
  });

  // --- タッチ対応 ---
  let touchStartX = 0;
  let touchScrollLeft = 0;
  slider.addEventListener('touchstart', (e) => {
    touchStartX = e.touches[0].pageX;
    touchScrollLeft = slider.scrollLeft;
  });
  slider.addEventListener('touchmove', (e) => {
    const x = e.touches[0].pageX;
    const walk = (touchStartX - x);
    slider.scrollLeft = touchScrollLeft + walk;
  });

  // --- インジケータ ---
  // 再度確認：ページ全体で削除後の状態をチェック
  let remainingIndicators = document.querySelectorAll('.slider-indicator');
  console.log('Remaining indicators after cleanup:', remainingIndicators.length);
  
  // 新しいインジケータを作成
  const indicator = document.createElement('div');
  indicator.className = 'slider-indicator';
  indicator.id = 'unique-slider-indicator'; // ユニークID追加
  slider.parentNode.insertBefore(indicator, rightBtn.nextSibling);
  console.log('New indicator created with unique ID');

  function updateIndicator() {
    const maxScroll = slider.scrollWidth - slider.clientWidth;
    const percent = maxScroll > 0 ? slider.scrollLeft / maxScroll : 0;
    indicator.innerHTML = `<div class="slider-indicator-bar" style="width:${Math.round(percent*100)}%"></div>`;
    
    // デバッグ用：全体のインジケータ数を確認
    const allIndicators = document.querySelectorAll('.slider-indicator');
    console.log('Total indicators in DOM:', allIndicators.length);
    
    // デバッグ用：インジケータのHTML構造を確認
    console.log('Indicator HTML:', indicator.outerHTML);
  }
  
  // スクロールイベントリスナーの重複を防ぐ
  slider.removeEventListener('scroll', updateIndicator);
  slider.addEventListener('scroll', updateIndicator);
  updateIndicator();
}

// シンプルな初期化：グローバルフラグでガード
if (!window.sliderInitialized) {
  if (document.readyState === 'loading') {
    // まだ読み込み中
    console.log('Document still loading, waiting for DOMContentLoaded');
    document.addEventListener('DOMContentLoaded', initializeSlider);
  } else {
    // すでに読み込み完了
    console.log('Document already loaded, initializing immediately');
    initializeSlider();
  }
} else {
  console.log('Slider initialization skipped due to global flag');
}
