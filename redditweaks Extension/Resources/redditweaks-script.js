const ready = (callback) => {
    if (document.readyState != "loading") callback();
    else document.addEventListener("DOMContentLoaded", callback);
}

ready(() => {
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

const removeAll = (selector) => document.querySelectorAll(selector).forEach(e => e.remove())

let hideAds = () => removeAll('.ad-container, .ad-container, #ad_1')
let hidePromotedPosts = () => removeAll(".promoted")
let hideUsername = () => removeAll("#header-bottom-right .user a")
let hideRedditPremiumBanner = () => removeAll(".premium-banner-outer")
let hideNewRedditButton = () => removeAll(".redesign-beta-optin")
let hideHappeningNowBanners = () => removeAll('.happening-now-wrap')

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

let noChat = () => {
    let chat = document.querySelector("a#chat")
    if (chat) {
        chat.nextSibling.remove()
        chat.remove();
        document.querySelector("#chat-app").remove()
        document.querySelectorAll("script").forEach(e => {
            if ((/^\/_chat/).test(new URL(e.src, location.origin).pathname)) {
                e.remove()
            }
        })
    }
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

let collapseAutoModerator = () => {
    document.querySelectorAll('div[data-author=AutoModerator]').forEach(e => {
        e.classList.remove('noncollapsed')
        e.classList.add('collapsed')
        e.querySelectorAll('.expand').textContent = "[+]"
    })
}

let collapseChildComments = () => document.querySelectorAll(".comment .noncollapsed").forEach(e => {
    e.classList.remove('noncollapsed')
    e.classList.add('collapsed')
    let child = e.querySelector(".expand")
    if (child) {
        child.textContent = "[+]"
    }
})

let nsfwFilter = () => removeAll(".over18")

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

let showNewComments = (context) => {
    if (context === "parseAndSave") {
        let thisThread = getThreadId()
        let comments = document.querySelector("a.bylink.comments").textContent.split(" ")[0]
        var map = getThreadCommentStorage()
        map.set(thisThread, comments)
        localStorage.threadCommentStorage = JSON.stringify(Array.from(map.entries()))
    } else if (context === "parseAndLoad") {
        $("a.bylink.comments").each(function() {
            let threadId = String($(this).attr("href")).match(/\/comments\/(?<threadId>[a-zA-Z0-9]+)\//).groups.threadId
            let precomments = String($(this).html()).match(commentsMatcher)
            let comments = (precomments == null) ? 0 : precomments.groups.numComments
            let saved = getThreadCommentStorage().get(threadId)
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
