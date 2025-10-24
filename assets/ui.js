(function(){
  // Lightweight sparkle background
  const canvas = document.getElementById('sparkle');
  const ctx = canvas.getContext('2d');
  let w, h, stars;

  function resize(){
    w = canvas.width = window.innerWidth;
    h = canvas.height = window.innerHeight;
    stars = Array.from({length: Math.min(150, Math.floor((w*h)/35000))}, () => ({
      x: Math.random()*w,
      y: Math.random()*h,
      r: Math.random()*1.6 + 0.2,
      v: Math.random()*0.3 + 0.05
    }));
  }
  function step(){
    ctx.clearRect(0,0,w,h);
    for(const s of stars){
      ctx.beginPath();
      ctx.arc(s.x, s.y, s.r, 0, Math.PI*2);
      ctx.fillStyle = 'rgba(255,255,255,0.8)';
      ctx.fill();
      s.y += s.v;
      if(s.y > h){ s.y = -2; s.x = Math.random()*w; }
    }
    requestAnimationFrame(step);
  }
  window.addEventListener('resize', resize);
  resize(); step();
})();