const debug = (msg) => {
    console.log(`[Tweaks for Reddit][DEBUG] ${msg}`)
}

const ready = (callback) => {
    if (document.readyState != "loading") callback()
    else document.addEventListener("DOMContentLoaded", callback)
}

const uuidv4 = () => {
    return "10000000-1000-4000-8000-100000000000".replace(/[018]/g, c =>
        (c ^ crypto.getRandomValues(new Uint8Array(1))[0] & 15 >> c / 4).toString(16)
    );
}

const enabledFeatures = {
    autoExpandImages: false,
    hideAds: false,
    hidePromotedPosts: false,
    hideHappeningNowBanners: false,
    rememberUserVotes: false,
}

ready(() => {
    if (window.top === window) {
        safari.self.addEventListener("message", event => {
            switch (event.name) {
                case "script":
                    let func = event.message["function"]
                    eval(func)
                    switch (func) {
                        case "autoExpandImages()": enabledFeatures.autoExpandImages = true; break;
                        case "hideAds()": enabledFeatures.hideAds = true; break;
                        case "hidePromotedPosts()": enabledFeatures.hidePromotedPosts = true; break;
                        case "hideHappeningNowBanners()": enabledFeatures.hideHappeningNowBanners = true; break;
                        case "rememberUserVotes()": enabledFeatures.rememberUserVotes = true; break;
                    }
                    break

                case "userKarmaFetchRequestResponse":
                    debug(`${event.name} in: ${event.message['user']} -> ${event.message['karma']}`)
                    rememberUserVotes("userKarmaFetchRequestResponse", event.message)
                    break

                case "threadCommentCountFetchRequestResponse":
                    debug(`${event.name} in: ${event.message["thread"]} -> ${event.message["count"]}`)
                    showNewComments("fulfillRequest", event.message)
                    break
            }
        });
        safari.extension.dispatchMessage("begin", { "url": window.location.href })
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
            if (enabledFeatures.hidePromotedPosts) {
                hidePromotedPosts(preloadedData)
            }
            if (enabledFeatures.hideHappeningNowBanners) {
                hideHappeningNowBanners(preloadedData)
            }
            if (enabledFeatures.hideAds) {
                hideAds(preloadedData)
            }
            debug("Endless scrolling: preloading completed")
        })

    ready(preloadData)

    const postLoadTasks = () => {
        if (enabledFeatures.autoExpandImages) {
            autoExpandImages()
        }
        if (enabledFeatures.rememberUserVotes) {
            rememberUserVotes("load")
        }
    }

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
                        postLoadTasks()
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
const removeAll = (selector, subject) => {
    (subject ?? document).querySelectorAll(selector).forEach(e => e.remove())
}
const hideAds = (subject) => removeAll(".ad-container, .ad-container, #ad_1", subject)
const hideNSFW = (subject) => removeAll(".over18", subject)
const hidePromotedPosts = (subject) => removeAll(".promoted", subject)
const hideUsername = (subject) => removeAll("#header-bottom-right .user a", subject)
const hideRedditPremiumBanner = (subject) => removeAll(".premium-banner-outer", subject)
const hideNewRedditButton = (subject) => removeAll(".redesign-beta-optin", subject)
const hideHappeningNowBanners = (subject) => removeAll(".happening-now-wrap", subject)

const hideJunk = () => {
    hideAds()
    hidePromotedPosts()
    hideRedditPremiumBanner()
    hideNewRedditButton()
    hideHappeningNowBanners()
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

// MARK: autoExpandImages
let autoExpandImages = (subject) => {
    debug(`[AutoExpandImages] Begin scan on ${subject ?? document}`)
    const expandableDomains = [ "i.redd.it", "reddit.com", "i.imgur.com", "pbs.twimg.com" ];
    Array.from((subject ?? document).querySelectorAll(".thing"))
        .filter(e => {
            const dataUrl = e.getAttribute("data-url")
            if (!dataUrl) return false
            for (const i in expandableDomains) {
                const domain = expandableDomains[i]
                if (dataUrl.includes(domain)) {
                    return true
                }
            }
            return false
        })
        .forEach(e => e.querySelector(".expando-button:not(.expanded)")?.click())
}

// MARK: oldReddit
let oldReddit = () => {
    const isOldReddit = document.querySelector("ul.sr-bar")
    const url = window.location.href
    if (!isOldReddit) {
        if (url.includes("/poll/")) {
            return
        } else if (url.startsWith("https://www.reddit")) {
            window.location = url.replace("www", "old")
        } else if (url.startsWith("https://reddit.com")) {
            window.location = url.replace("reddit.com", "old.reddit.com")
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

// MARK: rememberUserVotes
let rememberUserVotes = (context, userInfo, subject) => {
    if (!subject) {
        subject = document
    }
    let selector = (window.location.href.includes("/comments/")) ? ".comment" : ".thing"

    if (context === "userKarmaFetchRequestResponse") {
        const user = userInfo["user"]
        const karma = userInfo["karma"]
        subject.querySelectorAll(selector).forEach(comment => {
            const author = comment.getAttribute("data-author")
            if (author === user) {
                let karmaDiv = document.createElement("span")
                karmaDiv.textContent = `[${karma}] `
                karmaDiv.classList.add(karma < 0 ? "rdtwks-negativeKarmaMemory" : "rdtwks-positiveKarmaMemory")
                const authorElement = comment.querySelector(".author")
                authorElement.parentNode.insertBefore(karmaDiv, authorElement.nextSibling)
            }
        })
    } else {
        let completedAuthors = []
        subject.querySelectorAll(selector).forEach(comment => {
            const author = comment.getAttribute("data-author");
            const permalink = comment.getAttribute("data-permalink");
            const text = comment.querySelector(".usertext-body .md p")?.innerHTML;
//            console.log("author: " + author);
//            console.log("permalink: " + permalink);
//            console.log("text: " + text);
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
}

// MARK: showNewComments
let showNewComments = (context, userInfo, subject) => {
    if (!subject) {
        subject = document
    }
    if (context === "parseAndSave") {
        const id = String(window.location).match(/\/comments\/([a-zA-Z0-9]+)\//)[1]
        let comments = subject.querySelector("a.bylink.comments").textContent.split(" ")[0]
        safari.extension.dispatchMessage("threadCommentCountSaveRequest", {
            "thread": id,
            "count": comments
        })
    } else if (context === "parseAndLoad") {
        subject.querySelectorAll("a.bylink.comments").forEach(node => {
            let id = node.getAttribute("href").match(/\/comments\/([a-zA-Z0-9]+)\//)[1]
            safari.extension.dispatchMessage("threadCommentCountFetchRequest", {
                "thread": id
            })
        })
    } else if (context === "fulfillRequest") {
        subject.querySelectorAll("a.bylink.comments[href*='" + userInfo["thread"] + "']:not(.tfr)").forEach(node => {
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
                node.querySelector(".expando-button.expanded")?.click()
                node.classList.add("tfr") // token which blacklists this post/comment from being marked again
            }
        })
    }
}
