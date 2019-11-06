document.addEventListener("DOMContentLoaded", function(event) {
    if (window.top === window) {
        safari.extension.dispatchMessage("redditweaks.domLoaded");
    }
});

function toggleElement(element, hidden) {
    var thing = document.getElementsByClassName(element);
    for (var i = 0; i < thing.length; i++) {
        thing[i].style.display = (hidden ? "none" : "inline");
    }
}

safari.self.addEventListener("message", function(event) {
    if (event.name == "redditweaks.state") {
        let nsfwFilterState = event.message["nsfw"];
        let hideNewRedditButton = event.message["hideNewRedditButton"];
        let hideRedditPremiumAd = event.message["hideRedditPremiumAd"];
        toggleElement("premium-banner-outer", hideRedditPremiumAd);
        toggleElement("redesign-beta-optin", hideNewRedditButton);
        var nsfwDivs = document.getElementsByClassName("thing over18");
        for (var i = 0; i < nsfwDivs.length; i++) {
            let div = nsfwDivs[i];
            div.style.display = (nsfwFilterState ? "none" : "inline");
            if (nsfwFilterState) {
                safari.extension.dispatchMessage("redditweaks.incrementNSFWCounter");
            }
        }
    }
}, true);
