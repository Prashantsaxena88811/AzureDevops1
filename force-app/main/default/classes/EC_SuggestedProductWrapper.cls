/* Class Name    : EC_SuggestedProductWrapper
 * Description      :Wrapper Class for EC_SuggestedProducts
 * Created By       :Ashish
 * Created On       :2019-Jun-26
 

 * Modification Log:
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date            Modification ID         Description
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------
 * Ashish            2019-Jun-26         BC-74097        Created the class   
 *
 */
global class EC_SuggestedProductWrapper {    
    public string sku {get; set;}
    public Decimal quantity {get; set;} 
    public Decimal price {get; set;}
}