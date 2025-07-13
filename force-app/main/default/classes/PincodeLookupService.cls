public with sharing class PincodeLookupService {

    // Wrapper class to parse the API response
    public class PincodeResponse {
        @AuraEnabled
        public String Message;
        @AuraEnabled
        public String Status;
        @AuraEnabled
        public List<PostOffice> PostOffice; // This will be null if no PostOffice objects are returned
    }

    public class PostOffice {
        @AuraEnabled
        public String Name;
        @AuraEnabled
        public String Description;
        @AuraEnabled
        public String BranchType;
        @AuraEnabled
        public String DeliveryStatus;
        @AuraEnabled
        public String Circle;
        @AuraEnabled
        public String District;
        @AuraEnabled
        public String Division;
        @AuraEnabled
        public String Region;
        @AuraEnabled
        public String State;
        @AuraEnabled
        public String Country;
        @AuraEnabled
        public String Pincode;
    }

    @AuraEnabled(cacheable=true)
    public static PincodeResponse getPincodeDetails(String pincode) {
        PincodeResponse result = new PincodeResponse();

        // Basic validation for pincode length (assuming 6 digits)
        if (pincode == null || pincode.length() != 6 || !pincode.isNumeric()) {
            result.Status = 'Error';
            result.Message = 'Please enter a valid 6-digit numeric pincode.';
            return result;
        }

        String endpoint = 'http://www.postalpincode.in/api/pincode/' + pincode;

        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('GET');
        request.setTimeout(60000); // 60 seconds timeout

        Http http = new Http();
        HttpResponse response;

        try {
            response = http.send(request);
            String jsonResponse = response.getBody();
            System.debug('API Response Body: ' + jsonResponse); // Debug the raw response

            if (response.getStatusCode() == 200) {
                // IMPORTANT: Handle the API's inconsistent response format
                // The API can return:
                // 1. An array of PincodeResponse objects: [{"Message":"Success","Status":"Success","PostOffice":[...]}],
                // 2. An array with an error object: [{"Message":"No records found","Status":"Error"}],
                // 3. (Less common, but possible) A simple JSON object without an array if something goes wrong on their end.

                // First, try to deserialize as a List, which is the most common successful format.
                try {
                    List<PincodeResponse> apiResponses = (List<PincodeResponse>) JSON.deserialize(jsonResponse, List<PincodeResponse>.class);

                    if (apiResponses != null && !apiResponses.isEmpty()) {
                        result = apiResponses[0]; // Take the first response object
                    } else {
                        // This path might be hit if the list is empty, though unlikely for this API on success.
                        result.Status = 'Error';
                        result.Message = 'No data found or unexpected empty response from API.';
                    }
                } catch (JSONException e) {
                    // If deserializing as List<PincodeResponse> fails, it might be a single object (e.g., error response)
                    System.debug('Attempting to deserialize as single PincodeResponse due to JSONException: ' + e.getMessage());
                    try {
                        result = (PincodeResponse) JSON.deserialize(jsonResponse, PincodeResponse.class);
                        // If it successfully deserializes to a single PincodeResponse, check its status/message
                        if (result == null || result.Status == 'Error') {
                            // If deserialized but status is Error, use its message
                            result.Status = 'Error';
                            result.Message = result.Message != null ? result.Message : 'Failed to parse API response as a single object.';
                        }
                    } catch (JSONException innerE) {
                        // If both attempts fail, the JSON format is truly unexpected
                        result.Status = 'Error';
                        result.Message = 'Malformed JSON response from API: ' + innerE.getMessage();
                        System.debug('Failed to deserialize JSON in all attempts: ' + jsonResponse + ' - ' + innerE.getMessage());
                    }
                }
            } else {
                // Handle non-200 status codes
                result.Status = 'Error';
                result.Message = 'API Callout failed with status code: ' + response.getStatusCode() + ' ' + response.getStatus() + '. Response: ' + jsonResponse;
                System.debug('Pincode API Error (Non-200): ' + response.getStatusCode() + ' - ' + response.getBody());
            }
        } catch (Exception e) {
            result.Status = 'Error';
            result.Message = 'An unexpected error occurred during callout: ' + e.getMessage() + '. Please check Remote Site Settings.';
            System.debug('Pincode API Exception: ' + e.getMessage() + ' - Stack Trace: ' + e.getStackTraceString());
        }

        // Ensure that if PostOffice list is null, it's explicitly handled or initialized to avoid issues in LWC if it expects a list.
        if (result.PostOffice == null && result.Status == 'Success') {
             // This case should ideally not happen if Status is 'Success' and data is found.
             // If it does, it implies a malformed 'Success' response without PostOffice data.
             result.Status = 'Error';
             result.Message = 'API returned success but no postal office details found.';
        }

        return result;
    }
}