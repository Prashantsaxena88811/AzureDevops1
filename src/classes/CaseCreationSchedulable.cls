public class CaseCreationSchedulable implements Schedulable  {
    String accessToken;
    list<String> callOutCaseIds;
    public CaseCreationSchedulable(list<String> callOutCaseIds,String accessToken){
        this.accessToken = accessToken;
        this.callOutCaseIds = callOutCaseIds;
    }
    public void execute(SchedulableContext ctx) {
        System.enqueueJob(new CaseCreationQueueable(callOutCaseIds,accessToken));//pass access token
    }
}