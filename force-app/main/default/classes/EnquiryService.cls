public with sharing class EnquiryService {

    public static final String BUDGET_ERROR = 'Customer budget must be at least ₹1,000';

    public static void setDefaultStatus(List<Enquiry__c> enquiryList) {
        for (Enquiry__c enq : enquiryList) {
            if (String.isBlank(enq.Status__c)) {
                enq.Status__c = 'New';
            }
        }
    }

    
    public static void validateBudget(List<Enquiry__c> enquiryList) {
        for (Enquiry__c enq : enquiryList) {
            if (enq.Customer_Budget__c != null && enq.Customer_Budget__c < 1000) {
                enq.Customer_Budget__c.addError(BUDGET_ERROR);
            }
        }
    }

    public static void setClosedDateOnClose(List<Enquiry__c> enquiryList, Map<Id, Enquiry__c> oldMap) {
        for (Enquiry__c enq : enquiryList) {
            Enquiry__c oldEnq = oldMap.get(enq.Id);
            if (enq.Status__c == 'Closed' && oldEnq.Status__c != 'Closed') {
                enq.Closed_Date__c = Date.today();
            }
        }
    }

    
    public static void createFollowUpTasks(List<Enquiry__c> enquiryList) {
        List<Task> taskList = new List<Task>();

        for (Enquiry__c enq : enquiryList) {
            ////////////////// a Task can't be owned by a queue, so only create it when the owner is a user
            if (String.valueOf(enq.OwnerId).startsWith('005')) {
                taskList.add(new Task(
                    Subject = 'Follow up: ' + enq.Subject__c,
                    WhatId = enq.Id,
                    OwnerId = enq.OwnerId,
                    ActivityDate = Date.today().addDays(3),
                    Status = 'Not Started',
                    Priority = 'Normal'
                ));
            }
        }

        if (!taskList.isEmpty()) {
            insert taskList;
        }
    }
}