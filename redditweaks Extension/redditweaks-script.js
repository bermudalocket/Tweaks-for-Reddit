$(document).ready(function() {
    if (window.top === window) {
        safari.extension.dispatchMessage("on_dom_loaded");
    }
    $('.drop-choices .choice').each(function(i, ele) {
        var presubreddit = String(ele).match(subredditMatcher)
        if (presubreddit == null) { return }
        let subreddit = presubreddit.groups.subreddit
        let html = $('<a href="javascript:;" title="Add ' + subreddit + ' to favorites"> [+]</a>')
        html.click(function() {
            safari.extension.dispatchMessage("add_favorite_sub", { "subreddit": subreddit })
            location.reload()
        })
        ele.append(html.get(0))
    })
})

safari.self.addEventListener("message", function(event) {
    if (event.name === "script") {
        const t0 = performance.now();
        eval(event.message["script"]);
        const t1 = performance.now();
        console.log(`[redditweaks debug] eval (${event.message["name"]}) took ${t1 - t0} ms.`)
    } else if (event.name === "debug") {
        console.log("[redditweaks debug] " + event.message["info"]);
    } else if (event.name === "keep_alive") {
        // debug only - stop xcode debugger from killing safari after a period of inactivity
        setInterval(() => safari.extension.dispatchMessage("ping", {}), 1000);
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

// -----------------------------------

let subredditMatcher = /https:\/\/www\.reddit\.com\/r\/(?<subreddit>.*)\//
let commentsMatcher = /^(?<numComments>[0-9]+) comment[s]?$/

var RedditPageType = {
    THREAD: 1,
    NOT_THREAD: 2,
    properties: {
        1: { "regex": /reddit.com\/r\/.*\/comments/ },
        2: { }
    }
};

function getPageType() {
    let match = String(window.location).match(RedditPageType.properties[RedditPageType.THREAD].regex)
    if (match == null) {
        return RedditPageType.NOT_THREAD
    } else {
        return RedditPageType.THREAD
    }
}

function getThreadId() {
    let thisThread = String(window.location).match(/\/comments\/(?<threadId>[a-zA-Z0-9]+)\//)
    if (thisThread == null) {
        return null
    } else {
        return thisThread.groups.threadId
    }
}

$(document).ready(function() {
    // safari.extension.dispatchMessage("redditweaks.shouldIShowCommentCounts"); // TODO
    if (getPageType() == RedditPageType.THREAD) {
        let thisThread = getThreadId()
        let matches = $("a.bylink.comments")
        let comments = matches.html().match(commentsMatcher).groups.numComments
        persistThreadComments(thisThread, comments)
    } else {
        let allThreads = $("a.bylink.comments").each(function() {
            let threadId = String($(this).attr("href")).match(/\/comments\/(?<threadId>[a-zA-Z0-9]+)\//).groups.threadId
            let precomments = String($(this).html()).match(commentsMatcher)
            let comments = (precomments == null) ? 0 : precomments.groups.numComments
            let saved = getThreadComments(threadId)
            if (saved != null) {
                if (saved <= comments) {
                    let diff = comments - saved
                    $(this).after(` <b>[${diff} NEW]</b>`)
                }
            }
        })
    }
});

function getThreadCommentStorage() {
    let map = localStorage.threadCommentStorage
    if (map != null) {
        return new Map(JSON.parse(map))
    } else {
        return new Map()
    }
}

function persistThreadComments(thread, comments) {
    var map = getThreadCommentStorage()
    map.set(thread, comments)
    localStorage.threadCommentStorage = JSON.stringify(Array.from(map.entries()))
}

function getThreadComments(thread) {
    return getThreadCommentStorage().get(thread)
}

