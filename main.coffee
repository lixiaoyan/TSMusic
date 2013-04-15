window.onload = ->
    if TSMusic.test()
        main = new TSMusic.Main
        main.plug new TSMusic.FilePlugin
        if typeof chrome != "undefined" and chrome.tabs
            main.plug new TSMusic.XiaMiPlugin
        main.plug new TSMusic.LyricPlugin
        main.plug new TSMusic.SpectrumPlugin
    else
        alert "您的浏览器不支持此应用！"