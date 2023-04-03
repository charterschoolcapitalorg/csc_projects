@isTest
public class TestDiligenceUtils {
    private static Profile PORTAL_PROFILE = [ SELECT Id FROM Profile WHERE Name = 'Partner Community User School/Tenant' ];

    private static Integer idSequence = 1;
 
 static boolean openingCallExists;
 
 static {
    try {
        intake_item_Template__c item = [Select Id from intake_item_Template__c where Name=:DiligenceVars.OpeningCallName LIMIT 1];
        openingCallExists = true;
    } catch (EXception e) { openingCallExists = false;}
        
 }
 
    public static void createCOnfig() {
        
        BoxCredentials__c bc = new BoxCredentials__c(Access_Token__c='1',Box_CSC_Group_Name__c='test',Box_User_ID__c='1', Client_Id__c='1', Client_Secret__c='1', Refresh_Token__c='1', SF_Box_Group_Name__c='test');
        insert bc;
        BoxFolderIds__c bf = new BoxFolderIds__c(Account_Root_Folder__c='test', Opportunity_Root_Folder__c='test', Root_Folder_Name__c='test');
        insert bf;
        Intake_Settings__c is = new Intake_Settings__c(Lead_Exception_Status__c='Open');
        insert is;
        createStates();
        
        InitialStageName__c oppStageNames = new InitialStageName__c(
              Name = 'Standard',
              Facilities__c = 'Stage 01 - Prospect',
              FOF__c = 'Stage 1 - Projected',
              Initial_Funding__c = 'Stage 1 - Prospect'
            );
            insert oppStageNames;
        //DiligenceRoleMap__mdt dm = new DiligenceRoleMap__mdt(Box_Folder_Name__c='test',Profile_Name__c='System Administrator',Role__c='School');
        //insert dm;
    }
 public static void createCustomSettings() {
    BoxFolderIds__c i = new BoxFolderIds__c(name = 'blah', Account_Root_Folder__c = '123', 
        Opportunity_Root_Folder__c = '234', Root_Folder_Name__c = 'test');
    insert i;
    
    BoxCredentials__c c = new BoxCredentials__c(name = 'asd', Box_CSC_Group_Name__c = '123', Box_User_ID__c = '123',
        Client_Id__c = '123', Client_Secret__c = '123', Refresh_Token__c = '123');
        insert c;
 }
 
 
 public static Intake_Item_Template__c createBaseIntakeTemplates(integer ordernum, Id parentId) {
    String nameSUffix = '';
    Intake_Item_Template__c i = new Intake_Item_Template__c();
    i.default__c = true;
     i.active__c = true;
    i.RecordTypeId = RecordTypes.IDInitialFundingIntake;
    if (parentId!=null) { i.Parent_Intake_Item_Template_del__c = parentId;nameSuffix = 'child';}
    //create unique intake item names
    if (ordernum==3) {
        if (!openingCallExists) {
            i.Name = DiligenceVars.OpeningCallName + nameSUffix;
            i.is_opening_call__c = true;
        } else {
            i.Name = DiligenceVars.OpeningCallName + nameSUffix;
            i.is_opening_call__c = true;
            //i.Name = 'test'+ordernum + nameSUffix;
        } 
    } else {
        i.Name = 'test'+ordernum + nameSUffix;
    }
    
    i.visible_to__c = 'CSC;School;';
    i.X14_day_Due_Date_Lag__c = 1;
    i.X30_day_Due_Date_Lag__c = 2;
    
    if (ordernum==0) {
        i.action_url__c = 'Custom Form';
        i.assigned_to__c = 'School';
        i.name = 'Pre Qual';
    } else if (ordernum==1) {
        i.action_url__c = 'Custom Form';
        i.assigned_to__c = 'School';
        i.name = 'Information Sheet';
    } else if (ordernum==2) {
        i.action_url__c = 'See Instructions';
        i.assigned_to__c = 'Seller';
    } else if (ordernum==3) {
        i.action_url__c = 'Custom Form';
       i.assigned_to__c = 'School';
    } else if (ordernum==4) {
        i.action_url__c = 'Edit Item Details';
        i.assigned_to__c = 'CSC';
    } else {
        i.action_url__c = 'Document Upload';
        i.document_name__c = 'test';
        i.is_document__c = true;
        i.assigned_to__c = 'School';
    }
    
    i.due_date_lag__c = 2;
    i.processing_order__c = ordernum;
    if (ordernum == 0) { i.is_pre_qual__c = true; }
    i.Stop_Number__c = ordernum;
    return i;
 }
 public static void createFUndingIntakeTemplates() {
    List<Intake_Item_Template__c> ii = new List<Intake_Item_Template__c>();
    Integer v = 0;
    while (v<7) {
        ii.add(createBaseIntakeTemplates(v, null));
        v++;
    }
    insert ii;
    
    //create child items
    List<Intake_Item_Template__c> ii2 = new List<Intake_Item_Template__c>();
     v = 0;
    while (v<7) {
        Intake_Item_Template__c i = createBaseIntakeTemplates(v,ii[0].Id);
        ii2.add(i);
        v++;
    }
    insert ii2;
 }
 public static void createFacilitiesIntakeTemplates() {
    List<Intake_Item_Template__c> ii = new List<Intake_Item_Template__c>();
    Integer v = 0;
    while (v<7) {
        Intake_Item_Template__c i = createBaseIntakeTemplates(v, null);
        i.RecordTypeId = RecordTypes.IDFacilitiesIntake;
        i.Update_AL__c = true;
        i.Update_PCL__c = true;
        i.Copy_Files_to_AL_PCL__c = true;
        i.Action_Item_Mapping__c = 'Academic Calendar';
        i.Facilities_Client_Type__c = 'Seller';
        ii.add(i);
        v++;
    }
    insert ii;
    
    //create child items
    List<Intake_Item_Template__c> ii2 = new List<Intake_Item_Template__c>();
     v = 0;
    while (v<1) {
        Intake_Item_Template__c i = createBaseIntakeTemplates(v,ii[0].Id);
        ii2.add(i);
        v++;
    }
    insert ii2;
 }  
 public static State_Province__c getState(String abbrev, String name) {
    return new State_Province__c(
        Name = abbrev,
        state_name__c = name
    );
 }
 public static void createStates() {
    insert new List<State_Province__c> {
        getState('GA', 'Georgia'),
        getState('AK', 'Alaska')
    };
 }
 public static Lead createLead() {
    
    LEad l = new LEad();
    l.firstname = 't';
    l.lastname = 't';
    l.email = 't@t.com';
    l.phone = '1231231234';
    l.company = 'COmpanyt';
    l.LeadSource = 'Form';
    l.Lead_Type__c = 'Business'; 
    l.Industry = 'Architect';
    l.Funding_Need__c = 'Growth Capital';
    State_Province__c s = [Select Id from State_Province__c where Name = 'GA' limit 1];
    l.Operating_State__c = s.Id;
    return l;
 }   
 
