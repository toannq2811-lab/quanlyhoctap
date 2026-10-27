// recorder.js — records one spoken word, stops by itself after the speaker goes quiet,
// then returns a 16 kHz WAV (object URL) and a pitch track (Hz per 10 ms, 0 = unvoiced).
(function () {
  var current = null;

  function resample(x, from, to) {
    if (from === to) return x;
    var n = Math.floor(x.length * to / from), out = new Float32Array(n), r = from / to;
    for (var i = 0; i < n; i++) {
      var p = i * r, j = Math.floor(p), f = p - j;
      out[i] = (x[j] || 0) * (1 - f) + (x[j + 1] || 0) * f;
    }
    return out;
  }

  // YIN pitch detection, 40 ms window, 10 ms hop, 75–500 Hz.
  function pitchTrack(x, sr) {
    var win = Math.round(sr * 0.04), hop = Math.round(sr * 0.01);
    var minLag = Math.floor(sr / 500), maxLag = Math.ceil(sr / 75);
    var peak = 1e-6;
    for (var i = 0; i < x.length; i++) peak = Math.max(peak, Math.abs(x[i]));
    var out = [], d = new Float32Array(maxLag + 1);
    for (var s = 0; s + win + maxLag < x.length; s += hop) {
      var e = 0;
      for (var k = 0; k < win; k++) e += x[s + k] * x[s + k];
      if (Math.sqrt(e / win) < peak * 0.08) { out.push(0); continue; }
      var sum = 0, best = 0;
      d[0] = 1;
      for (var tau = 1; tau <= maxLag; tau++) {
        var acc = 0;
        for (var k2 = 0; k2 < win; k2++) { var t = x[s + k2] - x[s + k2 + tau]; acc += t * t; }
        sum += acc;
        d[tau] = sum > 0 ? acc * tau / sum : 1;
        if (tau > minLag && d[tau - 1] < 0.15 && d[tau - 1] <= d[tau] && d[tau - 1] <= d[tau - 2]) { best = tau - 1; break; }
      }
      out.push(best ? sr / best : 0);
    }
    return out;
  }

  function wav(pcm, sr) {
    var b = new ArrayBuffer(44 + pcm.length * 2), v = new DataView(b);
    function str(o, s) { for (var i = 0; i < s.length; i++) v.setUint8(o + i, s.charCodeAt(i)); }
    str(0, 'RIFF'); v.setUint32(4, 36 + pcm.length * 2, true); str(8, 'WAVE'); str(12, 'fmt ');
    v.setUint32(16, 16, true); v.setUint16(20, 1, true); v.setUint16(22, 1, true);
    v.setUint32(24, sr, true); v.setUint32(28, sr * 2, true); v.setUint16(32, 2, true); v.setUint16(34, 16, true);
    str(36, 'data'); v.setUint32(40, pcm.length * 2, true);
    for (var i = 0; i < pcm.length; i++) {
      var s = Math.max(-1, Math.min(1, pcm[i]));
      v.setInt16(44 + i * 2, s < 0 ? s * 32768 : s * 32767, true);
    }
    return new Blob([b], { type: 'audio/wav' });
  }

  window.zhRecorder = {
    // onLevel(0..1) while recording; onDone(url, pitchCsv, ms); onError(code)
    start: function (onLevel, onDone, onError) {
      if (current) current('cancel');
      var AC = window.AudioContext || window.webkitAudioContext;
      if (!AC || !navigator.mediaDevices || typeof AudioWorkletNode === 'undefined') { onError('unsupported'); return; }
      var ctx = new AC();            // created inside the tap so iOS lets it start
      var stream = null, node = null, finished = false;
      var chunks = [], total = 0, floor = 0, floorN = 0, startIdx = -1, lastIdx = 0, lastVoiceT = 0;
      var t0 = performance.now();

      function finish(reason) {
        if (finished) return;
        finished = true;
        current = null;
        try { if (node) { node.port.onmessage = null; node.disconnect(); } } catch (e) {}
        if (stream) stream.getTracks().forEach(function (t) { t.stop(); });
        var sr = ctx.sampleRate;
        ctx.close().catch(function () {});
        if (reason === 'cancel') return;
        if (startIdx < 0) { onError('no-speech'); return; }
        var all = new Float32Array(total), o = 0;
        chunks.forEach(function (c) { all.set(c, o); o += c.length; });
        var a = Math.max(0, startIdx - Math.round(sr * 0.15)), z = Math.min(total, lastIdx + Math.round(sr * 0.2));
        var pcm = resample(all.subarray(a, z), sr, 16000);
        var peak = 1e-4;
        for (var i = 0; i < pcm.length; i++) peak = Math.max(peak, Math.abs(pcm[i]));
        for (var j = 0; j < pcm.length; j++) pcm[j] *= 0.9 / peak;    // normalise loudness for playback
        onDone(URL.createObjectURL(wav(pcm, 16000)), pitchTrack(pcm, 16000).map(function (f) { return f.toFixed(1); }).join(','),
               Math.round(pcm.length / 16));
      }
      current = finish;

      navigator.mediaDevices.getUserMedia({ audio: { channelCount: 1, echoCancellation: true, noiseSuppression: true, autoGainControl: true } })
        .then(function (s) {
          stream = s;
          if (finished) { s.getTracks().forEach(function (t) { t.stop(); }); return; }
          return ctx.resume().then(function () { return ctx.audioWorklet.addModule('recorder_worklet.js'); });
        })
        .then(function () {
          if (finished || !stream) return;
          node = new AudioWorkletNode(ctx, 'rec-capture');
          var mute = ctx.createGain(); mute.gain.value = 0;
          ctx.createMediaStreamSource(stream).connect(node);
          node.connect(mute).connect(ctx.destination);
          t0 = performance.now();
          node.port.onmessage = function (e) {
            var c = e.data, s2 = 0;
            for (var i = 0; i < c.length; i++) s2 += c[i] * c[i];
            var rms = Math.sqrt(s2 / c.length), now = performance.now() - t0;
            chunks.push(c); total += c.length;
            if (now < 300) { floor = (floor * floorN + rms) / (floorN + 1); floorN++; }
            var th = Math.max(0.012, floor * 3);
            if (rms > th) {
              if (startIdx < 0) startIdx = total - c.length;
              lastIdx = total; lastVoiceT = now;
            }
            onLevel(Math.min(1, rms * 10));
            if (startIdx >= 0 && now - lastVoiceT > 900) finish('done');      // quiet after speaking
            else if (now > 7000) finish('done');                               // safety limit
            else if (startIdx < 0 && now > 5000) finish('done');               // never spoke
          };
        })
        .catch(function (err) {
          if (finished) return;
          finished = true; current = null;
          if (stream) stream.getTracks().forEach(function (t) { t.stop(); });
          ctx.close().catch(function () {});
          onError(err && err.name === 'NotAllowedError' ? 'not-allowed' : 'audio-capture');
        });
    },
    stop: function () { if (current) current('done'); },
    cancel: function () { if (current) current('cancel'); },
    play: function (url) { var a = new Audio(url); a.play().catch(function () {}); }
  };
})();
