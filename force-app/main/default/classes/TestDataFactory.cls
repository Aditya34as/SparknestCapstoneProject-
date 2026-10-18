@IsTest
public class TestDataFactory {

    public static Contact createContact(String lastName) {
        Contact con = new Contact(
            FirstName = 'Test',
            LastName = lastName,
            Email = lastName.toLowerCase().replace(' ', '') + '@testsparknest.com'
        );
        insert con;
        return con;
    }

    public static List<Enquiry__c> buildEnquiries(Integer count, Id contactId) {
        List<Enquiry__c> enquiryList = new List<Enquiry__c>();
        for (Integer i = 0; i < count; i++) {
            enquiryList.add(new Enquiry__c(
                Subject__c = 'Test Enquiry ' + i,
                Enquiry_Type__c = 'Product Enquiry',
                Contact__c = contactId,
                Customer_Budget__c = 5000,
                Priority__c = 'Medium'
            ));
        }
        return enquiryList;
    }

    public static Product2 createProduct(String sku) {
        Product2 prod = new Product2(Name = 'Test Product ' + sku, SKU__c = sku, IsActive = true);
        insert prod;
        return prod;
    }
}