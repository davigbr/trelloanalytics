(function(){
	var authenticationSuccess = function(param) {
		window.location.href = '/authorized/' + localStorage['trello_token'];
	};
	var authenticationFailure = function() { 
		console.log("Failed authentication");
	};
	Trello.authorize({
		type: "redirect",
		name: "Analytics",
		persist: true,
		scope: {
	    	read: true,
	    	write: true
	    },
	 	expiration: "1day",
	 	success: authenticationSuccess,
		error: authenticationFailure
	});
})();