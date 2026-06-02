(function () {
  var slides = Array.prototype.slice.call(document.querySelectorAll('.deck-slide'));
  if (!slides.length) return;

  var idx = 0;
  var dotsEl = document.getElementById('dots');
  var progressEl = document.getElementById('progress');
  var notesEl = document.getElementById('notes-text');
  var notesPanel = document.getElementById('notes-panel');
  var notesVisible = true;

  slides.forEach(function (_, i) {
    var b = document.createElement('button');
    b.type = 'button';
    b.title = slides[i].getAttribute('data-title') || '';
    b.addEventListener('click', function () { go(i); });
    dotsEl.appendChild(b);
  });

  function updateNotes() {
    if (!notesEl) return;
    notesEl.textContent = slides[idx].getAttribute('data-notes') || '';
  }

  function go(n) {
    if (n < 0 || n >= slides.length) return;
    slides[idx].classList.remove('active');
    idx = n;
    slides[idx].classList.add('active');
    var dots = dotsEl.querySelectorAll('button');
    for (var i = 0; i < dots.length; i++) {
      dots[i].classList.toggle('active', i === idx);
    }
    progressEl.textContent = (idx + 1) + ' / ' + slides.length + ' · ' + (slides[idx].getAttribute('data-title') || '');
    updateNotes();
  }

  function toggleNotes() {
    notesVisible = !notesVisible;
    if (notesPanel) {
      notesPanel.classList.toggle('hidden', !notesVisible);
    }
    document.body.classList.toggle('notes-hidden', !notesVisible);
  }

  document.getElementById('btn-first').onclick = function () { go(0); };
  document.getElementById('btn-prev').onclick = function () { go(idx - 1); };
  document.getElementById('btn-next').onclick = function () { go(idx + 1); };
  document.getElementById('btn-full').onclick = function () {
    var el = document.documentElement;
    if (!document.fullscreenElement) el.requestFullscreen().catch(function () {});
    else document.exitFullscreen();
  };
  var btnNotes = document.getElementById('btn-notes');
  if (btnNotes) btnNotes.onclick = toggleNotes;

  document.addEventListener('keydown', function (e) {
    if (e.key === 'ArrowRight' || e.key === 'PageDown' || e.key === ' ') {
      e.preventDefault();
      go(idx + 1);
    } else if (e.key === 'ArrowLeft' || e.key === 'PageUp') {
      e.preventDefault();
      go(idx - 1);
    } else if (e.key === 'Home') {
      go(0);
    } else if (e.key === 'End') {
      go(slides.length - 1);
    } else if (e.key === 'f' || e.key === 'F') {
      document.getElementById('btn-full').click();
    } else if (e.key === 'n' || e.key === 'N') {
      toggleNotes();
    }
  });

  go(0);
})();
