public class CaseCreationWrapper{
    public CaseCreationValuesWrapper accountDivisionProps = new CaseCreationValuesWrapper('account_division',32,true);
    public CaseCreationValuesWrapper accountNameProps = new CaseCreationValuesWrapper('account_name',80,true);
    public CaseCreationValuesWrapper caseNumberProps = new CaseCreationValuesWrapper('case_number',100,false);
    public CaseCreationValuesWrapper cityProps = new CaseCreationValuesWrapper('city',40,false);
    public CaseCreationValuesWrapper contactEmailProps = new CaseCreationValuesWrapper('contact_email',100,false);
    public CaseCreationValuesWrapper contactNameProps = new CaseCreationValuesWrapper('contact_name',151,false);
    public CaseCreationValuesWrapper contactPhoneProps = new CaseCreationValuesWrapper('contact_phone',40,false);
    public CaseCreationValuesWrapper countryProps = new CaseCreationValuesWrapper('country',40,true);
    public CaseCreationValuesWrapper descriptionProps = new CaseCreationValuesWrapper('description',4000,true);
    public CaseCreationValuesWrapper postalCodeProps = new CaseCreationValuesWrapper('postal_code',40,false);
    public CaseCreationValuesWrapper stateProps = new CaseCreationValuesWrapper('state',40,true);
    public CaseCreationValuesWrapper streetProps = new CaseCreationValuesWrapper('street',255,false);
    public CaseCreationValuesWrapper subcategoryProps = new CaseCreationValuesWrapper('subcategory',40,true);
    public CaseCreationValuesWrapper subjectProps = new CaseCreationValuesWrapper('subject',160,true);
     
    public class CaseCreationValuesWrapper{
        public String fieldName{get;set;}
        public Integer maxLength{get;set;}
        public Boolean isTrim{get;set;}
        public CaseCreationValuesWrapper(String field,Integer maxLength,Boolean isTrim){
            this.fieldName = field;
            this.maxLength = maxLength;
            this.isTrim = isTrim;
        }
    }
}