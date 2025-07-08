import { LightningElement, api, wire, track } from 'lwc';
import getContacts from '@salesforce/apex/AccountContactController.getContacts';

// Define the columns for the datatable
const COLUMNS = [
    { label: 'Name', fieldName: 'Name', type: 'text' },
    { label: 'Title', fieldName: 'Title', type: 'text' },
    { label: 'Phone', fieldName: 'Phone', type: 'phone' },
    { label: 'Email', fieldName: 'Email', type: 'email' },
];
export default class ShowContactsRelToAccount extends LightningElement {

    @api recordId;

    @track contacts;
    @track error;

    columns = COLUMNS;
   @track cardTitle = 'Related Contacts for account';
    // Show the datatable when the component is rendered';

    // Use the @wire adapter to call the Apex method imperatively.
    // The wire service automatically provides the data and error properties.
    @wire(getContacts, { accountId: '$recordId' })
    wiredContacts({ error, data }) {
        if (data) {
            this.contacts = data;
            this.cardTitle = `Related Contacts for account ==> ${this.contacts[0].Account.Name}`;
            this.error = undefined;

        } else if (error) {
            this.error = error;
            this.contacts = undefined;
        }
    }

    // Getter to check if there are contacts to display
    get hasContacts() {
        return this.contacts && this.contacts.length > 0;
    }
}