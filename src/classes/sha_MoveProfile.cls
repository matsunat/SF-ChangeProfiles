/*
 * 管理ツール
 * この機能はツールとして使用するものです。
 * 瑕疵・サポート対象には含まれません。 
 * 2016/12/16 新規作成　AGREX松永
 *
 */
global class sha_MoveProfile {

    @remoteAction	
    global static List<profile> getProfiles(){
        List<profile> lstP = new List<profile>();
        lstP = [select id,name,UserLicense.Name from profile Where UserLicense.Name IN ('Force.com - App Subscription','Salesforce Platform','Salesforce') order by UserLicenseId];
        return lstP;
    }
    public class userWrap{
        public User u;
        public boolean chk;
        public string userlink;
        public userWrap(){
            u = new User();
            chk = false;
            userlink='';
        }
    }
    @remoteAction
    public static List<userWrap> getUsers(string profileid){
        List<userWrap> lstU = new List<userWrap>();
        for(user u : [select id,Username,LastName,FirstName,UserRole.Name from User Where ProfileId = :profileid And IsActive = True order by UserRole.Name]){
            userWrap uw = new userWrap();
            uw.u = u;
            uw.userlink='/'+u.id+'?noredirect=1&isUserEntityOverride=1';
			lstU.Add(uw);            
        }		
        return lstU;
    }
 	@remoteAction
    public static string putUsers(string lstUpd,string profileid){
        string rslt = '';
    	list<userWrap> lstWUser = new list<userWrap>();
        list<user> lstUser = new list<user>();
        try{
            JSONParser parser = JSON.createParser(lstUpd);
            Schema.DescribeSObjectResult sr = User.sObjectType.getDescribe();
            //lstWUser = parser.readValueAs(userWrap.class);
            Map<id,User> mapUser = new Map<id,User>();
            boolean  chk = false;
            while (parser.nextToken() != null){
                userWrap uw = new userWrap();
                if(parser.getText()=='chk'){
                    parser.nextToken();
                    string val = parser.getText();
                    if(val.equals('true')){
                        chk = true;
                    }
                }else if(parser.getText().equals('Id')){
                    parser.nextToken();
                    if(sr.getKeyPrefix()==parser.getText().substring(0,3)){
                        if(chk && !mapUser.containsKey((id)parser.getText())){
                            mapUser.put((id)parser.getText(),new User(id = (id)parser.getText(),ProfileId = (id)profileid));
							chk=false;
                        }
                    }
                }
            }

            if(!mapUser.isEmpty()){
                 update mapUser.values(); 
            }
        }catch(exception ex){
            rslt = ex.getMessage() + ' Trace:'+ex.getStackTraceString();
        }	        
        return rslt;
    }
}