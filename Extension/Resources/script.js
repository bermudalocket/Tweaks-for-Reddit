"use strict";
exports.__esModule = true;
var uuid_1 = require("uuid");
console.log("---------------------------------------------------------");
console.log("- Tweaks for Reddit is initializing...                  -");
console.log("---------------------------------------------------------");
function debug(msg) {
    console.log("[Tweaks for Reddit][DEBUG] " + msg);
}
function ready(callback) {
    if (document.readyState != "loading") {
        callback();
    }
    else {
        document.addEventListener("DOMContentLoaded", callback);
    }
}
// test
debug("this is a test");
console.log("[TFR Test] uuidv4 = " + uuid_1.v4());
var Feature;
(function (Feature) {
    Feature[Feature["autoExpandImages"] = 0] = "autoExpandImages";
    Feature[Feature["hideAds"] = 1] = "hideAds";
    Feature[Feature["hidePromotedPosts"] = 2] = "hidePromotedPosts";
    Feature[Feature["hideHappeningNowBanners"] = 3] = "hideHappeningNowBanners";
    Feature[Feature["rememberUserVotes"] = 4] = "rememberUserVotes";
})(Feature || (Feature = {}));
