/**
Logging utility. Derived from https://github.com/rsoesemann/apex-unified-logging
**/
public with sharing class Log {

	private static final String ORG_NAMESPACE = [SELECT NamespacePrefix FROM Organization LIMIT 1].NamespacePrefix;
	private static final String CLASSNAME = Log.class.getName();
	private static final Pattern STACK_LINE = Pattern.compile('^(?:Class\\.)?([^.]+)\\.?([^\\.\\:]+)?[\\.\\:]?([^\\.\\:]*): line (\\d+), column (\\d+)$');
	private static final String DEFAULT_CONTEXT = timestamp();


	/**
	* @description: Logs a simple error. Result in a Log__c record being inserted, so do not call it in a Loop!
	* @params: message (short description of the error)
	* @return: void
	*/
	public static void error(String message) {
		error(message, new List<Object>(), null);
	}

	/**
	* @description: Logs an error with a list of associated information. Result in a Log__c record being inserted, so do not call it in a Loop!
	* @params: message (short description of the error)
	* @params: values (list of objects containing additional information about the error)
	* @return: void
	*/
	public static void error(String message, List<Object> values) {
		error(message, values, null);
	}

	/**
	* @description: Logs an error associated to a record or job ID. Result in a Log__c record being inserted, so do not call it in a Loop!
	* @params: message (short description of the error)
	* @params: contextId (ID of the associated record or job)
	* @return: void
	*/
	public static void error(String message, Id contextId) {
		error(message, new List<Object>(), contextId);
	}

	/**
	* @description: Logs an error associated to a record or job ID, with a list of associated information. Result in a Log__c record being inserted, so do not call it in a Loop!
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


	/**
 	HELPER METHODS
	**/

	private static Log__c newLog(String message, List<Object> values, Id contextId) {
		message = message +' ; '+ cast(values);
		Log__c newLog = new Log__c(Message__c = message);
		newLog.Context__c = (contextId == null) ? DEFAULT_CONTEXT : ' '+contextId;
		populateLocation(newLog);
		return newLog;
	}

	private static List<String> cast(List<Object> values) {
		List<String> result = new List<String>();
		for(Object value : values) {
			result.add(' ' + value);
		}
		return result;
	}


	private static String timestamp() {
		return System.now().formatGmt('HH:mm:ss.SSS');
	}


	private static void populateLocation(Log__c logMessage) {
		// Note: Idea taken from https://salesforce.stackexchange.com/questions/153835
		List<String> stacktrace = new DmlException().getStackTraceString().split('\n');

		for(String line : stacktrace) {
			Matcher matcher = STACK_LINE.matcher(line);
			if(matcher.find() && !line.startsWith('Class.' + CLASSNAME + '.')) {
				logMessage.Class__c = matcher.group(1);
				logMessage.Method__c = prettyMethod(matcher.group(2));
				logMessage.Line__c = Integer.valueOf(matcher.group(4));
				return;
			}

		}
	}

	private static String prettyMethod(String method) {
		String result = (method == null) ? 'anonymous' : method;
		return (result.contains('init')) ? 'ctor' : result;
	}

	private static void insertLogs(List<Log__c> logsToInsert) {
		Database.SaveResult[] srList = Database.insert(logsToInsert, false);
		for (Database.SaveResult sr : srList) {
			if (!sr.isSuccess()) {
				System.debug('Unable to save Log: '+ sr.getErrors());
			}
		}
	}

}