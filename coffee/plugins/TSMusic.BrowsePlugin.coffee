class TSMusic.BrowsePlugin extends TSMusic.Plugin
    @type: "browse"
    constructor: (name)->
        super name
        @div = null
        @button = null
        @visible = false
    _init: ->
        @button?.style.display = ""
        flag = false
        for index,plugin of @widget.plugins
            if plugin isnt @
                if plugin instanceof TSMusic.BrowsePlugin and plugin.visible
                    flag = true
                    break
        unless flag
            @show()
    _uninit: ->
        @button?.style.display = "none"
        if @visible
            for index,plugin of @widget.plugins
                if plugin isnt @
                    if plugin instanceof TSMusic.BrowsePlugin
                        plugin.show()
                        break
            @hide()
    show: ->
        unless @widget
            return
        for index,plugin of @widget.plugins
            if plugin isnt @
                if plugin instanceof TSMusic.BrowsePlugin and plugin.visible
                    plugin.hide()
                    break
        @visible = true
        @div?.style.display = ""
        @button?.className = "on"
        @widget.browse_type = @constructor.type
    hide: ->
        unless @widget
            return
        @visible = false
        @div?.style.display = "none"
        @button?.className = ""
        @widget.browse_type = @constructor.type