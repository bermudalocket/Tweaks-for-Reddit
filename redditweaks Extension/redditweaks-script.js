document.addEventListener("DOMContentLoaded", onDomLoad);

safari.self.addEventListener("message", processEvent);

function watchForChildren(ele, selector, callback) {
    for (const child of Array.from(ele.children).filter(child => child.matches(selector))) {
        callback(child);
    }
}

function watchForFutureChildren(ele, selector, callback) {
    new MutationObserver(mutations => {
        for (const mutation of mutations) {
            for (const node of mutation.addedNodes) {
                if (node.nodeType === Node.ELEMENT_NODE && node.matches(selector)) {
                    callback(node);
                }
            }
        }
    }).observe(ele, { childList: true });
}

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
