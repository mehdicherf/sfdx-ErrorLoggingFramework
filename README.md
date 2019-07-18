# sfdx-ErrorLoggingFramework


A basic error logging framework for Apex, derived from https://github.com/rsoesemann/apex-unified-logging


The purpose of this version is to store the logs into a custom object (so that it can be persisted longer that a platform event).


To add this error logging framework to your sfdx project, you can clone this repo and then push it to your scratch org by executing the command `sfdx force:source:deploy -p <path/to/the/repo>`,followed by `sfdx force:source:retrieve -x  <path/to/the/repo/package.xml>`
 to retrieve the metadata in your sfdx project folder.


## Example Use:

### To log all errors of a bulk DML operation:
```apex
// Create two accounts, one of which is missing a required field
Account[] accountList = new List<Account>{
    new Account(Name='Account1'),
    new Account()};
Database.SaveResult[] srList = Database.insert(accountList, false);

// Log errors
Log.error(srList);
```

### When Using a try-catch block:
```apex
try{
    //try something complex
}catch (exception pokemon){
    // Log error
    Log.error(pokemon.getMessage())
}
```

### To log a single error:
```apex
try{
    Update myRecord;
}catch (exception pokemon){
    // Log error
    Log.error(pokemon.getMessage(), myRecord.Id)
}
```



## Log Public Methods:
```apex
/**
* @description: Logs a simple error. Result in a Log__c record being inserted, so do not call it in a Loop!
* @params: message (short description of the error)
* @return: void
*/
public static void error(String message) {
	error(message, new List<Object>(), null);
}
/**
* @description: Logs an error with a list of associated information. Result in a Log__c record being inserted, so do notcall it in a Loop!
* @params: message (short description of the error)
* @params: values (list of objects containing additional information about the error)
* @return: void
*/
public static void error(String message, List<Object> values) {
	error(message, values, null);
}
/**
* @description: Logs an error associated to a record or job ID. Result in a Log__c record being inserted, so do not call itin a Loop!
* @params: message (short description of the error)
* @params: contextId (ID of the associated record or job)
* @return: void
*/
public static void error(String message, Id contextId) {
	error(message, new List<Object>(), contextId);
}
/**
* @description: Logs an error associated to a record or job ID, with a list of associated information. Result in a Log__crecord being inserted, so do not call it in a Loop!
* @params: message (short description of the error)
* @params: values (list of objects containing additional information about the error)
* @params: contextId (ID of the associated record or job)
* @return: void
*/
public static void error(String message, List<Object> values, Id contextId) {
	Log__c newLog = newLog(message, values, contextId);
	insertLogs(new List<Log__c>{newLog});
}
/**
* @description: Logs all errors associated with a database.insert or database.udpate DML operation
* @params: srList (List<Database.SaveResult> returned by database.insert or database.udpate)
* @return: void
*/
public static void error(List<Database.SaveResult> srList) {
	List<Log__c> logList = new List<Log__c>();
	for (Database.SaveResult sr : srList) {
		if (!sr.isSuccess()) {
			Log__c newLog =newLog('Database.SaveResult error', sr.getErrors(), sr.getId());
			logList.add(newLog);
		}
	}
	insertLogs(logList);
}
/**
* @description: Logs all errors associated with a database.upsert DML operation
* @params: urList (List<Database.UpsertResult> returned by database.upsert)
* @return: void
*/
public static void error(List<Database.UpsertResult> urList) {
	List<Log__c> logList = new List<Log__c>();
	for (Database.UpsertResult ur : urList) {
		if (!ur.isSuccess()) {
			Log__c newLog =newLog('Database.UpsertResult error; isCreated: '+ur.isCreated(), ur.getErrors(), ur.getId());
			logList.add(newLog);
		}
	}
	insertLogs(logList);
}
/**
* @description: Logs all errors associated with a database.delete DML operation
* @params: drList (List<Database.DeleteResult> returned by database.delete)
* @return: void
*/
public static void error(List<Database.DeleteResult> drList) {
	List<Log__c> logList = new List<Log__c>();
	for (Database.DeleteResult dr : drList) {
		if (!dr.isSuccess()) {
			Log__c newLog =newLog('Database.DeleteResult error', dr.getErrors(), dr.getId());
			logList.add(newLog);
		}
	}
	insertLogs(logList);
}
```


