function fixRatingBanner() {
	for (const banner of document.getElementsByClassName("rating-banner")) {
		banner.innerHTML = banner.innerHTML.replace("Rating: ", "");
	}
}

setInterval(fixRatingBanner, 250);
