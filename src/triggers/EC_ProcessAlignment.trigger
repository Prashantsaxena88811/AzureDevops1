/* Trigger Name     : EC_ProcessAlignment 
 * Description      : Trigger to process alignment records which are loading from informatica
 * Created By       : Venkatesh 
 * Created On       : 2020-Sep-12
 

 * Modification Log:
 * -------------------------------------------------------------------------------
 * Developer                Date            Modification ID         Description
 * ---------------------------------------------------------------------------------
 * Venkatesh             2020-Sep-12               V1             Created the class   
 *
 */

 trigger EC_ProcessAlignment on AccountContactRelation (after insert,before delete) {
	if (Trigger.isInsert && Trigger.isAfter) {
        //After trigger to process Insert Alignment
        EC_AccConHelper.alignmentInserHelper(Trigger.new);
    }
    if (Trigger.isDelete && Trigger.isBefore) {
        //Before trigger to process Delete Alignment
        EC_AccConHelper.alignmentDeleteHelper(Trigger.old);
    }
} 