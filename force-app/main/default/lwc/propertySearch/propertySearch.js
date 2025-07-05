import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import searchProperties from '@salesforce/apex/PropertySearchController.searchProperties';
import saveProperties from '@salesforce/apex/PropertySearchController.saveProperties';

const columns = [
    { label: 'Address', fieldName: 'address', type: 'text' },
    { label: 'City', fieldName: 'city', type: 'text' },
    { label: 'State', fieldName: 'state', type: 'text' },
    { label: 'Zip', fieldName: 'zip', type: 'text' },
    { label: 'Property Type', fieldName: 'propertyType', type: 'text' },
    { label: 'Year Built', fieldName: 'yearBuilt', type: 'number' },
    { label: 'Square Feet', fieldName: 'squareFeet', type: 'number' },
    { label: 'Estimated Value', fieldName: 'estimatedValue', type: 'currency' }
];

export default class PropertySearch extends LightningElement {
    @track properties = {};
    @track isLoading = false;
    @track error;
    @track selectedProperties = [];
    
    @track street = '';
    @track city = '';
    @track state = '';
    @track zip = '';
    @track payload = '';
    
    columns = columns;
    
    handleSearchTermChange(event) {
        const field = event.target.name;
        this[field] = event.target.value;    
    }
    
    async handleSearch() {
        if (!this.zip) {
            this.error = 'Please enter a zip code to search for properties';
            return;
        }
        
        this.isLoading = true;
        this.error = undefined;
        
        try {
            const wrapperData = {
                searchCriteria: {
                    query: `${this.city}, ${this.state}`,
                    compAddress: {
                        street: this.street,
                        city: this.city,
                        state: this.state,
                        zip: this.zip
                        }
                    }
                };

            const result = await searchProperties({ wrapperData });
            this.properties = result;
            
            if (!this.properties || !this.properties.data || this.properties.data.length === 0) {
                this.error = 'No properties found for the given search criteria';
                return;
            }

            this.selectedProperties = this.properties.data.map(property => {
                return { ...property, selected: false };
            });
           
        } catch (error) {
            this.error = error.body?.message || 'An error occurred while searching properties';
        } finally {
            this.isLoading = false;
        }
    }
    
    handleRowSelection(event) {
        const selectedRows = event.detail.selectedRows;
        this.selectedProperties = selectedRows;
    }
    
    async handleSave() {
        if (!this.selectedProperties.length) {
            this.error = 'Please select at least one property to save';
            return;
        }
        
        this.isLoading = true;
        
        try {
            const result = await saveProperties({ properties: this.selectedProperties });
            
            if (!result || result.length === 0) {
                this.error = 'An error occurred while saving properties. Please try again later.';
                return;
            }

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: `${result.length} property(s) saved successfully`,
                    variant: 'success'
                })
            );
            
            this.selectedProperties = [];
        } catch (error) {
            this.error = error.body?.message || 'An error occurred while saving properties';
        } finally {
            this.isLoading = false;
        }
    }
}