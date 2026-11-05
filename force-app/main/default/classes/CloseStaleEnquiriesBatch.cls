public  class CloseStaleEnquiriesBatch implements Database.Batchable<SObject> {

    private Integer staleDays;
    public CloseStaleEnquiriesBatch() {
        this.staleDays = 30;
    }

    public CloseStaleEnquiriesBatch(Integer staleDays) {
        this.staleDays = staleDays;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        Datetime cutOffTime = System.now().addDays(-staleDays);
        Date cutOffDate = cutOffTime.date();

        return Database.getQueryLocator([
            Select Id, Status__c
            from Enquiry__c
            Where Status__c = 'In Progress'
            And LastModifiedDate < :cutOffTime
            And (LastActivityDate = null or LastActivityDate < :cutOffDate)
        ]);
    }

    public void execute(Database.BatchableContext bc, List<Enquiry__c> scope) {
        for (Enquiry__c enq : scope) {
            enq.Status__c = 'Closed';
        }
        Database.update(scope, false);//here the partial success update is done so that whole query should not roll back 
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('CloseStaleEnquiriesBatch finished');
    }
}