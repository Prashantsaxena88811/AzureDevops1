trigger LiveChatTranscriptTrigger on LiveChatTranscript (after update) {
    LiveChatTranscriptTriggerHandler.updateCase(Trigger.New, Trigger.OldMap);
}