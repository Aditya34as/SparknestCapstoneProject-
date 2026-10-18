public interface TriggerHandler {
    void beforeInsert(List<SObject> newList);
    void beforeUpdate(List<SObject> newList, Map<Id, SObject> oldMap);
    void afterInsert(List<SObject> newList);
    
}