 public static Lead createIFLead() {
    LEad l = createLEad();
    l.Opportunity_Type__c = 'Initial Funding';
    l.RecordTypeId = RecordTypes.IDGeneralLead;
    l.Close_Date__c = Date.today();
    l.Amount_Requested__c = 0;
    return l;
 }
 public static Lead createFacLead() {
    LEad l = createLEad();
    l.RecordTypeId = RecordTypes.IDFacilitiesLead;
    // l.Facilities_Client_Type__c = 'Seller';
    l.Opportunity_Type__c = 'Facilities';
    l.Close_Date__c = Date.today();
    l.Deal_Structure__c = 'New Development';
    return l;
 }     

    public static Account getCMO() {
        return new Account(
            Name = 'Test CMO',
            RecordTypeId = RecordTypes.IDBusAccount
        );
    }

    public static Account getCharterHolder(Account cmoAcct) {
        Account charterHolderAcct = getCharterHolder();
        charterHolderAcct.CMO__c = cmoAcct.Id;
        charterHolderAcct.ParentId = cmoAcct.Id;
        return charterHolderAcct;
    }

    public static Account getCharterHolder() {
        return new Account(
            Name = 'Test Charter Holder',
            RecordTypeId = RecordTypes.IDCharterAccount
        );
    }

