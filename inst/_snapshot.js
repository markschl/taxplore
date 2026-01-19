// this script to triggers a snapshot after loading; to be included after krona-2.0.js
window.onload = function() {
  const update_ = update;
  // prevent timed update() calls
  update = function() {};
  load();
  update_();
  tweenFactor = 1;

  // prevent window.open in snapshot()
  window.open = function() { return {document: document}; };
  snapshot();

  // fix eternal loading issue in htmlwidgets IFrame
  document.close();

  // remove download link
  document.querySelector("a").remove();
};
