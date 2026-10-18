@IsTest
private class EnquiryProductHelperTest {

    @IsTest
    static void countShouldFollowInsertDeleteUndeleteAndMove() {
        Contact con = TestDataFactory.createContact('Count Test');
        List<Enquiry__c> enquiryList = TestDataFactory.buildEnquiries(2, con.Id);
        insert enquiryList;
        Enquiry__c firstEnq = enquiryList[0];
        Enquiry__c secondEnq = enquiryList[1];
        Product2 prod = TestDataFactory.createProduct('TEST-SKU-001');

        List<Enquiry_Product__c> interestList = new List<Enquiry_Product__c>();
        for (Integer i = 0; i < 3; i++) {
            interestList.add(new Enquiry_Product__c(Enquiry__c = firstEnq.Id, Product__c = prod.Id, Quantity_Interested__c = 1));
        }

        Test.startTest();
        insert interestList;
        Assert.areEqual(3, getCount(firstEnq.Id), 'Count should be 3 after insert');

        delete interestList[0];
        Assert.areEqual(2, getCount(firstEnq.Id), 'Count should be 2 after delete');

        undelete interestList[0];
        Assert.areEqual(3, getCount(firstEnq.Id), 'Count should be 3 after undelete');

        interestList[1].Enquiry__c = secondEnq.Id;
        update interestList[1];
        Test.stopTest();

        Assert.areEqual(2, getCount(firstEnq.Id), 'Old enquiry should drop to 2');
        Assert.areEqual(1, getCount(secondEnq.Id), 'New enquiry should go up to 1');
    }

    private static Decimal getCount(Id enquiryId) {
        return [SELECT Total_Products_Interested__c FROM Enquiry__c WHERE Id = :enquiryId].Total_Products_Interested__c;
    }
}