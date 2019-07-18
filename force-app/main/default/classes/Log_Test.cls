@IsTest
private class Log_Test {

	@IsTest
	private static void singleErrorTest() {
			Test.startTest();
			Account[] acctsFail = new List<Account>{new Account()};
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

	@IsTest
	private static void bulkInsertErrorTest() {
			Test.startTest();
			Account[] acctsFail = new List<Account>{new Account()};
			Database.SaveResult[] srList = Database.insert(acctsFail, false);
			Log.error(srList); //1 log record
			Test.stopTest();
			//Verify
			List<Log__c> errorLogs = [SELECT Id FROM Log__c];		
			System.assertEquals(1, errorLogs.size(), 'No Log created');
	}

	@IsTest
	private static void bulkUpsertErrorTest() {
			Test.startTest();
			Account[] acctsFail = new List<Account>{new Account()};
			Database.UpsertResult[] urList = Database.upsert(acctsFail, false);
			Log.error(urList); //1 log record
			Test.stopTest();
			//Verify
			List<Log__c> errorLogs = [SELECT Id FROM Log__c];		
			System.assertEquals(1, errorLogs.size(), 'No Log created');
	}

	@IsTest
	private static void bulkDeleteErrorTest() {
			Test.startTest();
			Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId());
			Database.DeleteResult[] drList = Database.delete(new List<Pricebook2>{standardPricebook}, false);
			Log.error(drList); //1 log record
			Test.stopTest();
			//Verify
			List<Log__c> errorLogs = [SELECT Id FROM Log__c];		
			System.assertEquals(1, errorLogs.size(), 'No Log created');
	}



}