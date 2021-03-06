// Generated by CoffeeScript 1.6.2
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  TSMusic.LyricPlugin = (function(_super) {
    __extends(LyricPlugin, _super);

    LyricPlugin.type = "lyric";

    LyricPlugin.events = {
      update: "on_update",
      load: "on_load"
    };

    LyricPlugin.krc_keys = [0x40, 0x47, 0x61, 0x77, 0x5e, 0x32, 0x74, 0x47, 0x51, 0x36, 0x31, 0x2d, 0xce, 0xd2, 0x6e, 0x69];

    function LyricPlugin(name) {
      var _this = this;

      LyricPlugin.__super__.constructor.call(this, name);
      this.div = document.getElementById("lyric-file-outer");
      this.canvas = document.getElementById("lyric");
      this.context = this.canvas.getContext("2d");
      this.visible_btn = document.getElementById("lyric-visible");
      this.forward_btn = document.getElementById("lyric-forward");
      this.backward_btn = document.getElementById("lyric-backward");
      this.change_lyric = document.getElementById("change-lyric");
      this.lyric_panel_div = document.getElementById("lyric-panel-div");
      this.panel_canvas = document.getElementById("lyric-panel");
      this.panel_context = this.panel_canvas.getContext("2d");
      this.desktop_lyric_btn = document.getElementById("desktop-lyric");
      this.text_fill = this.context.createLinearGradient(0, 0, 0, 50);
      this.text_fill.addColorStop(0, "rgb(37,152,10)");
      this.text_fill.addColorStop(1, "rgb(129,249,0)");
      this.mask_fill = this.context.createLinearGradient(0, 0, 0, 50);
      this.mask_fill.addColorStop(0, "rgb(253,232,0)");
      this.mask_fill.addColorStop(0.5, "rgb(255,120,0)");
      this.mask_fill.addColorStop(1, "rgb(255,246,0)");
      this.lyric = null;
      this.lyric_index = -1;
      this.lyric_text = "-- TSMusic --";
      this.lyric_percent = 0;
      this.canvas_width = 0;
      this.lyric_type = 0;
      this.visible = true;
      this.desktop_lyric_btn.onclick = function() {
        if (_this.lyric_type === 0) {
          return _this.change_type(1);
        } else {
          return _this.change_type(0);
        }
      };
      this.visible_btn.onclick = function() {
        if (_this.visible) {
          return _this.hide();
        } else {
          return _this.show();
        }
      };
      this.forward_btn.onclick = function() {
        return _this.change(-500);
      };
      this.backward_btn.onclick = function() {
        return _this.change(500);
      };
      this.change_lyric.onclick = this.on_load.bind(this);
      window.onresize = this.resize.bind(this);
      this.resize();
    }

    LyricPlugin.prototype._init = function() {
      this.div.style.display = "";
      this.visible_btn.style.display = "";
      this.forward_btn.style.display = "";
      this.backward_btn.style.display = "";
      this.desktop_lyric_btn.style.display = "";
      this.change_type(0);
      this.show();
      return this.clear_lyric();
    };

    LyricPlugin.prototype._uninit = function() {
      this.div.style.display = "none";
      this.visible_btn.style.display = "none";
      this.forward_btn.style.display = "none";
      this.backward_btn.style.display = "none";
      this.desktop_lyric_btn.style.display = "none";
      this.change_type(0);
      this.hide();
      return this.clear_lyric();
    };

    LyricPlugin.prototype.change = function(time) {
      var l, _i, _len, _ref, _results;

      if (this.lyric) {
        _ref = this.lyric;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          l = _ref[_i];
          _results.push(l.time += time);
        }
        return _results;
      }
    };

    LyricPlugin.prototype.change_type = function(type) {
      this.lyric_type = type;
      if (this.visible) {
        if (this.lyric_type === 0) {
          this.canvas.style.display = "none";
          this.lyric_panel_div.style.display = "";
          return this.desktop_lyric_btn.className = "";
        } else {
          this.canvas.style.display = "";
          this.lyric_panel_div.style.display = "none";
          return this.desktop_lyric_btn.className = "on";
        }
      }
    };

    LyricPlugin.prototype.show = function() {
      this.visible = true;
      this.canvas.style.display = "";
      this.lyric_panel_div.style.display = "";
      this.desktop_lyric_btn.disabled = "";
      this.visible_btn.value = "关闭歌词";
      return this.change_type(this.lyric_type);
    };

    LyricPlugin.prototype.hide = function() {
      this.visible = false;
      this.canvas.style.display = "none";
      this.lyric_panel_div.style.display = "none";
      this.desktop_lyric_btn.disabled = "disabled";
      return this.visible_btn.value = "打开歌词";
    };

    LyricPlugin.prototype.resize = function() {
      this.canvas.width = this.canvas_width = window.innerWidth;
      this.context.font = "32px 黑体";
      this.context.textBaseline = "middle";
      this.context.textAlign = "left";
      return this.draw();
    };

    LyricPlugin.prototype.draw = function() {
      var lyric_left, lyric_mask_width, lyric_width;

      lyric_width = this.context.measureText(this.lyric_text).width;
      lyric_left = (this.canvas_width - lyric_width) / 2;
      lyric_mask_width = lyric_width * this.lyric_percent / 100;
      if (lyric_left < 0) {
        if (this.canvas_width / 2 > lyric_mask_width) {
          lyric_left = 0;
        } else if (this.canvas_width / 2 > lyric_width - lyric_mask_width) {
          lyric_left = this.canvas_width - lyric_width;
        } else {
          lyric_left = this.canvas_width / 2 - lyric_mask_width;
        }
      }
      this.context.clearRect(0, 0, this.canvas_width, 50);
      this.context.save();
      this.context.lineWidth = 1.5;
      this.context.shadowColor = "#000000";
      this.context.shadowBlur = 2;
      this.context.shadowOffsetX = 1;
      this.context.shadowOffsetY = 1;
      this.context.fillText(this.lyric_text, lyric_left, 25);
      this.context.strokeText(this.lyric_text, lyric_left, 25);
      this.context.restore();
      this.context.save();
      this.context.lineWidth = 1.5;
      this.context.fillStyle = this.text_fill;
      this.context.strokeStyle = this.text_fill;
      this.context.fillText(this.lyric_text, lyric_left, 25);
      this.context.strokeText(this.lyric_text, lyric_left, 25);
      this.context.beginPath();
      this.context.rect(lyric_left, 0, lyric_mask_width, 50);
      this.context.clip();
      this.context.fillStyle = this.mask_fill;
      this.context.strokeStyle = this.mask_fill;
      this.context.fillText(this.lyric_text, lyric_left, 25);
      this.context.strokeText(this.lyric_text, lyric_left, 25);
      return this.context.restore();
    };

    LyricPlugin.prototype.draw_panel = function() {
      var index, left, mask_width, temp, top, width, _results;

      this.panel_context.clearRect(0, 0, 300, 200);
      this.panel_context.font = "bold 14px 宋体";
      this.panel_context.textBaseline = "middle";
      this.panel_context.textAlign = "left";
      width = this.panel_context.measureText(this.lyric_text).width;
      left = 150 - width / 2;
      mask_width = width * this.lyric_percent / 100;
      top = -16 * this.lyric_percent / 100 + 8;
      if (left < 0) {
        if (150 > mask_width) {
          left = 0;
        } else if (150 > width - mask_width) {
          left = 300 - width;
        } else {
          left = 150 - mask_width;
        }
      }
      this.panel_context.fillStyle = "#333";
      this.panel_context.fillText(this.lyric_text, left, 100 + top);
      this.panel_context.fillStyle = "#36f";
      this.panel_context.save();
      this.panel_context.beginPath();
      this.panel_context.rect(left, 92 + top, mask_width, 16);
      this.panel_context.clip();
      this.panel_context.fillText(this.lyric_text, left, 100 + top);
      this.panel_context.restore();
      this.panel_context.font = "14px 宋体";
      this.panel_context.textAlign = "center";
      this.panel_context.fillStyle = "#333";
      index = 1;
      _results = [];
      while (index <= 7) {
        if (temp = this.lyric[this.lyric_index - index]) {
          this.panel_context.fillText(temp.lyric, 150, 92 - index * 16 + 8 + top);
        }
        if (temp = this.lyric[this.lyric_index + index]) {
          this.panel_context.fillText(temp.lyric, 150, 108 + index * 16 - 8 + top);
        }
        _results.push(index++);
      }
      return _results;
    };

    LyricPlugin.prototype.time_to_string = function(time) {
      var str;

      str = "[";
      if (time < 0) {
        str += "-";
        time = -time;
      }
      str += TSMusic.String.zero_fill(Math.floor(time / 60 / 1000).toString(), 2);
      str += ":";
      str += TSMusic.String.zero_fill((Math.floor(time / 1000) % 60).toString(), 2);
      str += ".";
      str += TSMusic.String.zero_fill(Math.floor((time % 1000) / 10).toString(), 2);
      str += "]";
      return str;
    };

    LyricPlugin.prototype.krc_to_lrc = function(krc, handle) {
      var array, index, value, _i, _len,
        _this = this;

      if (TSMusic.Array.uint8_array_to_string(new Uint8Array(krc.slice(0, 4))) === "krc1") {
        array = new Uint8Array(krc.slice(4));
        for (index = _i = 0, _len = array.length; _i < _len; index = ++_i) {
          value = array[index];
          array[index] ^= this.constructor.krc_keys[index % this.constructor.krc_keys.length];
        }
        return TSMusic.File.read_text_from_array(new Zlib.Inflate(array).decompress(), function(text) {
          var after, before, data, duration, line, list, match, result, start, str, _j, _k, _l, _len1, _len2, _len3;

          text = text.replace(/<-?\d+,-?\d+,-?\d+>/g, "");
          list = text.split("\n");
          result = [];
          before = null;
          after = null;
          for (_j = 0, _len1 = list.length; _j < _len1; _j++) {
            line = list[_j];
            if (line = line.trim()) {
              if (match = line.match(/^\[(-?\d+),(-?\d+)\]([\s\S]*?)$/)) {
                start = parseInt(match[1], 10);
                duration = parseInt(match[2], 10);
                data = match[3].trim();
                if (!data) {
                  continue;
                }
                if (before !== null) {
                  if (Math.abs(start - before) > 1000) {
                    result.push(_this.time_to_string(before));
                  }
                }
                if (after) {
                  for (_k = 0, _len2 = after.length; _k < _len2; _k++) {
                    str = after[_k];
                    result.push(str);
                  }
                  after = null;
                }
                result.push(_this.time_to_string(start) + data);
                before = start + duration;
              } else {
                (after != null ? after : after = []).push(line);
              }
            }
          }
          if (before !== null) {
            result.push(_this.time_to_string(before));
          }
          if (after) {
            for (_l = 0, _len3 = after.length; _l < _len3; _l++) {
              str = after[_l];
              result.push(str);
            }
          }
          result = result.join("\n");
          return handle(result);
        });
      } else {
        return handle("");
      }
    };

    LyricPlugin.prototype.load_lyric = function(text) {
      var l, line, m, offset, str, t, time, tm, _i, _j, _k, _l, _len, _len1, _len2, _len3, _ref,
        _this = this;

      text = text.split("\n");
      this.lyric = [];
      for (_i = 0, _len = text.length; _i < _len; _i++) {
        line = text[_i];
        if (m = line.match(/^(?:\[-?\d+:\d+\.\d+\])+([\s\S]*?)$/)) {
          l = m[1].trim();
          t = line.match(/\[-?\d+:\d+\.\d+\]/g);
          for (_j = 0, _len1 = t.length; _j < _len1; _j++) {
            str = t[_j];
            tm = str.match(/\[(-?)(\d+):(\d+)\.(\d+)\]/);
            time = parseInt(tm[2], 10) * 60 * 1000 + parseInt(tm[3], 10) * 1000 + parseInt(tm[4], 10) * 10;
            if (tm[1] === "-") {
              time = -time;
            }
            this.lyric.push({
              time: time,
              lyric: l
            });
          }
        }
      }
      for (_k = 0, _len2 = text.length; _k < _len2; _k++) {
        line = text[_k];
        if (m = line.match(/^\[offset:(-?\d+)\]$/)) {
          offset = parseInt(m[1], 10);
          _ref = this.lyric;
          for (_l = 0, _len3 = _ref.length; _l < _len3; _l++) {
            l = _ref[_l];
            l.time += offset;
          }
        }
      }
      this.lyric.sort(function(a, b) {
        return a.time - b.time;
      });
      this.lyric.splice(0, 0, {
        time: -10000000000,
        lyric: ""
      });
      return this.lyric.push({
        time: 10000000000,
        lyric: ""
      });
    };

    LyricPlugin.prototype.clear_lyric = function() {
      this.lyric = null;
      this.lyric_index = -1;
      this.lyric_text = "-- TSMusic --";
      this.lyric_percent = 0;
      return this.draw();
    };

    LyricPlugin.prototype.on_update = function() {
      var flag, index, time, value, _i, _len, _ref;

      if (this.lyric && this.visible) {
        time = this.widget.audio.currentTime * 1000;
        flag = false;
        _ref = this.lyric;
        for (index = _i = 0, _len = _ref.length; _i < _len; index = ++_i) {
          value = _ref[index];
          if (value.time <= time && time < this.lyric[index + 1].time) {
            this.lyric_index = index;
            this.lyric_text = value.lyric;
            this.lyric_percent = (time - value.time) / (this.lyric[index + 1].time - value.time) * 100;
            flag = true;
            break;
          }
        }
        if (!flag) {
          this.lyric_index = -1;
          this.lyric_text = "";
          this.lyric_percent = 0;
        }
        if (this.lyric_type === 0) {
          return this.draw_panel();
        } else {
          this.lyric_text = this.lyric_text || "Music...";
          return this.draw();
        }
      }
    };

    LyricPlugin.prototype.on_load = function() {
      var file_object, index, plugin, type, _ref, _results,
        _this = this;

      this.clear_lyric();
      type = this.widget.browse_type;
      _ref = this.widget.plugins;
      _results = [];
      for (index in _ref) {
        plugin = _ref[index];
        if (plugin.constructor.type === type) {
          switch (type) {
            case "file":
              if (plugin.lyric_file && plugin.lyric_file.files.length) {
                file_object = plugin.lyric_file.files[0];
                if (/\.lrc$/i.test(file_object.name)) {
                  _results.push(TSMusic.File.read_text_from_blob(file_object, function(result) {
                    _this.clear_lyric();
                    return _this.load_lyric(result);
                  }));
                } else if (/\.krc$/i.test(file_object.name)) {
                  _results.push(TSMusic.File.read_array_buffer_from_blob(file_object, function(result) {
                    return _this.krc_to_lrc(result, function(lrc) {
                      _this.clear_lyric();
                      return _this.load_lyric(lrc);
                    });
                  }));
                } else {
                  _results.push(void 0);
                }
              } else {
                _results.push(void 0);
              }
              break;
            case "app.xiami":
              if (plugin.lyric_url) {
                _results.push(TSMusic.Loader.load(plugin.lyric_url, function(result) {
                  _this.clear_lyric();
                  return _this.load_lyric(result);
                }));
              } else {
                _results.push(void 0);
              }
              break;
            default:
              _results.push(void 0);
          }
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    return LyricPlugin;

  })(TSMusic.Plugin);

}).call(this);
