/* Class Name       :EC_PlatformCacheController 
 * Description      :This class is used cache static data
 * Created By       :Viraj
 * Created On       :19-Jun-2019
 
 * Modification Log:
 * ----------------------------------------------------------------------------------------------------------------
 * Developer                Date                            Description
 * ----------------------------------------------------------------------------------------------------------------
 * Viraj                 19-Jun-2019                      Created class
 */
public class EC_PlatformCacheController {
		
		private static User thisUser = [SELECT Id  FROM User WHERE Id = :UserInfo.getUserId()];
		
	    public static Object cacheData(String key,Object value) {
	    	
	    	String[] keySplit = key.split('\\.');
	    	if(Cache.Session.contains(keySplit[0]+'.'+keySplit[1]+'.'+thisUser.Id+keySplit[2])){
    			return Cache.Session.get(keySplit[0]+'.'+keySplit[1]+'.'+thisUser.id+keySplit[2]);
    		}else if(value!=null){
    			Cache.Session.put(keySplit[0]+'.'+keySplit[1]+'.'+thisUser.Id+keySplit[2],value);
    			return value;
    		}else{
    			return null;
    		}
    		
	    }
    
}