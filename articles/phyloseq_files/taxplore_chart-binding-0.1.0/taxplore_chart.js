
function set_opts_script(opts) {
  let out = ''
  const nameTrans = {
    dataset: 'datasetDefault',
    node: 'nodeDefault',
    collapse: 'collapse',
    showMagnitude: 'showMagnitude',
    color: 'hueDefault',
    depth: 'maxDepthDefault',
    font: 'fontSize',
    key: 'showKeys'
  };
  for (const key in opts) {
    if (!nameTrans.hasOwnProperty(key)) {
      throw 'Unknown display option: ' + key;
    }
    let val = opts[key];
    if (val !== null) {
      if (Number.isInteger(val))
        val = 'Number(' + val + ')';
      out += nameTrans[key] + ' = ' + val + '; ';
    }
  }
  return out;
}

HTMLWidgets.widget({

  name: 'taxplore_chart',

  type: 'output',

  factory: function (el, width, height) {
    return {
      renderValue: function (x) {
        let iframe = document.createElement('iframe');
        // iframe.width = width;
        // iframe.height = height;
        iframe.style.border = 'none';
        iframe.style.width = '100%';
        iframe.style.height = '100%';
        // inject scripts for setting options or taking snapshot
        let scripts = '';
        if (x.opts.snapshotScript) {
          scripts += '<script>\n' + x.opts.snapshotScript + '\n</script>';
        }
        if (x.opts.display) {
          scripts += '<script>\n' + set_opts_script(x.opts.display) + '\n</script>';
        }
        if (scripts) {
          x.html = x.html.replace('</head>', scripts + '\n</head>')
        }
        iframe.srcdoc = x.html;
        el.innerHTML = '';
        el.appendChild(iframe);
      },

      resize: function (width, height) {
        //  let iframe = el.children[0];
        //  iframe.width = width;
        //  iframe.height = height;
      }
    };
  }
});
