
document.addEventListener("DOMContentLoaded", onDomLoad);
safari.self.addEventListener("message", processEvent);

function processEvent(event) {
    if (event.name === "redditweaks.script") {
        eval(event.message["script"]);
    }
}

function onDomLoad() {
    if (window.top === window) {
        safari.extension.dispatchMessage("redditweaks.onDomLoaded");
    }
}
