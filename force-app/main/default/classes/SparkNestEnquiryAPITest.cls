@IsTest
private class SparkNestEnquiryAPITest {

    private static void setRequest(String jsonBody) {
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/sparknest/enquiry';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(jsonBody);
        RestContext.request = req;
        RestContext.response = new RestResponse();
    }

    @IsTest
    static void newCustomerTest() {
        setRequest('{"firstName":"Test","lastName":"Web","email":"new.web@testsparknest.com","subject":"Need earbuds","enquiryType":"Product Enquiry","budget":3000}');

        Test.startTest();
        SparkNestEnquiryAPI.EnquiryResponse result = SparkNestEnquiryAPI.createEnquiry();
        Test.stopTest();

        Assert.isTrue(result.success, 'Request should succeed');
        Assert.areEqual('NEW', result.customerType, 'Customer should be new');
        Assert.areEqual(201, RestContext.response.statusCode);
    }

    @IsTest
    static void existingCustomerTest() {
        Contact con = TestDataFactory.createContact('Existing Web');
        setRequest('{"email":"' + con.Email + '","subject":"Need a charger","enquiryType":"Product Enquiry","budget":2000}');

        Test.startTest();
        SparkNestEnquiryAPI.EnquiryResponse result = SparkNestEnquiryAPI.createEnquiry();
        Test.stopTest();

        Assert.areEqual('EXISTING', result.customerType, 'Customer should be existing');
        Assert.areEqual(con.Id, result.contactId, 'Should use the same contact');
    }

    @IsTest
    static void missingEmailTest() {
        setRequest('{"lastName":"No Email","subject":"Test"}');

        Test.startTest();
        SparkNestEnquiryAPI.EnquiryResponse result = SparkNestEnquiryAPI.createEnquiry();
        Test.stopTest();

        Assert.isFalse(result.success);
        Assert.areEqual(400, RestContext.response.statusCode);
        Assert.areEqual('email is required', result.message);
    }

    @IsTest
    static void lowBudgetRollbackTest() {
        setRequest('{"lastName":"Low","email":"low.budget@testsparknest.com","subject":"Test","enquiryType":"Product Enquiry","budget":500}');

        Test.startTest();
        SparkNestEnquiryAPI.EnquiryResponse result = SparkNestEnquiryAPI.createEnquiry();
        Test.stopTest();

        Assert.isFalse(result.success);
        Assert.areEqual(0, [SELECT COUNT() FROM Contact WHERE Email = 'low.budget@testsparknest.com'],
                        'Contact should be rolled back');
    }
}