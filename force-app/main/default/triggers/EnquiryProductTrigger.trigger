trigger EnquiryProductTrigger on Enquiry_Product__c (after insert, after update, after delete, after undelete) {
    if (Trigger.isAfter && Trigger.isInsert) {
        EnquiryProductHandler.handleAfterInsert(Trigger.new);
    }
    if (Trigger.isAfter && Trigger.isUpdate) {
        EnquiryProductHandler.handleAfterUpdate(Trigger.newMap, Trigger.oldMap);
    }
    if (Trigger.isAfter && Trigger.isDelete) {
        EnquiryProductHandler.handleAfterDelete(Trigger.old);
    }
    if (Trigger.isAfter && Trigger.isUndelete) {
        EnquiryProductHandler.handleAfterUndelete(Trigger.new);
    }
}