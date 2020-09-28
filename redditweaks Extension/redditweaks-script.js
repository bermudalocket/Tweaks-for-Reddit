let subredditMatcher = /https:\/\/www\.reddit\.com\/r\/(?<subreddit>.*)\//

$(document).ready(function() {
    $('.drop-choices .choice').each(function(i, ele) {
        var subreddit = String(ele).match(subredditMatcher).groups.subreddit
        let html = $('<a href="javascript:;" title="Add ' + subreddit + ' to favorites"> [+]</a>')
        html.click(function() {
            safari.extension.dispatchMessage("redditweaks.addFavoriteSub", { "subreddit": subreddit })
            location.reload()
        })
        ele.append(html.get(0))
    })
})

document.addEventListener("DOMContentLoaded", function() {
    if (window.top === window) {
        safari.extension.dispatchMessage("redditweaks.onDomLoaded");
    }
});

safari.self.addEventListener("message", function(event) {
    if (event.name === "redditweaks.script") {
        const t0 = performance.now();
        eval(event.message["script"]);
        const t1 = performance.now();
        console.log(`[redditweaks debug] eval (${event.message["name"]}) took ${t1 - t0} ms.`)
    } else if (event.name === "redditweaks.debug") {
        console.log("[redditweaks debug] " + event.message["info"]);
    }
});

// https://github.com/honestbleeps/Reddit-Enhancement-Suite/blob/6faae61fb5193ae49d3ba91f4c0f04d4aa974534/lib/utils/dom.js#L40
function watchForChildren(ele, selector, callback) {
    for (const child of Array.from(ele.children).filter(child => child.matches(selector))) {
        callback(child);
    }
}

// https://github.com/honestbleeps/Reddit-Enhancement-Suite/blob/6faae61fb5193ae49d3ba91f4c0f04d4aa974534/lib/utils/dom.js#L48
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
