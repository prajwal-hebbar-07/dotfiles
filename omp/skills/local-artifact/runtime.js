// Injected into every artifact page by serve.mjs. Provides a small
// Firestore-style window.claude.use("db") stored in the artifact's data.json,
// and reloads the page when its files change.
(function () {
  var slug = document.currentScript.dataset.slug;
  var base = "/" + slug + "/";
  var data = null; // { collection: { id: doc } }
  var listeners = new Set();
  var ready;
  var readyP = new Promise(function (r) { ready = r; });

  function snapshotOf(name) {
    var col = (data && data[name]) || {};
    var docs = Object.keys(col).map(function (id) {
      var d = col[id];
      return { id: id, exists: true, data: function () { return JSON.parse(JSON.stringify(d)); } };
    });
    return {
      docs: docs, size: docs.length, empty: docs.length === 0,
      metadata: { fromCache: false },
      forEach: function (f) { docs.forEach(f); }
    };
  }
  function docSnap(name, id) {
    var d = data && data[name] && data[name][id];
    return { id: id, exists: !!d, data: function () { return d ? JSON.parse(JSON.stringify(d)) : undefined; } };
  }
  function emit() { listeners.forEach(function (l) { l(); }); }

  function write(collection, id, doc) {
    // Optimistic local update, then persist.
    data = data || {};
    var col = (data[collection] = data[collection] || {});
    if (doc === null) delete col[id]; else col[id] = doc;
    emit();
    return fetch(base + "__db", {
      method: "POST", headers: { "content-type": "application/json" },
      body: JSON.stringify({ collection: collection, id: id, doc: doc })
    }).then(function (r) { if (!r.ok) throw new Error("save failed: " + r.status); });
  }

  function newId() {
    return Date.now().toString(36) + Math.random().toString(36).slice(2, 8);
  }

  function collection(name) {
    function watch(fn) {
      var l = function () { fn(); };
      listeners.add(l);
      readyP.then(l);
      return function () { listeners.delete(l); };
    }
    function doc(id) {
      id = id || newId();
      return {
        id: id,
        get: function () { return readyP.then(function () { return docSnap(name, id); }); },
        set: function (v, opts) {
          return readyP.then(function () {
            var cur = (opts && opts.merge && data[name] && data[name][id]) || {};
            return write(name, id, Object.assign({}, cur, v));
          });
        },
        update: function (v) { return this.set(v, { merge: true }); },
        delete: function () { return readyP.then(function () { return write(name, id, null); }); },
        onSnapshot: function (fn) { return watch(function () { fn(docSnap(name, id)); }); }
      };
    }
    return {
      doc: doc,
      add: function (v) { var d = doc(); return d.set(v).then(function () { return d; }); },
      get: function () { return readyP.then(function () { return snapshotOf(name); }); },
      onSnapshot: function (fn) { return watch(function () { fn(snapshotOf(name)); }); }
    };
  }

  var db = { collection: collection, dump: function () { return readyP.then(function () { return JSON.parse(JSON.stringify(data)); }); } };

  var es = new EventSource(base + "__events");
  es.onmessage = function (e) {
    var msg = JSON.parse(e.data);
    if (msg.type === "reload") return location.reload();
    if (msg.type === "db") {
      var first = data === null;
      data = msg.data || {};
      if (first) ready(); else emit();
    }
  };

  window.claude = window.claude || {};
  window.claude.use = function (cap) {
    return cap === "db" ? readyP.then(function () { return db; }) : Promise.resolve(null);
  };
})();
