# sfdx-ErrorLoggingFramework


A basic error logging framework for Apex, derived from https://github.com/rsoesemann/apex-unified-logging


The purpose of this version is to store the logs into a custom object (so that it can be persisted longer that a platform event).


To add the conten of this repo to your sfdx project, you can clone this repo and then push it to your scratch org by executing the command 'sfdx force:source:deploy -p <path/to/the/repo>',followed by 'sfdx force:source:retrieve -x  <path/to/the/repo/package.xml>'
 to retrieve the metadata in your sfdx project folder.


## Log Public Methods:
```apex
    /**
    * @description: Logs a simple error
    * @params: message (short description of the error)
    * @return: void
    */
    public static void error(String message) {
        error(message, new List<Object>(), null);
    }

    /**
    * @description: Logs an error with a list of associated information
    * @params: message (short description of the error)
    * @params: values (list of objects containing additional information about the error)
    * @return: void
    */
    public static void error(String message, List<Object> values) {
        error(message, values, null);
    }

    /**
    * @description: Logs an error associated to a record or job ID
    * @params: message (short description of the error)
    * @params: contextId (ID of the associated record or job)
    * @return: void
    */
    public static void error(String message, Id contextId) {
        error(message, new List<Object>(), contextId);
    }

    /**
    * @description: Logs an error associated to a record or job ID, with a list of associated information
    * @params: message (short description of the error)
    * @params: values (list of objects containing additional information about the error)
    * @params: contextId (ID of the associated record or job)
    * @return: void
    */
    public static void error(String message, List<Object> values, Id contextId) {
        insertLog(message, values, contextId);
    }
```

## Example Use:

### When Inserting records in Bulk:
```apex
// Create two accounts, one of which is missing a required field
Account[] accountList = new List<Account>{
    new Account(Name='Account1'),
    new Account()};
Database.SaveResult[] srList = Database.insert(accountList, false);

// Log errors
for (Database.SaveResult sr : srList) {
    if (!sr.isSuccess()) {
     Log.error('Account insert failed', sr.getErrors());
    }
}
```

### When Updating records in Bulk:
```apex
//Update a List of Account
Database.SaveResult[] srList = Database.update(accountList, false);

// Log errors
for (Database.SaveResult sr : srList) {
    if (!sr.isSuccess()) {
     Log.error('Account update failed', sr.getErrors(), sr.getId());
    }
}
```

### When Using a try-catch block:
```apex
try{
    //try something complex
}catch (exception pokemon){
    Log.error(pokemon.getMessage())
}
```

### When Using a try-catch block That can be related to a record or job ID:
```apex
try{
    Update myRecord;
}catch (exception pokemon){
    Log.error(pokemon.getMessage(), myRecord.Id)
}
```

