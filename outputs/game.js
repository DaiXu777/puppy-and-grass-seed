// ========== Puppy & Grass Seed - Game Logic v4 ==========
var docProg = [1,0,0,0,0];
var curDoc = -1;
var foundClues = {};
var searchHistory = [];
var pedigreeFilled = {};
var allDocsComplete = false;

function countTotalClues() {
  var n = 0;
  STORY_DOCS.forEach(function(d) { n += d.required.length; });
  return n;
}
function countFoundClues() {
  var n = 0;
  for (var di in foundClues) {
    for (var kw in foundClues[di]) { if (foundClues[di][kw]) n++; }
  }
  return n;
}

function showScene(id) {
  document.querySelectorAll(".scene").forEach(function(s){s.classList.remove("active");});
  var el = document.getElementById(id);
  if (el) el.classList.add("active");
}

function startGame() {
  showScene("hs");
  buildHall();
}

function buildHall() {
  var g = document.getElementById("docGrid");
  if (!g) return;
  g.innerHTML = "";
  var found = countFoundClues();
  var total = countTotalClues();
  var icons = ["\ud83d\udc11","\ud83c\udf2d","\ud83d\udc3e","\ud83d\udc3a","\ud83c\udfe0"];
  STORY_DOCS.forEach(function(d, i) {
    var c = document.createElement("div");
    c.className = "doc-card";
    if (docProg[i] === 0) c.classList.add("locked");
    if (docProg[i] === 2) { c.classList.add("done"); c.setAttribute("data-check","\u2713"); }
    var docFound = 0;
    d.required.forEach(function(r) { if (foundClues[i] && foundClues[i][r]) docFound++; });
    c.innerHTML = '<span class="breed-icon">' + icons[i] + '</span>' +
      '<div class="doc-id">Dossier ' + (i+1) + '</div>' +
      '<div class="doc-title">' + d.title + '</div>' +
      '<div class="doc-desc">' + d.desc + '</div>' +
      '<div class="badge ' + (docProg[i]===2 ? "done" : "avail") + '">' +
      (docProg[i]===0 ? "LOCKED" : docProg[i]===2 ? "DONE" : docFound + "/" + d.required.length + " clues") + '</div>';
    if (docProg[i] > 0) {
      c.onclick = function() { curDoc = i; openDoc(i); };
      c.style.cursor = "pointer";
    }
    g.appendChild(c);
  });
  updateProgressBar(found, total);
}

function updateProgressBar(found, total) {
  var bar = document.getElementById("progressBar");
  if (!bar) {
    bar = document.createElement("div");
    bar.id = "progressBar";
    bar.className = "progress-bar-wrap";
    bar.innerHTML = '<div class="progress-label">Investigation Progress</div>' +
      '<div class="progress-track"><div class="progress-fill" id="progressFill"></div></div>' +
      '<div class="progress-text" id="progressText"></div>';
    var header = document.querySelector("#hs .hall-header");
    if (header) header.appendChild(bar);
  }
  var pct = total > 0 ? Math.round(found/total*100) : 0;
  var fill = document.getElementById("progressFill");
  var text = document.getElementById("progressText");
  if (fill) fill.style.width = pct + "%";
  if (text) text.textContent = found + " / " + total + " clues found";
}

function openDoc(idx) {
  var doc = STORY_DOCS[idx];
  if (!foundClues[idx]) foundClues[idx] = {};
  var text = doc.text.replace(/\[([^\]]+)\]/g, "$1");
  var total = doc.required.length;
  var found = 0;
  doc.required.forEach(function(r) { if (foundClues[idx][r]) found++; });
  var canComplete = found >= total;

  document.getElementById("paperDoc").innerHTML =
    '<div class="paper-header">' +
    '<div><h3>' + doc.title + '</h3><div class="eng">' + doc.subtitle + '</div></div>' +
    '</div>' +
    '<div class="paper-sheet" id="docText" style="border-top:3px solid ' + doc.color + '">' +
    text.replace(/\n/g, '<br>') + '</div>' +
    '<div class="doc-footer">' +
    '<button class="btn-back" onclick="backToHall()">BACK</button>' +
    '<span class="clue-counter">Required clues: ' + found + '/' + total + '</span>' +
    '<button class="btn-complete" ' + (canComplete ? "" : "disabled") + ' onclick="completeDoc(' + idx + ')">' +
    (canComplete ? "COMPLETE DOSSIER" : "FIND ALL REQUIRED CLUES") + '</button>' +
    '</div>';

  var dt = document.getElementById("docText");
  if (dt) {
    dt.addEventListener("contextmenu", function(e) {
      e.preventDefault();
      var sel = window.getSelection().toString().trim();
      if (sel.length > 0 && sel.length < 40) {
        showCtxMenu(e.clientX, e.clientY, sel, idx);
      }
    });
  }
  updateHistoryPanel();
  showScene("ds");
}