    public static Account getSchool(Account charterHolderAcct) {
        return new Account(
            Name = 'Test School',
            RecordTypeId = RecordTypes.IDSchoolAccount,
            ParentId = charterHolderAcct.Id,
            Charter_Holder__c = charterHolderAcct.Id
        );
    }

    public static Contact getContact(Account acct) {
        return new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            Email = 'test.contact+csc.unit.test.'+acct.Id+'@example.com',
            AccountId = acct.Id
        );
    }

    public static Community_Contact_Role__c getCCR(Contact con, Account acc) {
        return new Community_Contact_Role__c(
            Contact__c = con.Id,
            Account__c = acc.Id,
            Role__c = 'School'
        );
    }

    public static Community_Contact_Role__c getCCR(Contact con, Opportunity opp) {
        return new Community_Contact_Role__c(
            Contact__c = con.Id,
            Opportunity__c = opp.Id,
            Role__c = 'School'
        );
    }

    public static User getUser(Contact con, Boolean doInsert) {
        User u = new User(
            FirstName = con.FirstName,
            LastName = con.LastName,
            Alias = 'test1',
            Email = con.Email,
            Username = con.Email,
            ContactId = con.Id,
            LanguageLocaleKey = 'en_US',
            TimeZoneSidKey = 'America/New_York',
            EmailEncodingKey = 'ISO-8859-1',
            LocaleSidKey = 'en_CA',
            IsActive = true,
            ProfileId = PORTAL_PROFILE.Id
        );
        if (doInsert) {
            insertUser(u);
        }
        return u;
    }

    public static User insertUser(User u) {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert u;
        }
        return u;
    }

    public static Intake_Item__c getDiligenceItem(Opportunity opp, Intake_Item__c parent) {
        Intake_Item__c item = getDiligenceItem(opp);
        item.Parent_Intake_Item__c = parent.Id;
        return item;
    }

    public static Intake_Item__c getDiligenceItem(Opportunity opp) {
        return new Intake_Item__c(
            Opportunity__c = opp.Id,
            Status__c = 'Pending',
            Is_Visible_To_Community__c = true,
            RecordTypeId = RecordTypes.IDInitialFundingIntakeItem,
            Action_Item_Mapping__c = 'Budget',
            Assigned_To__c = 'School',
            Visible_To__c = 'School',
            Client_Comments__c = 'Test Client Comment',
            Due_Date__c = Date.today(),
            Update_Lease_Compliance__c = true,
            Update_AL__c = true,
            Update_PCL__c = true
        );
    }

    public static Intake_Item_Template__c getDiligenceTemplate() {
        return new Intake_Item_Template__c(
            Visible_At_Creation__c = true,
            RecordTypeId = RecordTypes.IDInitialFundingIntakeItem,
            Action_Item_Mapping__c = 'Budget',
            Assigned_To__c = 'School',
            Visible_To__c = 'School',
            Update_Lease_Compliance__c = true,
            Update_AL__c = true,
            Update_PCL__c = true
        );
    }

    public static Intake_Item_Template__c getDiligenceTemplate(Intake_Item_Template__c parent) {
        Intake_Item_Template__c item = getDiligenceTemplate();
        item.Parent_Intake_Item_Template_del__c = parent.Id;
        return item;
    }

    public static Intake_Item__c getOngoingDiligenceItem(Account acct) {
        return new Intake_Item__c(
            Account_Name__c = acct.Id,
            Status__c = 'Pending',
            Is_Visible_To_Community__c = true,
            RecordTypeId = RecordTypes.IDOngoingIntakeItem,
            Action_Item_Mapping__c = 'Budget',
            Assigned_To__c = 'School',
            Visible_To__c = 'School',
            Client_Comments__c = 'Test Client Comment',
            Due_Date__c = Date.today(),
            Update_Lease_Compliance__c = true,
            Update_AL__c = true,
            Update_PCL__c = true
        );
    }

    public static Intake_Item__c getOngoingDiligenceItem(Account acc, Intake_Item__c parent) {
        Intake_Item__c item = getOngoingDiligenceItem(acc);
        item.Parent_Intake_Item__c = parent.Id;
        return item;
    }

    public static Intake_Item_Template__c getOngoingDiligenceTemplate() {
        return new Intake_Item_Template__c(
            Visible_At_Creation__c = true,
            RecordTypeId = RecordTypes.IDOngoingIntake,
            Action_Item_Mapping__c = 'Budget',
            Assigned_To__c = 'School',
            Visible_To__c = 'School',
            Update_Lease_Compliance__c = true,
            Update_AL__c = true,
            Update_PCL__c = true
        );
    }

    public static Intake_Item_Template__c getOngoingDiligenceTemplate(Intake_Item_Template__c parent) {
        Intake_Item_Template__c item = getOngoingDiligenceTemplate();
        item.Parent_Intake_Item_Template_del__c = parent.Id;
        return item;
    }

    public static CSC_Action_List__c getActionList(Account acct) {
        return new CSC_Action_List__c(
            Action_List_Name__c = 'Test Action List',
            Library_Type__c = 'Finance',
            Account__c = acct.Id
        );
    }

    public static CSC_Action_Item__c getActionItem(CSC_Action_List__c actionList) {
        return new CSC_Action_Item__c(
            Action_Item_Name__c = 'Test Action Item',
            Action_Item_Mapping__c = 'Budget',
            Status__c = 'New',
            CSC_Action_List__c = actionList.Id
        );
    }

    public static ContentVersion getFile(SObject parent) {
        return new ContentVersion(
            Title = 'Test File Name',
            PathOnClient = '/TestFileName.png',
            FirstPublishLocationId = parent.Id,
            VersionData = Blob.valueOf('Test'),
            IsMajorVersion = true
        );
    }

    public static Account getProperty() {
        return new Account(
            Name = 'Test Property',
            RecordTypeId = RecordTypes.IDPropAccount,
            Nick_Name__c = 'LISA' //add nick name to property
        );
    }

    public static Lease__c getLease(Account prop) {
        return new Lease__c(
            Property__c = prop.Id,
            RecordTypeId = SObjectType.Lease__c.getRecordTypeInfosByDeveloperName().get('School_Leases').getRecordTypeId()
        );
    }

    public static Lease_School__c getLeaseSchool(Lease__c lease, Account school) {
        return new Lease_School__c(
            Lease__c = lease.Id,
            Account_School__c = school.Id
        );
    }

    public static Lease_Compliance__c getLeaseCompliance(Lease__c lease) {
        return new Lease_Compliance__c(
            Lease__c = lease.Id,
            Due_Days__c = 2,
            Client_Alert_Days__c = 2,
            Expire_Days__c = 2,
            FAM_Alert_Days__c = 2,
            Period__c = 'Monthly',
            Type__c = 'Budget',
            Action_Item_Mapping__c = 'Budget',
            RecordTypeId = SObjectType.Lease_Compliance__c.getRecordTypeInfosByDeveloperName().get('Pending').getRecordTypeId()
        );
    }

    public static Lease_Compliance_Template__c getLeaseComplianceTemplate() {
        return new Lease_Compliance_Template__c(
            Due_Days__c = 2,
            Client_Alert_Days__c = 2,
            Expire_Days__c = 2,
            FAM_Alert_Days__c = 2,
            Period__c = 'Monthly',
            Type__c = 'Budget',
            Action_Item_Mapping__c = 'Budget'
        );
    }

    public static Opportunity getOpportunity(Account acct) {
        return new Opportunity(
            Name = 'Test Opp',
            StageName = 'Stage 1 - Qualification',
            AccountId = acct.Id,
            CloseDate = Date.today(),
            RecordTypeId = RecordTypes.IDFundingOpp
        );
    }

    public static String getFakeId(Schema.DescribeSObjectResult type) {
        String result = String.valueOf(idSequence++);
        return Id.valueOf(type.getKeyPrefix() + '0'.repeat(12-result.length()) + result);
    }
}