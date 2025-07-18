// Taken from https://github.com/stashapp/stash/issues/4175#issuecomment-1838702811

// https://stackoverflow.com/a/17799291
function contains(selector, text) {
	var elements = document.querySelectorAll(selector);

	return [].filter.call(elements, function(element) {
		return RegExp(text).test(element.textContent);
	});
}


function useHLS() {
	if (!videoPlayer.canBeStreamed() && !videoPlayer.hlsElementSelected()) {
		window.usingHLS = true;
		videoPlayer.hlsElement().click();
		console.log("Video has to be transcoded, using HLS");
	}
}

// Observe less often while not on the scene player because hundreds of observations can occur
// and any observation can confirm if the url contains /scenes/
function delayObservation(delay) {
	urlObserver.disconnect();

	setTimeout(function() {
		urlObserver.observe(document.getElementsByClassName("main container-fluid")[0], urlObserverConfig);
	}, delay);
}

/*------------------------------------------------------------------------------------------------*/

var videoPlayer = {
	videoJsElement: null,
	loadedPlayer: null,

	// https://stackoverflow.com/a/36898221
	isPlaying: function() {
		return this.loadedPlayer.currentTime > 0 &&
			!this.loadedPlayer.paused &&
			!this.loadedPlayer.ended &&
			this.loadedPlayer.readyState > this.loadedPlayer.HAVE_CURRENT_DATA;
	},

	canBeStreamed: function() {
		return (contains(".vjs-menu-item-text", /^direct stream$/i).length > 0);
	},

	hlsElement: function() { // Optional chaining (?.)
		return (contains(".vjs-menu-item-text", /^hls$/i)[0]?.parentElement);
	},

	hlsElementSelected: function() {
		return (this.hlsElement()?.classList.contains("vjs-selected"));
	}
};

var oldScene = "";
var delay = 1000;

/*------------------------------------------------------------------------------------------------*/

const videoPlayerObserverConfig = { attributes: true };

const videoPlayerObserver = new MutationObserver(function(_mutations, observer) {
	// Wait until the video is playing to avoid triggering a "The play() request was interrupted" error
	// "It is worth noting that the (play())Promise won"t fulfill until playback has actually started"
	// https://developer.chrome.com/blog/play-request-was-interrupted/

	if (videoPlayer.isPlaying()) {
		observer.disconnect();
		useHLS();
	}
});

// https://stackoverflow.com/a/67825703
// One page application that updates href but doesnt reload the page. Observe when the application gets to
// the scenes player and attach the final observer to default to HLS as needed

const urlObserverConfig = { childList: true, subtree: true };

var urlObserver = new MutationObserver(function(_mutations, _observer) {
	var onPlayerPage = location.href.toLocaleLowerCase().indexOf("/scenes/") !== -1;

	if (onPlayerPage && (!videoPlayer.loadedPlayer)) {
		videoPlayer.videoJsElement = document.querySelector("#VideoJsPlayer");
		videoPlayer.loadedPlayer = document.querySelector("#VideoJsPlayer_html5_api");
	}

	if (onPlayerPage && videoPlayer.loadedPlayer) {
		var currentScene = location.href.match(/.*\/scenes\/\d+/i)[0];

		// /scenes? is the scene list while /scenes/{number}? is the scene player
		if (currentScene !== oldScene) {
			oldScene = currentScene;
			videoPlayerObserver.observe(videoPlayer.videoJsElement, videoPlayerObserverConfig);
		}

		delayObservation(delay);
	}

	if (!onPlayerPage) {
		if (videoPlayer.loadedPlayer) {
			videoPlayer.loadedPlayer = null;
			videoPlayer.videoJsElement = null;
		}

		delayObservation(delay);
	}
});

// Only existing elements can be observed and the root element is always present
// The content of the application is then housed and updated within main
new MutationObserver(function(_mutations, observer) {
	observer.disconnect();
	urlObserver.observe(document.getElementsByClassName("main container-fluid")[0], urlObserverConfig);
}).observe(
	document.getElementById("root"),
	{ childList: true }
);
