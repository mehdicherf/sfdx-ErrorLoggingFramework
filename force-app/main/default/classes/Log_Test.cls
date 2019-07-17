@IsTest
private class Log_Test {

    @IsTest
    private static void errorTest() {

        Test.startTest();
        Account[] acctsFail = new List<Account>{new Account(Name='Account1'),new Account()};
        Database.SaveResult[] srList = Database.insert(acctsFail, false);
        Log.error('test error'); //1 log record
        Log.error('test error Id', acctsFail[0].Id); //1 additional log record
        Log.error('test error List', srList); //1 log record
        Log.error('test error List and Id', srList, acctsFail[0].Id); //1 additional log record
        Test.stopTest();

        //Verify
        List<Log__c> errorLogs = [SELECT Id FROM Log__c];    
        System.assertEquals(4, errorLogs.size(), 'No Log created');
    }


}