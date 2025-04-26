document.addEventListener('DOMContentLoaded', function() {
    const slider = document.querySelector('.top-slider');
    const images = slider.querySelectorAll('img');
    const prevButton = document.querySelector('.prev');
    const nextButton = document.querySelector('.next');
    let currentIndex = 0;
    const imageWidth = images[0].clientWidth; // 最初の画像の幅を取得
  
    function slide(index) {
      slider.style.transform = `translateX(-${index * imageWidth}px)`;
      currentIndex = index;
    }
  
    function nextSlide() {
      currentIndex = (currentIndex + 1) % images.length;
      slide(currentIndex);
    }
  
    function prevSlide() {
      currentIndex = (currentIndex - 1 + images.length) % images.length;
      slide(currentIndex);
    }
  
    // 初期表示
    slide(currentIndex);
  
    // イベントリスナー
    if (prevButton && nextButton) {
      prevButton.addEventListener('click', prevSlide);
      nextButton.addEventListener('click', nextSlide);
    }
  
    // 自動再生 (オプション)
    setInterval(nextSlide, 3000);
  });