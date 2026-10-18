public with sharing class EnquiryTriggerHandler implements TriggerHandler {

    public void beforeInsert(List<SObject> newList) {
        List<Enquiry__c> enquiryList = (List<Enquiry__c>) newList;
        EnquiryService.setDefaultStatus(enquiryList);
        EnquiryService.validateBudget(enquiryList);
    }

    public void beforeUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
        EnquiryService.setClosedDateOnClose((List<Enquiry__c>) newList, (Map<Id, Enquiry__c>) oldMap);
    }

    public void afterInsert(List<SObject> newList) {
        EnquiryService.createFollowUpTasks((List<Enquiry__c>) newList);
    }
}