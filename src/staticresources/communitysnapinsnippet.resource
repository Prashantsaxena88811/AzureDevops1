window._snapinsSnippetSettingsFile = (function() {

console.log("Snippet settings file loaded.");	// Logs that the snippet settings file was loaded successfully

//embedded_svc.snippetSettingsFile.autoOpenPostChat = true;

embedded_svc.snippetSettingsFile.extraPrechatFormDetails = [
	{"label":"Contact Id", "transcriptFields": ["ContactId__c"], "displayToAgent":false}
];

embedded_svc.snippetSettingsFile.chatbotAvatarImgURL = "/resource/bot_avatar"; //"https://i.ibb.co/PjX9VBH/Eva2.png";

})();

document.addEventListener(
	"setCustomField",
	function(event) {
		console.log('setCustomField event captured');
		embedded_svc.settings.extraPrechatFormDetails[0].value = event.detail.customField;
		// Fire startChat callback.
		event.detail.callback();
	},
	false
);
