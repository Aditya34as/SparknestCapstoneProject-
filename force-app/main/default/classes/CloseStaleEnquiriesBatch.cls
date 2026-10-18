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
            SELECT Id, Status__c
            FROM Enquiry__c
            WHERE Status__c = 'In Progress'
            AND LastModifiedDate < :cutOffTime
            AND (LastActivityDate = null OR LastActivityDate < :cutOffDate)
        ]);
    }

    public void execute(Database.BatchableContext bc, List<Enquiry__c> scope) {
        for (Enquiry__c enq : scope) {
            enq.Status__c = 'Closed';
        }
        Database.update(scope, false);
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('CloseStaleEnquiriesBatch finished');
    }
}