const debug = (msg) => {
    console.log(`[Tweaks for Reddit][DEBUG] ${msg}`)
}

const ready = (callback) => {
    if (document.readyState != "loading") callback()
    else document.addEventListener("DOMContentLoaded", callback)
}

const uuidv4 = () => {
    return ([1e7]+-1e3+-4e3+-8e3+-1e11).replace(/[018]/g, c =>
        (c ^ crypto.getRandomValues(new Uint8Array(1))[0] & 15 >> c / 4).toString(16)
    );
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

// MARK: - TFRFeature implementations

// MARK: liveCommentPreview
// NoCommit.swift

// MARK: endlessScroll
let endlessScroll = () => {

    var isLoading = false

    const getNextPageURL = () => {
        const nextButtons = document.querySelectorAll(".next-button > a")
        if (nextButtons) {
            const lastNextButton = nextButtons[nextButtons.length - 1]
            return lastNextButton?.getAttribute("href")
        }
        return null
    }

    let preloadedData

    const preloadData = () => fetch(getNextPageURL())
        .then(response => {
            if (response.status === 200) {
                return response.text()
            } else {
                debug("Endless scrolling: !!! bad response while preloading")
            }
        })
        .then(text => {
            debug("Endless scrolling: fetched preload data... parsing...")
            const parser = new DOMParser()
            const html = parser.parseFromString(text, "text/html")
            preloadedData = html.documentElement.querySelector(".sitetable")
            debug("Endless scrolling: preloading completed")
        })

    ready(preloadData)

    window.onscroll = async () => {
        if (!isLoading && (window.innerHeight + window.pageYOffset) >= document.body.offsetHeight - (window.innerHeight/3)) {
            isLoading = true
            debug("Endless scrolling: attempting to pull next page...")
            const nextButtons = document.querySelectorAll(".next-button")
            const nextButton = nextButtons[nextButtons.length - 1]
            if (nextButton) {
                debug("Endless scrolling: found .next-button")
                const parentNode = nextButton.parentNode?.parentNode
                if (parentNode) {
                    parentNode.style.display = "none"
                    debug("Endless scrolling: removed .next-button's parentNode")
                }
                const siteTable = document.querySelector(".sitetable")
                if (siteTable) {
                    if (preloadedData) {
                        preloadedData.childNodes.forEach(node => siteTable.appendChild(node))
                    } else {
                        debug("Endless scrolling: there is no preloaded data")
                    }
                    preloadData()
                } else {
                    debug("Endless scrolling: could not find a .sitetable")
                }
            } else {
                debug("Endless scrolling: could not find a .next-button")
            }
            isLoading = false
        }
    }
}

// MARK: showKarma
let showKarma = () => {
    let username = document.querySelector(".user a").textContent
    let url = window.location.href.startsWith("https://old")
        ? `https://old.reddit.com/user/${username}`
        : `https://www.reddit.com/user/${username}`
    let karmaArea = document.querySelector("span .userkarma")
    let karma = karmaArea.textContent

    let postKarmaLink = document.createElement("a")
    postKarmaLink.href = `${url}/submitted/`
    postKarmaLink.textContent = karma

    let commentKarmaLink = document.createElement("a")
    commentKarmaLink.href = `${url}/comments/`

    fetch(url)
        .then(response => response.text())
        .then(text => {
            const parser = new DOMParser()
            const html = parser.parseFromString(text, "text/html")
            const karma = html.documentElement.querySelector(".comment-karma").textContent
            commentKarmaLink.textContent = karma
            let span = document.querySelector("span.userkarma")
            span.childNodes.forEach(e => e.remove())

            let container = document.createElement("karmaContainer")
            container.appendChild(postKarmaLink)
            container.append(" | ")
            container.appendChild(commentKarmaLink)

            span.append(container)
        })
}

// MARK: hide junk
const removeAll = (selector) => document.querySelectorAll(selector).forEach(e => e.remove())
const hideAds = () => removeAll('.ad-container, .ad-container, #ad_1')
const hidePromotedPosts = () => removeAll(".promoted")
const hideUsername = () => removeAll("#header-bottom-right .user a")
const hideRedditPremiumBanner = () => removeAll(".premium-banner-outer")
const hideNewRedditButton = () => removeAll(".redesign-beta-optin")
const hideHappeningNowBanners = () => removeAll('.happening-now-wrap')

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

// MARK: autoExpandImages
let autoExpandImages = () => {
    const expandableDomains = [ "i.redd.it", "reddit.com", "i.imgur.com", "pbs.twimg.com" ]
    document.querySelectorAll(".thing.collapsed").forEach(e => {
        if (expandableDomains.includes(e.getAttribute("data-domain"))) {
            e.querySelector(".expando-button")?.click()
        }
    })
}

// MARK: oldReddit
let oldReddit = () => {
    const isOldReddit = document.querySelector("ul.sr-bar")
    if (!isOldReddit) {
        if (url.includes("/poll/")) {
            return
        } else if (url.startsWith("https://www.reddit")) {
            window.location = window.location.href.replace("www", "old")
        } else if (url.startsWith("https://reddit.com")) {
            window.location = window.location.href.replace("reddit.com", "old.reddit.com")
        }
    }
}

// MARK: noChat
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

// MARK: customSubredditBar
let customSubredditBar = (subs) => {
    let bars = document.querySelectorAll("ul.sr-bar")

    const firstBar = bars[0]
    for (let i = 3; i < firstBar.childElementCount; i++) {
        const node = firstBar.childNodes[i]
        if (node) node.style.display = "none"
    }

    const subsBar = bars[1]
    for (let i = 0; i < subsBar.childElementCount; i++) {
        const node = subsBar.childNodes[i]
        if (node && node.style) node.style.display = "none"
    }

    for (let i = 0; i < subs.length; i++) {
        const sub = subs[i]
        let subSpan = document.createElement("a")
        subSpan.href = `https://www.reddit.com/r/${sub}`
        subSpan.textContent = sub
        subsBar.appendChild(subSpan)
        if (i != subs.length - 1) {
            subsBar.append(" - ")
        }
    }
}

// MARK: collapseAutoModerator
let collapseAutoModerator = () => {
    document.querySelectorAll('div[data-author=AutoModerator]').forEach(e => {
        e.classList.remove('noncollapsed')
        e.classList.add('collapsed')
        e.querySelectorAll('.expand').textContent = "[+]"
    })
}

// MARK: collapseChildComments
let collapseChildComments = () => document.querySelectorAll(".comment .noncollapsed").forEach(e => {
    e.classList.remove('noncollapsed')
    e.classList.add('collapsed')
    let child = e.querySelector(".expand")
    if (child) {
        child.textContent = "[+]"
    }
})

// MARK: nsfwFilter
let nsfwFilter = () => removeAll(".over18")

// MARK: rememberUserVotes
let rememberUserVotes = () => {
    let completedAuthors = []
    document.querySelectorAll(".comment").forEach(comment => {
        const author = comment.getAttribute("data-author")
        comment.querySelector(".arrow.up")?.addEventListener("click", _ => {
            safari.extension.dispatchMessage("userKarmaSaveRequest", {
                "user": author,
                "karma": 1
            })
        })
        comment.querySelector(".arrow.down")?.addEventListener("click", _ => {
            safari.extension.dispatchMessage("userKarmaSaveRequest", {
                "user": author,
                "karma": -1
            })
        })
        if (completedAuthors.includes(author)) {
            return
        }
        completedAuthors.push(author)
        safari.extension.dispatchMessage("userKarmaFetchRequest", {
            "user": author
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
        document.querySelectorAll("a.bylink.comments[href*='" + userInfo["thread"] + "']").forEach(node => {
            const currentCount = node.textContent.replace(" comments", "").replace(" comment", "")
            const saved = userInfo["count"]
            if (saved && saved > 0) {
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
