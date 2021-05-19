$(document).ready(function() {
    if (window.top === window) {
        safari.self.addEventListener("message", event => {
            if (event.name === "script") {
                let func = event.message["function"]
                eval(func)
            }
        });
        safari.extension.dispatchMessage("begin", {
            "url": window.location.href,
        })
    }
})

// ============================================================

let autoExpandImages = () => {
    const expandableDomains = [ "i.redd.it", "reddit.com", "i.imgur.com" ]
    document.querySelectorAll(".thing").forEach(e => {
        if (expandableDomains.includes(e.getAttribute("data-domain"))) {
            e.querySelector(".expando-button").click()
        }
    })
}

let endlessScroll = () => {

    var isLoading = false

    const getNextPageURL = () => $(".next-button").children().first().attr("href")

    let preloadedData

    const preloadData = async () => $.get(getNextPageURL(), data => preloadedData = $(data).find('.sitetable'))

    $(document).ready(preloadData)

    window.onscroll = async () => {
        if (!isLoading && (window.innerHeight + window.pageYOffset) >= document.body.offsetHeight - (window.innerHeight/3)) {
            $(".next-button").parent().remove()
            $(preloadedData).children().each(function() { $('.sitetable').append($(this)) })
            preloadData()
        }
    }
}

let oldReddit = () => {
    if (window.location.href.startsWith("https://www.reddit")) {
        window.location = window.location.href.replace("www", "old");
    }
}

let noHappeningNowBanners = () => {
    $('.happening-now-wrap').remove();
}

let noChat = () => {
    watchForChildren(document.body, "script", e => {
        if ((/^\/_chat/).test(new URL(e.src, location.origin).pathname)) {
            e.remove();
        }
    });
    watchForChildren(document.body, "#chat-app", e => e.remove());
}

let showKarma = () => {
    let username = $('.user a').text();
    let url = (window.location.href.startsWith("https://old")) ? `https://old.reddit.com/user/${username}` : `https://www.reddit.com/user/${username}`;
    let karmaArea = $('span .userkarma');
    let karma = karmaArea.text();
    karmaArea.html(`<a href='${url}/submitted/'>${karma}</a>`);
    $.get(url, data => {
        let ck = $(data).find('.comment-karma').text();
        let cmturl = `<a href='${url}/comments/'>${ck}</a>`;
        $('span .userkarma').append(" | " + cmturl);
    });
}

let customSubredditBar = (subs) => {
    let bar = $("ul.sr-bar").last()
    bar.children().remove()
    for (i in subs) {
        const sub = subs[i]
        let html = `<li><a class='choice' href='https://www.reddit.com/r/${sub}'>${sub}</a></li>`
        if (i < subs.length - 1) {
            html = `${html}<span class='separator'>-</span>`
        }
        bar.append(html)
    }
    $('.drop-choices .choice').each(function(ele) {
        var presubreddit = String(ele).match(subredditMatcher)
        if (presubreddit == null) { return }
        let subreddit = presubreddit.groups.subreddit
        let html = $('<a href="javascript:;" title="Add ' + subreddit + ' to favorites"> [+]</a>')
        html.click(function() {
            safari.extension.dispatchMessage("addFavoriteSub", { "subreddit": subreddit })
            location.reload()
        })
        ele.append(html.get(0))
    })
}

let hideAds = () => $('.ad-container, .ad-container, #ad_1').each(() => $(this).remove());

let hidePromotedPosts = () => $(".promoted").each(() => $(this).remove());

let hideUsername = () => $("#header-bottom-right .user a").first().remove();

let collapseAutoModerator = () => {
    $('div[data-author=AutoModerator]').each(function() {
        $(this).removeClass('noncollapsed');
        $(this).addClass('collapsed');
        $(this).find('.expand').html('[+]');
    });
}

let collapseChildComments = () => {
    $('.comment .noncollapsed').each(function() {
        $(this).removeClass('noncollapsed');
        $(this).addClass('collapsed');
        $(this).find('.expand').html('[+]');
    });
}

let hideRedditPremiumBanner = () => $(".premium-banner-outer").remove();

let hideNewRedditButton = () => $(".redesign-beta-optin").remove();

let nsfwFilter = () => $(".over18").each(() => $(this).remove());

let persistComments = () => {
    let comments = $("a.bylink.comments").html().match(commentsMatcher).groups.numComments
    persistThreadComments(getThreadId(), comments)
}

let rememberUserVotes = () => {
    $(".comment").each((i, e) => {
        let author = $(e).data("author")
        let count = votesForUser(author)

        if (count) {
            let authorLabel = $(e).find(".author").first()
            if (count > 0) {
                authorLabel.after(" | <font color=green>[+" + count + "]</font> ")
            } else {
                authorLabel.after(" | <font color=red>[-" + count + "]</font> ")
            }
        }

        let upvote = $(e).find(".arrow.up").first()
        upvote.click(() => {
            let isAlreadyUpvoted = $(upvote).hasClass("upmod")
            if (isAlreadyUpvoted) {
                rememberVote(false, author)
                safari.extension.dispatchMessage("removeupvote", { "user": author })
            } else {
                rememberVote(true, author)
                safari.extension.dispatchMessage("rememberupvote", { "user": author })
            }
        })

        let downvote = $(e).find(".arrow.down").first()
        downvote.click(() => {
            let isAlreadyDownvoted = $(downvote).hasClass("downmod")
            if (isAlreadyDownvoted) {
                rememberVote(true, author)
                safari.extension.dispatchMessage("removedownvote", { "user": author })
            } else {
                rememberVote(false, author)
                safari.extension.dispatchMessage("rememberdownvote", { "user": author })
            }
        })
    })
}

let showNewComments = () => {
    if (getPageType() == RedditPageType.THREAD) {
        let thisThread = getThreadId()
        let comments = $("a.bylink.comments").html().match(commentsMatcher).groups.numComments
        persistThreadComments(thisThread, comments)
    } else {
        $("a.bylink.comments").each(function() {
            let threadId = String($(this).attr("href")).match(/\/comments\/(?<threadId>[a-zA-Z0-9]+)\//).groups.threadId
            let precomments = String($(this).html()).match(commentsMatcher)
            let comments = (precomments == null) ? 0 : precomments.groups.numComments
            let saved = getThreadComments(threadId)
            if (saved != null) {
                $(this).parent().parent().parent().parent().parent().css("opacity", 0.5) // TODO
                if (saved <= comments) {
                    let diff = comments - saved
                    $(this).after(` <b>[${diff} NEW]</b>`)
                }
            }
        })
    }
}

// ==================================================
// UTILITIES
// ==================================================

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

let getPageType = () => {
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

//

let voteMemory = () => {
    let map = localStorage.voteMemory
    if (map != null) {
        return new Map(JSON.parse(map))
    } else {
        return new Map()
    }
}

let rememberVote = (upOrDown, user) => {
    var map = voteMemory()
    let currentCount = map.get(user)
    if (currentCount == null) {
        currentCount = 0
    }
    if (upOrDown) {
        currentCount += 1
    } else {
        currentCount -= 1
    }
    map.set(user, currentCount)
    localStorage.voteMemory = JSON.stringify(Array.from(map.entries()))
}

let votesForUser = (user) => {
    return voteMemory().get(user)
}
