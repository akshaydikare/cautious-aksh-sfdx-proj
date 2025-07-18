import { LightningElement, track } from 'lwc';
import findAccountById from '@salesforce/apex/findAccountById.findAccountById';

export default class AccountFinder extends LightningElement {
    @track accountIdToSearch = '';
    @track account;
    @track error;
    @track isLoading = false;

    // Handler for the input field change
    handleIdChange(event) {
        this.accountIdToSearch = event.target.value;
    }

    // Method to call Apex, used by both buttons
    callApex() {
        this.isLoading = true;
        this.account = null; // Clear previous results
        this.error = null;

        // Call the Apex method
        findAccountById({ accountId: this.accountIdToSearch })
            .then(result => {
                if (result) {
                    this.account = result;
                } else {
                    // This block will execute if Apex returns null (e.g., empty ID or no record found)
                    this.error = 'No Account found for the provided ID. Please check the ID and try again.';
                }
            })
            .catch(error => {
                this.error = 'An error occurred while fetching the account: ' + error.body.message;
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

     // Handler for the main "Search" button
     handleSearch() {
        if (!this.accountIdToSearch) {
            this.error = 'Please enter an Account ID.';
            return;
        }
        this.callApex();
    }

    // Handler for the button that demonstrates the empty string behavior
    handleSearchWithEmptyId() {
        // Explicitly set the ID to an empty string to demonstrate the behavior
        this.accountIdToSearch = '';
        console.log('Sending an empty string to Apex...');
        this.callApex();
    }
}