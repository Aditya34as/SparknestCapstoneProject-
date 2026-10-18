@IsTest
private class EnquiryServiceTest {

    @IsTest
    static void blankStatusShouldDefaultToNew() {
        Contact con = TestDataFactory.createContact('Status Test');
        Enquiry__c enq = TestDataFactory.buildEnquiries(1, con.Id)[0];
        enq.Status__c = null;

        Test.startTest();
        insert enq;
        Test.stopTest();

        Enquiry__c result = [SELECT Status__c FROM Enquiry__c WHERE Id = :enq.Id];
        Assert.areEqual('New', result.Status__c, 'Blank status should be set to New');
    }

    @IsTest
    static void lowBudgetShouldBeBlocked() {
        Contact con = TestDataFactory.createContact('Budget Test');
        Enquiry__c enq = TestDataFactory.buildEnquiries(1, con.Id)[0];
        enq.Customer_Budget__c = 500;

        Test.startTest();
        Database.SaveResult result = Database.insert(enq, false);
        Test.stopTest();

        Assert.isFalse(result.isSuccess(), 'Insert should fail when budget is below 1000');
        Assert.isTrue(result.getErrors()[0].getMessage().contains(EnquiryService.BUDGET_ERROR),
                      'Wrong error message: ' + result.getErrors()[0].getMessage());
    }

    @IsTest
    static void insertShouldCreateFollowUpTask() {
        Contact con = TestDataFactory.createContact('Task Test');
        Enquiry__c enq = TestDataFactory.buildEnquiries(1, con.Id)[0];

        Test.startTest();
        insert enq;
        Test.stopTest();

        Task followUp = [SELECT Subject, OwnerId, ActivityDate FROM Task WHERE WhatId = :enq.Id];
        Assert.areEqual('Follow up: ' + enq.Subject__c, followUp.Subject, 'Task subject is wrong');
        Assert.areEqual(UserInfo.getUserId(), followUp.OwnerId, 'Task should belong to the enquiry owner');
        Assert.areEqual(Date.today().addDays(3), followUp.ActivityDate, 'Task should be due in 3 days');
    }

    @IsTest
    static void closingShouldSetClosedDate() {
        Contact con = TestDataFactory.createContact('Close Test');
        Enquiry__c enq = TestDataFactory.buildEnquiries(1, con.Id)[0];
        insert enq;

        Test.startTest();
        enq.Status__c = 'Closed';
        update enq;
        Test.stopTest();

        Enquiry__c result = [SELECT Closed_Date__c FROM Enquiry__c WHERE Id = :enq.Id];
        Assert.areEqual(Date.today(), result.Closed_Date__c, 'Closed Date should be today');
    }

    @IsTest
    static void bulkInsertAndCloseOf200Records() {
        Contact con = TestDataFactory.createContact('Bulk Test');
        List<Enquiry__c> enquiryList = TestDataFactory.buildEnquiries(200, con.Id);

        Test.startTest();
        insert enquiryList;
        for (Enquiry__c enq : enquiryList) {
            enq.Status__c = 'Closed';
        }
        update enquiryList;
        Test.stopTest();

        Assert.areEqual(200, [SELECT COUNT() FROM Task WHERE WhatId IN :enquiryList],
                        'Each enquiry should get one follow-up task');
        Assert.areEqual(200, [SELECT COUNT() FROM Enquiry__c WHERE Id IN :enquiryList AND Closed_Date__c = TODAY],
                        'All 200 enquiries should have Closed Date set');
    }
}