import { v4 as uuidv4 } from 'uuid';

console.log("---------------------------------------------------------");
console.log("- Tweaks for Reddit is initializing...                  -");
console.log("---------------------------------------------------------");

function debug(msg: string): void {
    console.log(`[Tweaks for Reddit][DEBUG] ${msg}`);
}

function ready(callback: () => void): void {
    if (document.readyState != "loading") {
        callback();
    } else {
        document.addEventListener("DOMContentLoaded", callback);
    }
}

// test
debug("this is a test");
console.log("[TFR Test] uuidv4 = " + uuidv4());

interface Feature {
    name: string;
    enabled: boolean;
    run(subject?: HTMLElement): void;
}

const expandableDomains = [ "i.redd.it", "reddit.com", "i.imgur.com", "pbs.twimg.com" ];

const autoExpandImages: Feature = {
    name: "Auto-expand images",
    enabled: false,
    run: (subject?: HTMLElement) => {
        (subject ?? document).querySelectorAll(".thing").forEach(e => {
            const dataUrl = e.getAttribute("data-url");
            if (dataUrl === null) return;
            for (const i in expandableDomains) {
                const domain = expandableDomains[i]
                if (dataUrl.includes(domain)) {
                    const expando = e.querySelector(".expando-button:not(.expanded)");
                    if (expando instanceof HTMLElement) {
                        expando.click();
                        break;
                    }
                }
            }
        });
    }
};

const oldReddit: Feature = {
    name: "Always use old Reddit",
    enabled: false,
    run: (subject?: HTMLElement) => {
        const isOldReddit = document.querySelector("ul.sr-bar") !== null;
        if (!isOldReddit) {
            const url = window.location.href;
            if (url.includes("/poll/")) {
                return
            } else if (url.startsWith("https://www.reddit")) {
                window.location.href = url.replace("www", "old");
            } else if (url.startsWith("https://reddit.com")) {
                window.location.href = url.replace("reddit.com", "old.reddit.com")
            }
        }
    }
};

const favoriteSubredditBar: Feature = {
    name: "Favorite subreddits bar",
    enabled: false,
    run: (subject?: HTMLElement) => {
        const bar = document.querySelector("ul.sr-bar");
        if (bar === null) return;
        for (let i = 3; i < bar.childElementCount; i++) {
            const node = bar.childNodes[i];
            if (node instanceof HTMLElement) node.style.display = "none";
        }
    }
};

const allFeatures = [
    autoExpandImages,
    oldReddit
];

