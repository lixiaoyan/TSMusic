TSMusic.AppPlugins ?= {}
class TSMusic.AppPlugins.XiaMiPlugin extends TSMusic.BrowsePlugin
    @type: "app.xiami"
    constructor: (name)->
        super name
        @lyric_url = ""
        @div = document.getElementById "app-xiami-div"
        @button = document.getElementById "browse-app-xiami"
        @music_xiami = document.getElementById "music-app-xiami"
        @submit_xiami = document.getElementById "submit-app-xiami"
        @submit_xiami.onclick = =>
            value = @music_xiami.value.trim()
            if value and not isNaN value
                TSMusic.Loader.load "http://www.xiami.com/song/playlist/id/"+value,(result)=>
                    location = /<location>(.*?)<\/location>/.exec(result)[1]
                    url = @url_decode location
                    @lyric_url = /<lyric>(.*?)<\/lyric>/.exec(result)[1]
                    @widget.load url
            else
                alert "请输入正确的编号！"
        @button.onclick = @show.bind @
    url_decode: (id)->
        loc = id.indexOf "h"
        rows = parseInt id.slice(0,loc)
        s = id.slice loc
        cols = Math.floor s.length/rows
        right = s.length%rows
        output = ""
        i = 0
        while i < s.length
            x = i%rows
            y = Math.floor i/rows
            p = 0
            if x <= right
                p = x*(cols+1)+y
            else
                p = right*(cols+1)+(x-right)*cols+y
            output += s.charAt p
            i++
        return decodeURIComponent(output).replace(/\^/g,"0").replace(/%20/g," ")