@IsTest
private class CloseStaleEnquiriesBatchTest {

    @IsTest
    static void batchShouldCloseOnlyInProgressEnquiries() {
        Contact con = TestDataFactory.createContact('Batch Test');
        List<Enquiry__c> enquiryList = TestDataFactory.buildEnquiries(6, con.Id);
        for (Integer i = 0; i < 5; i++) {
            enquiryList[i].Status__c = 'In Progress';
        }
        insert enquiryList;   
        Test.startTest();

        Database.executeBatch(new CloseStaleEnquiriesBatch(-1));
        Test.stopTest();

        Assert.areEqual(5, [SELECT COUNT() FROM Enquiry__c WHERE Status__c = 'Closed'],
                        'All 5 In Progress enquiries should be closed');
        Assert.areEqual(1, [SELECT COUNT() FROM Enquiry__c WHERE Status__c = 'New'],
                        'The New enquiry should not be touched');
        Assert.areEqual(5, [SELECT COUNT() FROM Enquiry__c WHERE Closed_Date__c = TODAY],
                        'Trigger should stamp Closed Date on the closed ones');
    }

    @IsTest
    static void schedulerShouldBeRegistered() {
        String cronExp = '0 0 1 * * ?';

        Test.startTest();
        String jobId = System.schedule('Test Close Stale Enquiries', cronExp, new CloseStaleEnquiriesScheduler());
        Test.stopTest();

        CronTrigger job = [SELECT CronExpression, State FROM CronTrigger WHERE Id = :jobId];
        Assert.areEqual(cronExp, job.CronExpression, 'Job should use the nightly cron expression');
    }
}