function showCtxMenu(x, y, txt, docIdx) {
  var old = document.getElementById("ctxMenu");
  if (old) old.remove();
  var m = document.createElement("div");
  m.id = "ctxMenu";
  m.className = "ctx-menu";
  m.style.left = x + "px";
  m.style.top = y + "px";
  var safe = txt.replace(/'/g, "\\'");
  m.innerHTML = '<div class="ctx-item" onclick="doSearch(\'' + safe + '\',' + docIdx + ')">Search: "' + txt.substring(0, 30) + (txt.length>30?"...":"") + '"</div>' +
    '<div class="ctx-item ctx-cancel" onclick="closeCtxMenu()">Cancel</div>';
  document.body.appendChild(m);
  setTimeout(function() { document.addEventListener("click", closeCtxMenu, {once: true}); }, 10);
}

function closeCtxMenu() {
  var m = document.getElementById("ctxMenu");
  if (m) m.remove();
}

function doSearch(txt, docIdx) {
  closeCtxMenu();
  var doc = STORY_DOCS[docIdx];
  var any = false;
  doc.keywords.forEach(function(kw) {
    var sl = txt.toLowerCase();
    var kl = kw.text.toLowerCase();
    if (sl.indexOf(kl) >= 0 || kl.indexOf(sl) >= 0) {
      if (!foundClues[docIdx][kw.id]) {
        foundClues[docIdx][kw.id] = true;
        searchHistory.unshift({ text: kw.text, clue: kw.clue, docIdx: docIdx, time: new Date().toLocaleTimeString() });
        if (searchHistory.length > 30) searchHistory.pop();
        showClueBar(kw.clue);
        updateHistoryPanel();
        any = true;
      }
    }
  });
  if (!any) {
    showClueBar("No matching clue for: " + txt.substring(0, 30));
  }
  refreshDocProgress(docIdx);
}

function refreshDocProgress(docIdx) {
  var doc = STORY_DOCS[docIdx];
  var total = doc.required.length;
  var found = 0;
  doc.required.forEach(function(r) { if (foundClues[docIdx][r]) found++; });
  var can = found >= total;
  var btn = document.querySelector(".btn-complete");
  var ctr = document.querySelector(".clue-counter");
  if (btn) { btn.disabled = !can; btn.textContent = can ? "COMPLETE DOSSIER" : "FIND ALL REQUIRED CLUES"; }
  if (ctr) ctr.textContent = "Required clues: " + found + "/" + total;
  updateProgressBar(countFoundClues(), countTotalClues());
}

function updateHistoryPanel() {
  var panel = document.getElementById("historyPanel");
  if (!panel) {
    panel = document.createElement("div");
    panel.id = "historyPanel";
    panel.className = "history-panel";
    panel.innerHTML = '<div class="history-title">Clues Found</div><div class="history-list" id="historyList"></div>';
    document.body.appendChild(panel);
  }
  var list = document.getElementById("historyList");
  if (!list) return;
  list.innerHTML = "";
  if (searchHistory.length === 0) {
    list.innerHTML = '<div style="color:#bcaaa4;font-size:.8rem;padding:10px">No clues yet.<br>Select text + right-click to search.</div>';
    return;
  }
  searchHistory.forEach(function(h) {
    var item = document.createElement("div");
    item.className = "history-item found";
    item.innerHTML = '<span class="h-time">' + h.time + '</span><span class="h-text">' + h.text.substring(0, 20) + '</span>';
    item.title = h.clue;
    item.onclick = function() { showClueBar(h.clue); };
    list.appendChild(item);
  });
}

function showClueBar(text) {
  var old = document.getElementById("clueBar");
  if (old) old.remove();
  var bar = document.createElement("div");
  bar.id = "clueBar";
  bar.className = "clue-bar";
  bar.innerHTML = '<span class="clue-icon">\ud83d\udd0d</span>' +
    '<div class="clue-body"><div class="clue-label">Latest Clue</div><div class="clue-text">' + text + '</div></div>' +
    '<button class="clue-close" onclick="document.getElementById(\"clueBar\").remove()">\u2715</button>';
  document.body.appendChild(bar);
  updateClueMini(text);
}

function updateClueMini(text) {
  var hp = document.getElementById("historyPanel");
  if (!hp) return;
  var mini = document.getElementById("clueMini");
  if (!mini) {
    mini = document.createElement("div");
    mini.id = "clueMini";
    mini.className = "clue-mini";
    hp.insertBefore(mini, hp.firstChild);
  }
  mini.innerHTML = '<div class="clue-mini-label">Latest</div><div class="clue-mini-text">' + text.substring(0, 80) + (text.length>80?'...':'') + '</div>';
}

function completeDoc(idx) {
  docProg[idx] = 2;
  if (idx + 1 < 5) docProg[idx+1] = 1;
  if (idx + 1 >= 5) allDocsComplete = true;
  if (idx >= 2) fillPedUpTo(2);
  if (idx >= 3) fillPedUpTo(3);
  if (idx >= 4) fillPedUpTo(4);
  backToHall();
}

function fillPedUpTo(maxGen) {
  STORY_PED.forEach(function(n) { if (n.g <= maxGen) pedigreeFilled[n.id] = true; });
}

function backToHall() {
  buildHall();
  showScene("hs");
}

function showPedigree() {
  showScene("ps");
  setTimeout(buildPedigree, 100);
}

function buildPedigree() {
  var wrap = document.getElementById("treeWrap");
  var tip = document.getElementById("treeTip");
  if (!wrap) return;
  wrap.innerHTML = "";
  var nodes = STORY_PED;
  if (!nodes || !nodes.length) return;
  var maxGen = 0;
  if (docProg[2] >= 2) maxGen = 2;
  if (docProg[3] >= 2) maxGen = 3;
  if (docProg[4] >= 2) maxGen = 4;
  var gens = {};
  nodes.forEach(function(n) { gens[n.g] = gens[n.g] || []; gens[n.g].push(n); });
  var sY = 30, yG = 150, xC = Math.max(wrap.offsetWidth / 2, 400), xG = 200;
  var pos = {};
  Object.keys(gens).sort(function(a,b){return a-b;}).forEach(function(g) {
    var arr = gens[g];
    var tW = arr.length * xG;
    var sX = xC - tW/2 + xG/2;
    arr.forEach(function(n, i) {
      var x = sX + i * xG - 75;
      var y = sY + g * yG;
      pos[n.id] = {x: x, y: y};
      var unlocked = (n.g <= maxGen);
      var filled = pedigreeFilled[n.id];
      var cls = "tree-node gen" + n.g;
      if (n.g === 2) cls += (n.n && n.n.indexOf("Green") > -1) ? " gen2g" : " gen2f";
      if (!unlocked) cls += " locked";
      if (filled) cls += " filled";
      var d = document.createElement("div");
      d.className = cls;
      d.style.cssText = "left:" + x + "px;top:" + y + "px";
      d.innerHTML = '<div class="nn">' + (filled ? n.n : "???") + '</div><div class="nt">' + (filled ? n.t : "Unknown") + '</div>';
      if (unlocked && !filled) {
        d.style.cursor = "pointer";
        d.title = "Click to fill";
        d.addEventListener("click", function() { pedigreeFilled[n.id] = true; buildPedigree(); });
      }
      if (filled || unlocked) {
        d.addEventListener("mouseenter", function(e) { tip.textContent = filled ? n.b : "Unlock by completing dossiers"; tip.classList.add("show"); });
        d.addEventListener("mousemove", function(e) { tip.style.left = (e.clientX+16)+"px"; tip.style.top = (e.clientY-40)+"px"; });
        d.addEventListener("mouseleave", function() { tip.classList.remove("show"); });
      }
      wrap.appendChild(d);
    });
  });
  drawLines(wrap, nodes, pos);
  var allSolved = nodes.every(function(n) { return pedigreeFilled[n.id]; });
  var btn = document.getElementById("solveBtn");
  if (!btn) {
    btn = document.createElement("button");
    btn.id = "solveBtn";
    btn.className = "btn-pedi";
    btn.style.cssText = "margin-top:20px;display:block;margin-left:auto;margin-right:auto";
    btn.onclick = solvePedigree;
    wrap.parentElement.appendChild(btn);
  }
  btn.textContent = allSolved ? "Unlock Final Revelation" : "Fill all nodes to proceed";
  btn.disabled = !allSolved;
}

function drawLines(wrap, nodes, pos) {
  var old = wrap.querySelector("svg.tree-lines");
  if (old) old.remove();
  var svg = document.createElementNS("http://www.w3.org/2000/svg", "svg");
  svg.classList.add("tree-lines");
  svg.style.cssText = "position:absolute;top:0;left:0;pointer-events:none;z-index:1;width:" + wrap.offsetWidth + "px;height:" + wrap.offsetHeight + "px";
  nodes.forEach(function(n) {
    var f = pos[n.id]; if (!f) return;
    n.p.forEach(function(cid) {
      var t = pos[cid]; if (!t) return;
      var l = document.createElementNS("http://www.w3.org/2000/svg", "line");
      l.setAttribute("x1", f.x+75); l.setAttribute("y1", f.y+75);
      l.setAttribute("x2", t.x+75); l.setAttribute("y2", t.y);
      l.setAttribute("stroke", "rgba(125,206,160,.4)"); l.setAttribute("stroke-width", "2");
      svg.appendChild(l);
    });
  });
  wrap.appendChild(svg);
}

function solvePedigree() {
  var et = STORY_GLOBAL.ending_text || "Ending";
  document.getElementById("endingText").innerHTML = et.split("\n").filter(function(l){return l.trim();}).map(function(l){return "<p>"+l+"</p>";}).join("");
  showScene("es");
}

function backFromPed() { showScene("hs"); }

function restartGame() {
  docProg = [1,0,0,0,0]; curDoc = -1;
  foundClues = {}; searchHistory = []; pedigreeFilled = {};
  allDocsComplete = false;
  var hp = document.getElementById("historyPanel"); if (hp) hp.remove();
  var pb = document.getElementById("progressBar"); if (pb) pb.remove();
  var cb = document.getElementById("clueBar"); if (cb) cb.remove();
  buildHall(); showScene("ts");
}

buildHall();