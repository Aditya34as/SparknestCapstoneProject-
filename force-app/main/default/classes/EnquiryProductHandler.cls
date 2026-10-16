public with sharing class EnquiryProductHandler {

    public static void handleAfterInsert(List<Enquiry_Product__c> newList) {
        Set<Id> enquiryIds = getEnquiryIds(newList);
        if (enquiryIds.isEmpty()) {
            return;
        }
        EnquiryProductHelper.updateProductCount(enquiryIds);
    }

    public static void handleAfterUpdate(Map<Id, Enquiry_Product__c> newMap, Map<Id, Enquiry_Product__c> oldMap) {
        Set<Id> enquiryIds = new Set<Id>();
        for (Id epId : newMap.keySet()) {
            if (newMap.get(epId).Enquiry__c != oldMap.get(epId).Enquiry__c) {
                enquiryIds.add(newMap.get(epId).Enquiry__c);
                enquiryIds.add(oldMap.get(epId).Enquiry__c);
            }
        }
        if (enquiryIds.isEmpty()) {
            return;
        }
        EnquiryProductHelper.updateProductCount(enquiryIds);
    }

    public static void handleAfterDelete(List<Enquiry_Product__c> oldList) {
        Set<Id> enquiryIds = getEnquiryIds(oldList);
        if (enquiryIds.isEmpty()) {
            return;
        }
        EnquiryProductHelper.updateProductCount(enquiryIds);
    }

    public static void handleAfterUndelete(List<Enquiry_Product__c> newList) {
        Set<Id> enquiryIds = getEnquiryIds(newList);
        if (enquiryIds.isEmpty()) {
            return;
        }
        EnquiryProductHelper.updateProductCount(enquiryIds);
    }

    private static Set<Id> getEnquiryIds(List<Enquiry_Product__c> epList) {
        Set<Id> enquiryIds = new Set<Id>();
        for (Enquiry_Product__c ep : epList) {
            if (ep.Enquiry__c != null) {
                enquiryIds.add(ep.Enquiry__c);
            }
        }
        return enquiryIds;
    }
}