import { LightningElement, wire, track } from 'lwc';
import getAccounts from '@salesforce/apex/AccountInfoController.getAccounts';
import getRelatedInfo from '@salesforce/apex/AccountInfoController.getRelatedInfo';

// Define columns for the datatables
const CONTACT_COLUMNS = [
    { label: 'Name', fieldName: 'Name', type: 'text' },
    { label: 'Email', fieldName: 'Email', type: 'email' },
    { label: 'Phone', fieldName: 'Phone', type: 'phone' },
];

const OPPORTUNITY_COLUMNS = [
    { label: 'Name', fieldName: 'Name', type: 'text' },
    { label: 'Stage', fieldName: 'StageName', type: 'text' },
    { label: 'Amount', fieldName: 'Amount', type: 'currency', typeAttributes: { currencyCode: 'USD' } },
    { label: 'Close Date', fieldName: 'CloseDate', type: 'date' },
];

export default class AccountDetailViewer extends LightningElement {
    @track accountOptions = [];
    @track selectedAccountId = '';
    @track account;
    @track contacts = [];
    @track opportunities = [];
    @track isLoading = false;

    // Columns for datatables
    contactColumns = CONTACT_COLUMNS;
    opportunityColumns = OPPORTUNITY_COLUMNS;

    // Wire service to get the list of accounts for the combobox
    @wire(getAccounts)
    wiredAccounts({ error, data }) {
        if (data) {
            this.accountOptions = data.map(acc => ({
                label: acc.Name,
                value: acc.Id
            }));
        } else if (error) {
            console.error('Error fetching accounts:', error);
        }
    }

    // Wire service to get related info based on the selected account ID
    @wire(getRelatedInfo, { accountId: '$selectedAccountId' })
    wiredRelatedInfo({ error, data }) {
        this.isLoading = false;
        if (data) {
            this.account = data;
            // Use empty array as default to prevent errors if no related records exist
            this.contacts = data.Contacts ? data.Contacts : [];
            this.opportunities = data.Opportunities ? data.Opportunities : [];
        } else if (error) {
            console.error('Error fetching related info:', error);
            this.account = null;
            this.contacts = [];
            this.opportunities = [];
        }
    }

    // Event handler for when a user selects an account
    handleAccountChange(event) {
        this.selectedAccountId = event.detail.value;
        if (this.selectedAccountId) {
            this.isLoading = true;
        } else {
            // Clear data if the selection is cleared
            this.account = null;
            this.contacts = [];
            this.opportunities = [];
        }
    }

    // Getters for validating if data exists to show in the template
    get hasContacts() {
        return this.contacts && this.contacts.length > 0;
    }

    get hasOpportunities() {
        return this.opportunities && this.opportunities.length > 0;
    }
}