@RestResource(urlMapping='/sparknest/enquiry/*')
global with sharing class SparkNestEnquiryAPI {

    // data sent by the website
    global class EnquiryRequest {
        public String firstName;
        public String lastName;
        public String email;
        public String phone;
        public String subject;
        public String enquiryType;
        public Decimal budget;
        public String planDuration;
    }

    // data sent back to the website
    global class EnquiryResponse {
        public Boolean success;
        public String message;
        public String customerType;
        public Id contactId;
        public Id enquiryId;
    }

    @HttpPost
    global static EnquiryResponse createEnquiry() {
        RestResponse res = RestContext.response;
        EnquiryResponse result = new EnquiryResponse();

        EnquiryRequest req = (EnquiryRequest) JSON.deserialize(
            RestContext.request.requestBody.toString(), EnquiryRequest.class);

        // email is mandatory
        if (String.isBlank(req.email)) {
            res.statusCode = 400;
            result.success = false;
            result.message = 'email is required';
            return result;
        }

        Savepoint sp = Database.setSavepoint();

        try {
            // check if customer already exists
            List<Contact> contactList = [SELECT Id FROM Contact WHERE Email = :req.email LIMIT 1];
            Contact con;

            if (contactList.isEmpty()) {
                con = new Contact(
                    FirstName = req.firstName,
                    LastName = req.lastName,
                    Email = req.email,
                    Phone = req.phone
                );
                insert con;
                result.customerType = 'NEW';
            } else {
                con = contactList[0];
                result.customerType = 'EXISTING';
            }

            Enquiry__c enq = new Enquiry__c(
                Subject__c = req.subject,
                Enquiry_Type__c = req.enquiryType,
                Contact__c = con.Id,
                Customer_Budget__c = req.budget,
                Plan_Duration__c = req.planDuration,
                Source__c = 'Website'
            );
            insert enq;

            res.statusCode = 201;
            result.success = true;
            result.message = 'Enquiry created successfully';
            result.contactId = con.Id;
            result.enquiryId = enq.Id;

        } catch (Exception e) {
            // undo the new contact if the enquiry fails
            Database.rollback(sp);
            res.statusCode = 400;
            result.success = false;
            result.message = e.getMessage();
        }

        return result;
    }
}