class TSMusic.SpectrumPlugin extends TSMusic.Plugin
    @type: "spectrum"
    @events:
        update: "on_update"
    constructor: (name)->
        super name
        @div = document.getElementById "spectrum-div"
        @canvas = document.getElementById "spectrum"
        @context = @canvas.getContext "2d"
        @visible_btn = document.getElementById "spectrum-visible"
        @frequency = new Uint8Array(40)
        @visible = true
        @visible_btn.onclick = =>
            if @visible
                @hide()
            else
                @show()
    _init: ->
        @visible_btn.style.display = ""
        @show()
    _uninit: ->
        @visible_btn.style.display = "none"
        @hide()
    show: ->
        @div.style.display = ""
        @visible = true
        @visible_btn.value = "关闭频谱"
    hide: ->
        @div.style.display = "none"
        @visible = false
        @visible_btn.value = "打开频谱"
    on_update: ->
        if @visible
            @context.clearRect 0,0,200,100
            @widget.audio_analyser.getByteFrequencyData @frequency
            for value,index in @frequency
                value = value/3
                @context.fillRect index*5,100-value,4,value