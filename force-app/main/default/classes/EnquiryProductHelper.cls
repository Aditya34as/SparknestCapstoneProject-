public with sharing class EnquiryProductHelper {

    public static void updateProductCount(Set<Id> enquiryIds) {

        List<Enquiry__c> enquiryList = [
            SELECT Id, Total_Products_Interested__c,
                   (SELECT Id FROM Enquiry_Products__r)
            FROM Enquiry__c
            WHERE Id IN :enquiryIds
        ];

        for (Enquiry__c enq : enquiryList) {
            enq.Total_Products_Interested__c = enq.Enquiry_Products__r.size();
        }

        if (!enquiryList.isEmpty()) {
            update as system enquiryList;   ////// system mode: the count is calculated by code, users only have read access to it/////
        }
    }
}