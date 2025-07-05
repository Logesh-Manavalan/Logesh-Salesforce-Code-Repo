import { LightningElement, api } from 'lwc';

export default class ChildOpportunity extends LightningElement {
    @api formData;
    
    stageOptions = [
        { label: 'Prospecting', value: 'Prospecting' },
        { label: 'Qualification', value: 'Qualification' },
        { label: 'Needs Analysis', value: 'Needs Analysis' },
        { label: 'Value Proposition', value: 'Value Proposition' },
        { label: 'Closed Won', value: 'Closed Won' },
        { label: 'Closed Lost', value: 'Closed Lost' }
    ];

    handleChange(event) {
        const field = event.target.dataset.field;
        const value = event.target.value;

        this.dispatchEvent(new CustomEvent('oppdatachange', {
            detail: { field, value }
        }));
    }
}