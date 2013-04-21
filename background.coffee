chrome.app.runtime.onLaunched.addListener ->
    chrome.app.window.create "app.html",{
        id: "TSMusicMainWindow"
        frame: "none"
        minWidth: 900
        minHeight: 500
        bounds: {
            width: 900
            height: 500
        }
        singleton: true
    }