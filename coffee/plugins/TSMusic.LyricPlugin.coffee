class TSMusic.LyricPlugin extends TSMusic.Plugin
    @type: "lyric"
    @events:
        update: "on_update"
        load: "on_load"
    @krc_keys: [
        0x40
        0x47
        0x61
        0x77
        0x5e
        0x32
        0x74
        0x47
        0x51
        0x36
        0x31
        0x2d
        0xce
        0xd2
        0x6e
        0x69
    ]
    constructor: (name)->
        super name
        @div = document.getElementById "lyric-file-outer"
        @canvas = document.getElementById "lyric"
        @context = @canvas.getContext "2d"
        @visible_btn = document.getElementById "lyric-visible"
        @forward_btn = document.getElementById "lyric-forward"
        @backward_btn = document.getElementById "lyric-backward"
        @change_lyric = document.getElementById "change-lyric"
        @lyric_panel_div = document.getElementById "lyric-panel-div"
        @panel_canvas = document.getElementById "lyric-panel"
        @panel_context = @panel_canvas.getContext "2d"
        @desktop_lyric_btn = document.getElementById "desktop-lyric"
        @text_fill = @context.createLinearGradient 0,0,0,50
        @text_fill.addColorStop 0,"rgb(37,152,10)"
        @text_fill.addColorStop 1,"rgb(129,249,0)"
        @mask_fill = @context.createLinearGradient 0,0,0,50
        @mask_fill.addColorStop 0,"rgb(253,232,0)"
        @mask_fill.addColorStop 0.5,"rgb(255,120,0)"
        @mask_fill.addColorStop 1,"rgb(255,246,0)"
        @lyric = null
        @lyric_index = -1
        @lyric_text = "-- TSMusic --"
        @lyric_percent = 0
        @canvas_width = 0
        @lyric_type = 0
        @visible = true
        @chrome_app = typeof chrome != "undefined" and chrome.extension
        if @chrome_app
            @notification_btn = document.getElementById "notification-lyric"
            @notification_window = null
            @notification_visible = false
            @notification_canvas = null
            @notification_context = null
            @notification_btn.onclick = =>
                if @notification_visible
                    @hide_notification()
                else
                    @show_notification()
            window.onbeforeunload = @hide_notification.bind @
        @desktop_lyric_btn.onclick = =>
            if @lyric_type == 0
                @change_type 1
            else
                @change_type 0
        @visible_btn.onclick = =>
            if @visible
                @hide()
            else
                @show()
        @forward_btn.onclick = =>
            @change -500
        @backward_btn.onclick = =>
            @change 500
        @change_lyric.onclick = @on_load.bind @
        window.onresize = @resize.bind @
        @resize()
    _init: ->
        @div.style.display = ""
        @visible_btn.style.display = ""
        @forward_btn.style.display = ""
        @backward_btn.style.display = ""
        @desktop_lyric_btn.style.display = ""
        @change_type 0
        @show()
        @clear_lyric()
        if @chrome_app
            @notification_btn.style.display = ""
            @hide_notification()
    _uninit: ->
        @div.style.display = "none"
        @visible_btn.style.display = "none"
        @forward_btn.style.display = "none"
        @backward_btn.style.display = "none"
        @desktop_lyric_btn.style.display = "none"
        @change_type 0
        @hide()
        @clear_lyric()
        if @chrome_app
            @notification_btn.style.display = "none"
            @hide_notification()
    change: (time)->
        if @lyric
            for l in @lyric
                l.time += time
    change_type: (type)->
        @lyric_type = type
        if @visible
            if @lyric_type == 0
                @canvas.style.display = "none"
                @lyric_panel_div.style.display = ""
                @desktop_lyric_btn.className = ""
            else
                @canvas.style.display = ""
                @lyric_panel_div.style.display = "none"
                @desktop_lyric_btn.className = "on"
    show_notification: ->
        if @chrome_app
            @notification_visible = true
            @notification_btn.className = "on"
            @notification_window = webkitNotifications.createHTMLNotification("coffee/plugins/TSMusic.LyricPlugin.html")
            @notification_window.show()
            @notification_window.onclose = @hide_notification.bind @
    hide_notification: ->
        if @chrome_app
            @notification_visible = false
            @notification_btn.className = ""
            @notification_window?.close()
            @notification_window?.cancel()
            @notification_window = null
            @notification_canvas = null
            @notification_context = null
    show: ->
        @visible = true
        @canvas.style.display = ""
        @lyric_panel_div.style.display = ""
        @desktop_lyric_btn.disabled = ""
        @visible_btn.value = "关闭歌词"
        @change_type @lyric_type
    hide: ->
        @visible = false
        @canvas.style.display = "none"
        @lyric_panel_div.style.display = "none"
        @desktop_lyric_btn.disabled = "disabled"
        @visible_btn.value = "打开歌词"
    resize: ->
        @canvas.width = @canvas_width = window.innerWidth
        @context.font = "32px 黑体"
        @context.textBaseline = "middle"
        @context.textAlign = "left"
        @draw()
    draw: ->
        lyric_width = @context.measureText(@lyric_text).width
        lyric_left = (@canvas_width-lyric_width)/2
        lyric_mask_width = lyric_width*@lyric_percent/100
        if lyric_left < 0
            if @canvas_width/2 > lyric_mask_width
                lyric_left = 0
            else if @canvas_width/2 > lyric_width - lyric_mask_width
                lyric_left = @canvas_width - lyric_width
            else
                lyric_left = @canvas_width/2 - lyric_mask_width
        @context.clearRect 0,0,@canvas_width,50
        @context.save()
        @context.lineWidth = 1.5
        @context.shadowColor = "#000000"
        @context.shadowBlur = 2
        @context.shadowOffsetX = 1
        @context.shadowOffsetY = 1
        @context.fillText @lyric_text,lyric_left,25
        @context.strokeText @lyric_text,lyric_left,25
        @context.restore()
        @context.save()
        @context.lineWidth = 1.5
        @context.fillStyle = @text_fill
        @context.strokeStyle = @text_fill
        @context.fillText @lyric_text,lyric_left,25
        @context.strokeText @lyric_text,lyric_left,25
        @context.beginPath()
        @context.rect lyric_left,0,lyric_mask_width,50
        @context.clip()
        @context.fillStyle = @mask_fill
        @context.strokeStyle = @mask_fill
        @context.fillText @lyric_text,lyric_left,25
        @context.strokeText @lyric_text,lyric_left,25
        @context.restore()
    draw_panel: ->
        @panel_context.clearRect 0,0,300,200
        @panel_context.font = "bold 16px 宋体"
        @panel_context.textBaseline = "middle"
        @panel_context.textAlign = "left"
        width = @panel_context.measureText(@lyric_text).width
        left = 150-width/2
        mask_width = width*@lyric_percent/100
        if left < 0
            if 150 > mask_width
                left = 0
            else if 150 > width-mask_width
                left = 300-width
            else
                left = 150-mask_width
        @panel_context.fillStyle = "#333"
        @panel_context.fillText @lyric_text,left,100
        @panel_context.fillStyle = "#36f"
        @panel_context.save()
        @panel_context.beginPath()
        @panel_context.rect left,92,mask_width,16
        @panel_context.clip()
        @panel_context.fillText @lyric_text,left,100
        @panel_context.restore()
        @panel_context.font = "12px 宋体"
        @panel_context.textAlign = "center"
        @panel_context.fillStyle = "#333"
        index = 1
        while index <= 6
            if temp = @lyric[@lyric_index-index]
                @panel_context.fillText temp.lyric,150,92-index*16+8
            if temp = @lyric[@lyric_index+index]
                @panel_context.fillText temp.lyric,150,108+index*16-8
            index++
    draw_notification: ->
        unless @chrome_app
            return
        unless @notification_context
            win = chrome.extension.getViews({type:"notification"})[0]
            unless win
                return
            @notification_canvas = win.document.getElementById "lyric"
            @notification_context = @notification_canvas.getContext "2d"
        @notification_context.clearRect 0,0,280,120
        @notification_context.font = "bold 16px 宋体"
        @notification_context.textBaseline = "middle"
        @notification_context.textAlign = "left"
        width = @notification_context.measureText(@lyric_text).width
        left = 140-width/2
        mask_width = width*@lyric_percent/100
        if left < 0
            if 140 > mask_width
                left = 0
            else if 140 > width-mask_width
                left = 280-width
            else
                left = 140-mask_width
        @notification_context.fillStyle = "#333"
        @notification_context.fillText @lyric_text,left,60
        @notification_context.fillStyle = "#36f"
        @notification_context.save()
        @notification_context.beginPath()
        @notification_context.rect left,52,mask_width,16
        @notification_context.clip()
        @notification_context.fillText @lyric_text,left,60
        @notification_context.restore()
        @notification_context.font = "12px 宋体"
        @notification_context.textAlign = "center"
        @notification_context.fillStyle = "#333"
        index = 1
        while index <= 3
            if temp = @lyric[@lyric_index-index]
                @notification_context.fillText temp.lyric,140,52-index*16+8
            if temp = @lyric[@lyric_index+index]
                @notification_context.fillText temp.lyric,140,68+index*16-8
            index++
    time_to_string: (time)->
        str = "["
        if time < 0
            str += "-"
            time = -time
        str += TSMusic.String.zero_fill Math.floor(time/60/1000).toString(),2
        str += ":"
        str += TSMusic.String.zero_fill (Math.floor(time/1000)%60).toString(),2
        str += "."
        str += TSMusic.String.zero_fill Math.floor((time%1000)/10).toString(),2
        str += "]"
        return str
    krc_to_lrc: (krc,handle)->
        if TSMusic.Array.uint8_array_to_string(new Uint8Array(krc.slice(0,4))) == "krc1"
            array = new Uint8Array krc.slice(4)
            for value,index in array
                array[index] ^= @constructor.krc_keys[index%@constructor.krc_keys.length]
            TSMusic.File.read_text_from_array new Zlib.Inflate(array).decompress(),(text)=>
                text = text.replace /<-?\d+,-?\d+,-?\d+>/g,""
                list = text.split "\n"
                result = []
                before = null
                after = null
                for line in list
                    if line = line.trim()
                        if match = line.match /^\[(-?\d+),(-?\d+)\]([\s\S]*?)$/
                            start = parseInt match[1],10
                            duration = parseInt match[2],10
                            data = match[3].trim()
                            unless data
                                continue
                            if before isnt null
                                if Math.abs(start-before)>1000
                                    result.push @time_to_string(before)
                            if after
                                for str in after
                                    result.push str
                                after = null
                            result.push @time_to_string(start)+data
                            before = start+duration
                        else
                            (after ?= []).push line
                if before isnt null
                    result.push @time_to_string(before)
                if after
                    for str in after
                        result.push str
                result = result.join "\n"
                handle result
        else
            handle ""
    load_lyric: (text)->
        text = text.split "\n"
        @lyric = []
        for line in text
            if m = line.match /^(?:\[-?\d+:\d+\.\d+\])+([\s\S]*?)$/
                l = m[1].trim()
                t = line.match /\[-?\d+:\d+\.\d+\]/g
                for str in t
                    tm = str.match /\[(-?)(\d+):(\d+)\.(\d+)\]/
                    time = parseInt(tm[2],10)*60*1000+parseInt(tm[3],10)*1000+parseInt(tm[4],10)*10
                    time = -time if tm[1] == "-"
                    @lyric.push {
                        time: time
                        lyric: l
                    }
        for line in text
            if m = line.match /^\[offset:(-?\d+)\]$/
                offset = parseInt m[1],10
                for l in @lyric
                    l.time += offset
        @lyric.sort (a,b)=> a.time-b.time
        @lyric.splice 0,0,{
            time: -10000000000
            lyric: ""
        }
        @lyric.push {
            time: 10000000000
            lyric: ""
        }
    clear_lyric: ->
        @lyric = null
        @lyric_index = -1
        @lyric_text = "-- TSMusic --"
        @lyric_percent = 0
        @draw()
    on_update: ->
        if @lyric and (@visible or @notification_visible)
            time = @widget.audio.currentTime*1000
            flag = false
            for value,index in @lyric
                if value.time <= time and time < @lyric[index+1].time
                    @lyric_index = index
                    @lyric_text = value.lyric
                    @lyric_percent = (time-value.time)/(@lyric[index+1].time-value.time)*100
                    flag = true
                    break
            unless flag
                @lyric_index = -1
                @lyric_text = ""
                @lyric_percent = 0
            if @lyric_type == 0
                @draw_panel()
            else
                @lyric_text = @lyric_text or "Music..."
                @draw()
            if @notification_visible
                @draw_notification()
    on_load: ->
        @clear_lyric()
        type = @widget.browse_type
        for index,plugin of @widget.plugins
            if plugin.constructor.type == type
                switch type
                    when "file"
                        if plugin.lyric_file and plugin.lyric_file.files.length
                            file_object = plugin.lyric_file.files[0]
                            if /\.lrc$/i.test file_object.name
                                TSMusic.File.read_text_from_blob file_object,(result)=>
                                    @clear_lyric()
                                    @load_lyric result
                            else if /\.krc$/i.test file_object.name
                                TSMusic.File.read_array_buffer_from_blob file_object,(result)=>
                                    @krc_to_lrc result,(lrc)=>
                                        @clear_lyric()
                                        @load_lyric lrc
                    when "app.xiami"
                        if plugin.lyric_url
                            TSMusic.Loader.load plugin.lyric_url,(result)=>
                                @clear_lyric()
                                @load_lyric result
