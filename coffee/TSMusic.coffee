window.URL ?= window.webkitURL
window.AudioContext ?= window.webkitAudioContext
window.TSMusic =
    test: ->
        return window.FileReader? and window.Blob? and window.Audio? and window.URL? and window.AudioContext?
TSMusic.Array =
    find: (arr,find)->
        for value,index in arr
            if value is find
                return index
        return -1
    remove: (arr,value)->
        if (index = TSMusic.Array.find arr,value) != -1
            arr.splice index,1
    uint8_array_to_string: (arr)->
        str = []
        for code in arr
            str.push String.fromCharCode code
        return str.join ""
TSMusic.String =
    zero_fill: (str,len)->
        index = 0
        while index < len-str.length
            str = "0"+str
            index++
        return str
TSMusic.File =
    encode_test: new RegExp [
        "[\\xC0-\\xDF]([^\\x80-\\xBF]|$)"
        "[\\xE0-\\xEF].{0,1}([^\\x80-\\xBF]|$)"
        "[\\xF0-\\xF7].{0,2}([^\\x80-\\xBF]|$)"
        "[\\xF8-\\xFB].{0,3}([^\\x80-\\xBF]|$)"
        "[\\xFC-\\xFD].{0,4}([^\\x80-\\xBF]|$)"
        "[\\xFE-\\xFE].{0,5}([^\\x80-\\xBF]|$)"
        "[\\x00-\\x7F][\\x80-\\xBF]"
        "[\\xC0-\\xDF].[\\x80-\\xBF]"
        "[\\xE0-\\xEF]..[\\x80-\\xBF]"
        "[\\xF0-\\xF7]...[\\x80-\\xBF]"
        "[\\xF8-\\xFB]....[\\x80-\\xBF]"
        "[\\xFC-\\xFD].....[\\x80-\\xBF]"
        "[\\xFE-\\xFE]......[\\x80-\\xBF]"
        "^[\\x80-\\xBF]"
    ].join("|")
    read_text_from_blob: (blob,handle)->
        reader = new FileReader
        reader.readAsText blob,"utf-8"
        reader.onload = =>
            result = reader.result
            if not @encode_test.test result
                handle result
            else
                reader = new FileReader
                reader.readAsText blob,"gbk"
                reader.onload= ->
                    handle @result
    read_array_buffer_from_blob: (blob,handle)->
        reader = new FileReader
        reader.readAsArrayBuffer blob
        reader.onload = ->
            handle @result
    read_text_from_array: (array,handle)->
        if array instanceof ArrayBuffer
            array = new Uint8Array array
        blob = new Blob [array]
        @read_text_from_blob blob,handle
TSMusic.Loader =
    load: (url,handle)->
        xhr = new XMLHttpRequest
        xhr.open "GET",url,true
        xhr.send()
        xhr.onreadystatechange = ->
            if xhr.readyState == 4
                if (xhr.status >= 200 and xhr.status < 300) or xhr.status == 304 or xhr.status == 1223
                    handle xhr.responseText
class TSMusic.EventDispatcher
    constructor: ->
        @parent = null
        @_listener = []
        @_events = []
    bind: (type,handle)->
        @_listener[type] ?= (event)=>
            for handle in @_events[type]
                handle.call @,event
        (@_events[type] ?= []).push handle
    unbind: (type,handle)->
        if @_events[type]
            TSMusic.Array.remove @_events[type],handle
    fire: (type,event)->
        event ?= new TSMusic.Event type
        @_listener[type]?.call @,event
        if not event.cancelTSMusicubble and @parent
            @parent.fire type,event
class TSMusic.Event
    constructor: (@type)->
        @cancelTSMusicubble = false
    stopPropagation: ->
        @cancelTSMusicubble = true
