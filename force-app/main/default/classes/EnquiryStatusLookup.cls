public with sharing class EnquiryStatusLookup {

    public class Request {
        @InvocableVariable(label='Customer Email' description='Email the customer used when submitting the enquiry' required=true)
        public String email;
    }

    public class Result {
        @InvocableVariable(label='Enquiry Found')
        public Boolean found;

        @InvocableVariable(label='Enquiry Number')
        public String enquiryNumber;

        @InvocableVariable(label='Status')
        public String status;

        @InvocableVariable(label='Closed Date')
        public Date closedDate;

        @InvocableVariable(label='Message')
        public String message;
    }

    @InvocableMethod(label='Get Enquiry Status' description='Finds the latest enquiry for a customer email and returns its status')
    public static List<Result> getEnquiryStatus(List<Request> requests) {
        List<String> emails = new List<String>();
        for (Request req : requests) {
            if (String.isNotBlank(req.email)) {
                emails.add(req.email.trim().toLowerCase());
            }
        }

        // step 1: find the contacts for these emails
        Map<Id, String> emailByContactId = new Map<Id, String>();
        for (Contact con : [SELECT Id, Email FROM Contact WHERE Email IN :emails]) {
            emailByContactId.put(con.Id, con.Email.toLowerCase());
        }
        List<Id> contactIds = new List<Id>(emailByContactId.keySet());

        // step 2: their enquiries, newest first, so the first one per email is the latest
        Map<String, Enquiry__c> latestEnquiryByEmail = new Map<String, Enquiry__c>();
        for (Enquiry__c enq : [SELECT Name, Status__c, Closed_Date__c, Contact__c
                               FROM Enquiry__c
                               WHERE Contact__c IN :contactIds
                               ORDER BY CreatedDate DESC]) {
            String key = emailByContactId.get(enq.Contact__c);
            if (!latestEnquiryByEmail.containsKey(key)) {
                latestEnquiryByEmail.put(key, enq);
            }
        }

        List<Result> results = new List<Result>();
        for (Request req : requests) {
            Result res = new Result();
            res.found = false;

            Enquiry__c enq = null;
            if (String.isNotBlank(req.email)) {
                enq = latestEnquiryByEmail.get(req.email.trim().toLowerCase());
            }

            if (enq == null) {
                res.message = 'We could not find any enquiry for this email. Please check the email or submit a new enquiry.';
            } else {
                res.found = true;
                res.enquiryNumber = enq.Name;
                res.status = enq.Status__c;
                res.closedDate = enq.Closed_Date__c;

                if (enq.Status__c == 'Closed' && enq.Closed_Date__c != null) {
                    res.message = 'Your enquiry ' + enq.Name + ' was closed on ' + enq.Closed_Date__c.format() + '. Would you like to raise a new enquiry?';
                } else {
                    res.message = 'Your enquiry ' + enq.Name + ' is currently ' + enq.Status__c + '. Our team will get back to you soon.';
                }
            }
            results.add(res);
        }
        return results;
    }
}