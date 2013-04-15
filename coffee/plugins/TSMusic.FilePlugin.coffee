class TSMusic.FilePlugin extends TSMusic.BrowsePlugin
    @type: "file"
    constructor: (name)->
        super name
        @div = document.getElementById "file-div"
        @button = document.getElementById "browse-file"
        @music_file = document.getElementById "music-file"
        @lyric_file = document.getElementById "lyric-file"
        @submit_file = document.getElementById "submit-file"
        @submit_file.onclick = =>
            if @widget
                if @music_file.files.length
                    music_file_object = @music_file.files[0]
                    if /\.(?:mp3|wav|ogg)$/i.test music_file_object.name
                        @widget.load_from_file music_file_object
                    else
                        alert "音乐文件类型不正确！"
                else
                    alert "请选择音乐文件！"
        @button.onclick = @show.bind @