class TSMusic.Widget extends TSMusic.EventDispatcher
    constructor: ->
        super
        @plugins = {}
    plug: (plugin)->
        if plugin instanceof TSMusic.Plugin
            plugin.init @
            @plugins[plugin.name] = plugin
    unplug: (name)->
        if name instanceof TSMusic.Plugin
            name = name.name
        @plugins[name]?.uninit()
        delete @plugins[name]
class TSMusic.Plugin extends TSMusic.EventDispatcher
    @count: 0
    @events: {}
    @type: "undefined"
    constructor: (@name)->
        super
        @name ?= @constructor.type+@constructor.count++
        @widget = null
        @_handles = {}
        for name,func of @constructor.events
            @_handles[name] = @[func].bind @
    init: (widget)->
        if @widget
            @uninit()
        @widget = widget
        for name,func of @_handles
            @widget.bind name,func
        @_init?()
    uninit: ->
        @_uninit?()
        for name,func of @_handles
            @widget.unbind name,func
        @widget = null
    _init: null
    _uninit: null
class TSMusic.Main extends TSMusic.Widget
    constructor: ->
        super
        @audio = null
        @audio_context = new AudioContext
        @media_source = null
        @script_processor = @audio_context.createScriptProcessor 4096
        @audio_analyser = @audio_context.createAnalyser()
        @gain_node = @audio_context.createGain()
        @script_processor.connect @audio_context.destination
        @audio_analyser.connect @gain_node
        @gain_node.connect @audio_context.destination
        @toggle = document.getElementById "toggle"
        @slider = document.getElementById "slider"
        @mute = document.getElementById "mute"
        @volume = document.getElementById "volume"
        @playing = false
        @isdown = false
        @muted = false
        @toggle.onclick = =>
            if @playing
                @pause()
            else
                @play()
        slide = @get_handle =>
            @isdown = false
            @seek @slider.value
        ,200,500
        @slider.onchange = =>
            @isdown = true
            slide()
        @mute.onclick = =>
            @muted = not @muted
            if @muted
                @gain_node.gain.value = 0
                @mute.value = "打开音量"
            else
                @gain_node.gain.value = @volume.value
                @mute.value = "关闭音量"
        @volume.onchange = @get_handle =>
            unless @muted
                @gain_node.gain.value = @volume.value
        ,200,500
        @script_processor.onaudioprocess = =>
            @update()
            unless @isdown
                if @audio and @audio.readyState > 3
                    @slider.max = @audio.duration
                    @slider.value = @audio.currentTime
                else
                    @slider.max = 0
                    @slider.value = 0
        @audio_url = null
        @update = @get_handle =>
            if @playing
                @fire "update"
        ,50,50
    load: (url)->
        if @audio
            @pause()
            @media_source.disconnect()
        @toggle.disabled = ""
        @slider.disabled = ""
        @audio = new Audio
        @audio.src = url
        @audio.loop = "loop"
        @fire "load"
        @audio.addEventListener "canplay",=>
            @media_source = @audio_context.createMediaElementSource @audio
            @media_source.connect @script_processor
            @media_source.connect @audio_analyser
            @play()
            @fire "loaded"
    load_from_file: (file)->
        if @audio_url
            URL.revokeObjectURL @audio_url
        @audio_url = URL.createObjectURL file
        @load @audio_url
    play: ->
        if @audio
            @audio.play()
            @playing = true
            @toggle.value = "暂停"
            @fire "pause"
    pause: ->
        if @audio
            @audio.pause()
            @playing = false
            @toggle.value = "播放"
            @fire "play"
    seek: (time)->
        if @audio
            @audio.currentTime = time
            @fire "seek"
    get_handle: (handle,delay,max)->
        timer = -1
        t_start = 0
        return ->
            args = arguments
            t_current = new Date().getTime()
            clearTimeout timer
            unless t_start
                t_start = t_current
            if t_current-t_start >= max
                handle.apply @,args
                t_start = t_current
            else
                timer = setTimeout =>
                    handle.apply @,args
                    t_start = t_current
                ,delay
