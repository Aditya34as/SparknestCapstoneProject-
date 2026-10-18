public with sharing class TriggerDispatcher {

    public static void run(TriggerHandler handler) {
        if (Trigger.isBefore && Trigger.isInsert) {
            handler.beforeInsert(Trigger.new);
        }
        if (Trigger.isBefore && Trigger.isUpdate) {
            handler.beforeUpdate(Trigger.new, Trigger.oldMap);
        }
        if (Trigger.isAfter && Trigger.isInsert) {
            handler.afterInsert(Trigger.new);
        }
    }
}