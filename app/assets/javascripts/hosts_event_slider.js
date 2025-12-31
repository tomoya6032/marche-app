// ホストイベントスライダー用JS
// app/assets/javascripts/hosts_event_slider.js

console.log('hosts_event_slider.js loaded');

// グローバルフラグで重複読み込みを防ぐ（初期化フラグは initialize 内で立てる）
if (window.sliderScriptLoaded) {
  console.log('Slider script already loaded, skipping duplicate script setup');
} else {
  window.sliderScriptLoaded = true;
  console.log('Setting global slider script loaded flag');
}

function initializeSlider() {
  console.log('Initializing slider...');
  const slider = document.querySelector('.event-slider');
  if (!slider) {
    console.log('No slider element found, exiting');
    return;
  }

  // Prevent double initialization on the same element
  if (slider.classList.contains('slider-initialized')) {
    console.log('Slider already initialized');
    return;
  }
  slider.classList.add('slider-initialized');
  window.sliderInitialized = true;
  console.log('Global sliderInitialized flag set');

  // cleanup any previous arrows/indicators
  document.querySelectorAll('.slider-arrow').forEach(el => el.remove());
  document.querySelectorAll('.slider-indicator').forEach(el => el.remove());

  // create arrow buttons
  const leftBtn = document.createElement('button');
  leftBtn.className = 'slider-arrow slider-arrow-left';
  leftBtn.innerHTML = '◀';
  leftBtn.setAttribute('aria-label', '左へスクロール');

  const rightBtn = document.createElement('button');
  rightBtn.className = 'slider-arrow slider-arrow-right';
  rightBtn.innerHTML = '▶';
  rightBtn.setAttribute('aria-label', '右へスクロール');

  // ensure a wrapper exists for positioning
  let wrapper = slider.parentNode;
  if (!wrapper || !wrapper.classList || !wrapper.classList.contains('slider-wrapper')) {
    const newWrapper = document.createElement('div');
    newWrapper.className = 'slider-wrapper';
    newWrapper.style.position = 'relative';
    if (slider.parentNode) {
      slider.parentNode.insertBefore(newWrapper, slider);
      newWrapper.appendChild(slider);
      wrapper = newWrapper;
    }
  }

  // insert arrows into wrapper (fixed to wrapper edges)
  wrapper.insertBefore(leftBtn, slider);
  wrapper.insertBefore(rightBtn, slider.nextSibling);

  const scrollAmount = 320;
  leftBtn.addEventListener('click', () => slider.scrollBy({ left: -scrollAmount, behavior: 'smooth' }));
  rightBtn.addEventListener('click', () => slider.scrollBy({ left: scrollAmount, behavior: 'smooth' }));

  // drag to scroll
  let isDown = false;
  let startX = 0;
  let scrollLeft = 0;

  slider.addEventListener('mousedown', (e) => {
    isDown = true;
    slider.classList.add('dragging');
    startX = e.pageX - slider.offsetLeft;
    scrollLeft = slider.scrollLeft;
  });
  slider.addEventListener('mouseleave', () => { isDown = false; slider.classList.remove('dragging'); });
  slider.addEventListener('mouseup', () => { isDown = false; slider.classList.remove('dragging'); });
  slider.addEventListener('mousemove', (e) => {
    if (!isDown) return;
    e.preventDefault();
    const x = e.pageX - slider.offsetLeft;
    const walk = (x - startX) * 1.5;
    slider.scrollLeft = scrollLeft - walk;
  });

  // touch support
  let touchStartX = 0;
  let touchScrollLeft = 0;
  slider.addEventListener('touchstart', (e) => {
    touchStartX = e.touches[0].pageX;
    touchScrollLeft = slider.scrollLeft;
  }, { passive: true });
  slider.addEventListener('touchmove', (e) => {
    const x = e.touches[0].pageX;
    const walk = (touchStartX - x);
    slider.scrollLeft = touchScrollLeft + walk;
  }, { passive: true });

  // indicator: create once and update width via style using rAF throttling
  const indicator = document.createElement('div');
  indicator.className = 'slider-indicator';
  const indicatorBar = document.createElement('div');
  indicatorBar.className = 'slider-indicator-bar';
  indicator.appendChild(indicatorBar);
  if (slider.parentNode) slider.parentNode.insertBefore(indicator, slider.nextSibling);

  let rafId = null;

  function updateIndicator() {
    const maxScroll = slider.scrollWidth - slider.clientWidth;
    const percent = maxScroll > 0 ? slider.scrollLeft / maxScroll : 0;
    indicatorBar.style.width = `${Math.round(percent * 100)}%`;
  }

  if (slider._indicatorScrollHandler) {
    slider.removeEventListener('scroll', slider._indicatorScrollHandler);
    slider._indicatorScrollHandler = null;
  }
  const handleScroll = () => {
    if (rafId) return;
    rafId = requestAnimationFrame(() => { updateIndicator(); rafId = null; });
  };
  slider._indicatorScrollHandler = handleScroll;
  slider.addEventListener('scroll', handleScroll, { passive: true });
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
