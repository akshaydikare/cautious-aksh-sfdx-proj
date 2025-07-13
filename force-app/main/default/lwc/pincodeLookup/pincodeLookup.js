import { LightningElement, track, wire } from 'lwc';
import getPincodeDetails from '@salesforce/apex/PincodeLookupService.getPincodeDetails';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class PincodeLookup extends LightningElement {
    @track pincode = '';
    @track pincodeDetails;
    @track errorMessage;
    @track isLoading = false;

    handlePincodeChange(event) {
        this.pincode = event.target.value;
        // Clear previous results and errors when pincode changes
        this.pincodeDetails = undefined;
        this.errorMessage = undefined;
    }

    async handleSearch() {
        // Basic validation before calling Apex
        if (!this.pincode || this.pincode.length !== 6 || !/^\d{6}$/.test(this.pincode)) {
            this.errorMessage = 'Please enter a valid 6-digit numeric pincode.';
            this.pincodeDetails = undefined;
            return;
        }

        this.isLoading = true;
        this.errorMessage = undefined;
        this.pincodeDetails = undefined;

        try {
            const result = await getPincodeDetails({ pincode: this.pincode });

            if (result.Status === 'Success') {
                this.pincodeDetails = result;
                this.showToast('Success', 'Pincode details fetched successfully!', 'success');
            } else {
                this.errorMessage = result.Message || 'Failed to fetch pincode details.';
                this.showToast('Error', this.errorMessage, 'error');
            }
        } catch (error) {
            this.errorMessage = 'An error occurred while fetching data: ' + error.body.message;
            this.showToast('Error', this.errorMessage, 'error');
            console.error('Error fetching pincode details:', error);
        } finally {
            this.isLoading = false;
        }
    }

        // New handler for the Clear button
        handleClear() {
            this.pincode = '';             // Clear the input field
            this.pincodeDetails = undefined; // Clear the displayed results
            this.errorMessage = undefined;   // Clear any error messages
            this.isLoading = false;          // Ensure loading state is off
            const inputField = this.template.querySelector('lightning-input');
            if (inputField) {
                inputField.value = ''; // Ensure the actual input element is cleared if the @track doesn't force it immediately
            }
            this.showToast('Cleared', 'Input and results have been cleared.', 'info');
        }
        
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(event);
    }
}