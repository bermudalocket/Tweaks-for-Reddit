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
            } else if (event.name === "userKarmaFetchRequestResponse") {
                const user = event.message["user"]
                const karma = event.message["karma"]
                document.querySelectorAll(".comment").forEach(comment => {
                    const author = comment.getAttribute("data-author")
                    if (author === user) {
                        let karmaDiv = document.createElement("span")
                        karmaDiv.textContent = `[${karma}] `
                        karmaDiv.classList.add(karma < 0 ? "rdtwks-negativeKarmaMemory" : "rdtwks-positiveKarmaMemory")
                        const authorElement = comment.querySelector(".author")
                        authorElement.parentNode.insertBefore(karmaDiv, authorElement.nextSibling)
                    }
                })
            } else if (event.name == "threadCommentCountFetchRequestResponse") {
                debug("threadCommentCountFetchRequestResponse in: " + event.message["thread"] + " -> " + event.message["count"])
                showNewComments("fulfillRequest", event.message)
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


// MARK: showEstimatedDownvotes
const showEstimatedDownvotes = () => {
    const scoreDiv = document.querySelector("div.score")
    const scoreInfo = scoreDiv.textContent.split(" ")
    if (scoreInfo.length >= 3) {
        // 0 -> points, 1 -> "points", 2 -> percent
        const points = scoreInfo[0].replace(",", "")
        const percent = scoreInfo[2].replace("(", "").replace("%","")
        const downvotes = Math.round((points*100)/percent) - points

        let upvoteDiv = document.createElement("div")
        upvoteDiv.classList.add("rdtwks-upvotes")
        upvoteDiv.textContent = `▲ ${Number(points).toLocaleString()}`

        let downvoteDiv = document.createElement("div")
        downvoteDiv.classList.add("rdtwks-downvotes")
        downvoteDiv.textContent = `▼ ${Number(downvotes).toLocaleString()}`

        scoreDiv.childNodes.forEach(e => scoreDiv.removeChild(e))
        scoreDiv.textContent = ""
        scoreDiv.append(upvoteDiv)
        scoreDiv.append(downvoteDiv)
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
    document.querySelectorAll(".comment").forEach(comment => {
        const author = comment.getAttribute("data-author")
        safari.extension.dispatchMessage("userKarmaFetchRequest", {
            "user": author
        })
        comment.querySelector(".arrow.up").addEventListener("click", event => {
            safari.extension.dispatchMessage("userKarmaSaveRequest", {
                "user": author,
                "karma": 1
            })
        })
        comment.querySelector(".arrow.down").addEventListener("click", event => {
            safari.extension.dispatchMessage("userKarmaSaveRequest", {
                "user": author,
                "karma": -1
            })
        })
    })
}

// MARK: showNewComments
let showNewComments = (context, userInfo) => {
    if (context === "parseAndSave") {
        const id = String(window.location).match(/\/comments\/([a-zA-Z0-9]+)\//)[1]
        let comments = document.querySelector("a.bylink.comments").textContent.split(" ")[0]
        safari.extension.dispatchMessage("threadCommentCountSaveRequest", {
            "thread": id,
            "count": comments
        })
    } else if (context === "parseAndLoad") {
        document.querySelectorAll("a.bylink.comments").forEach(node => {
            let id = node.getAttribute("href").match(/\/comments\/([a-zA-Z0-9]+)\//)[1]
            safari.extension.dispatchMessage("threadCommentCountFetchRequest", {
                "thread": id
            })
        })
    } else if (context === "fulfillRequest") {
        debug("showNewComments('fulfillRequest')")
        document.querySelectorAll("a.bylink.comments[href*='" + userInfo["thread"] + "']").forEach(node => {
            const currentCount = node.textContent.replace(" comments", "").replace(" comment", "")
            const saved = userInfo["count"]
            console.log("saved = " + saved)
            if (saved && saved > 0) {
                console.log("saved > 0")
                node.closest(".thing").style.opacity = 0.55
                if (saved <= currentCount) {
                    const diff = currentCount - saved
                    if (!isNaN(diff)) {
                        node.append(` [${diff} NEW]`)
                    }
                }
            }
        })
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
