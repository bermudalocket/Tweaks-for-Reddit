/* jshint: browser true */
/* jshint: esversion 6 */

document.addEventListener("DOMContentLoaded", function(event) {
    if (window.top === window) {
        safari.extension.dispatchMessage("shouldFilterNSFW");
    }
});

safari.self.addEventListener("message", function(event) {
    var divs = document.getElementsByClassName("thing over18");
    if (event.name == "filter-nsfw-state") {
        let state = event.message["state"];
        if (state) {
            for (var i = 0; i < divs.length; i++) {
                let div = divs[i];
                div.style.display = "none";
                safari.extension.dispatchMessage("+over18");
            }
        } else {
            for (var j = 0; j < divs.length; j++) {
                let div = divs[j];
                div.style.display = "inline";
            }
        }
    }
}, true);
