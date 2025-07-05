import { LightningElement, api } from 'lwc';

export default class ChildContact extends LightningElement {
    @api formData;

    handleChange(event) {
        const field = event.target.dataset.field;
        const value = event.target.value;
        
        this.dispatchEvent(new CustomEvent('datachange', {
            detail: { field, value }
        }));
    }
}