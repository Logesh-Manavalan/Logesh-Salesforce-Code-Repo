import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createRecords from '@salesforce/apex/ParentAccountController.createRecords';
import { NavigationMixin } from 'lightning/navigation';

const dependencyMap = {
        'account.name': ['contact.lastName', 'opportunity.name'],
        'account.email': ['contact.email', 'opportunity.email'],
        'account.phone': ['contact.phone', 'opportunity.phone'],
        'contact.email': ['account.email', 'opportunity.email'],
        'contact.phone': ['account.phone', 'opportunity.phone'],
        'opportunity.email': ['account.email', 'contact.email'],
        'opportunity.phone': ['account.phone', 'contact.phone'],
        'account.rating': ['opportunity.amount']
    };
    
export default class ParentAccount extends NavigationMixin(LightningElement) {
    
     @track formData = this.getEmptyFormData();

     getEmptyFormData() {
        return {
            account: {
                name: '',
                email: '',
                phone: '',
                industry: '',
                rating: ''
            },
            contact: {
                firstName: '',
                lastName: '',
                email: '',
                phone: '',
                title: ''
            },
            opportunity: {
                name: '',
                stageName: 'Prospecting',
                closeDate: new Date().toISOString().split('T')[0],
                amount: 0,
                email: '',
                phone: ''
            }
        };
    }

    handleChange(event) {
        const field = event.target.dataset.field;
        const value = event.target.value;
        this.updateFormData(field, value);
    }

    handleDataChange(event) {
        const { field, value } = event.detail;
        this.updateFormData(field, value);
    }

    updateFormData(field, value) {
        let newFormData = JSON.parse(JSON.stringify(this.formData));
        
        const path = field.split('.');
        let current = newFormData;
        
        for (let i = 0; i < path.length - 1; i++) {
            current = current[path[i]];
        }
        current[path[path.length - 1]] = value;

        if (dependencyMap[field]) {
            dependencyMap[field].forEach(depField => {
                let depPath = depField.split('.');
                let depTarget = newFormData;
                for (let i = 0; i < depPath.length - 1; i++) {
                    depTarget = depTarget[depPath[i]];
                }

                if (field === 'account.rating' && depField === 'opportunity.amount') {
                    depTarget[depPath[depPath.length - 1]] = value * 100;
                } else if (field === 'account.name' && depField === 'opportunity.name') {
                    depTarget[depPath[depPath.length - 1]] = `Opportunity for ${value}`;
                } else {
                    depTarget[depPath[depPath.length - 1]] = value;
                }
            });
        }

        this.formData = newFormData;
    
    }

    handleSave() {
        const recordData = {
            accountName: this.formData.account.name,
            accountEmail: this.formData.account.email,
            accountPhone: this.formData.account.phone,
            accountIndustry: this.formData.account.industry,
            accountRating: this.formData.account.rating,
            
            contactFirstName: this.formData.contact.firstName,
            contactLastName: this.formData.contact.lastName,
            contactEmail: this.formData.contact.email,
            contactPhone: this.formData.contact.phone,
            contactTitle: this.formData.contact.title,
            
            opportunityName: this.formData.opportunity.name,
            opportunityStage: this.formData.opportunity.stageName,
            opportunityCloseDate: this.formData.opportunity.closeDate,
            opportunityAmount: this.formData.opportunity.amount,
            opportunityEmail: this.formData.opportunity.email,
            opportunityPhone: this.formData.opportunity.phone
        };
        console.log('Record Data:', recordData);
        createRecords({  wrapper: recordData })
            .then((data) => {
                console.log('Apex Response:', data);
                if (!data) {
                    this.showToast('Error', 'No account ID returned from Apex', 'error');
                    return;
                }
                this.formData = this.getEmptyFormData();
                this.showToast('Success', 'Records created successfully', 'success');
                this.navigateToAccount(data);
            })
            .catch(error => {
                this.showToast('Error', error?.body?.message || 'Unknown error', 'error');
            });
    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title,
                message,
                variant
            })
        );
    }

    navigateToAccount(accountId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: accountId,
                objectApiName: 'Account',
                actionName: 'view'
            }
        });
    }
}