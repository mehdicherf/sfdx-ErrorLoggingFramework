/**
Logging utility. Derived from https://github.com/rsoesemann/apex-unified-logging
**/

public with sharing class Log {

    private static final String ORG_NAMESPACE = [SELECT NamespacePrefix FROM Organization LIMIT 1].NamespacePrefix;
    private static final String CLASSNAME = Log.class.getName();
    private static final Pattern STACK_LINE = Pattern.compile('^(?:Class\\.)?([^.]+)\\.?([^\\.\\:]+)?[\\.\\:]?([^\\.\\:]*): line (\\d+), column (\\d+)$');
    private static final String DEFAULT_CONTEXT = timestamp();


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



    private static void insertLog(String message, List<Object> values, Id contextId) {
        message = message +' ; '+ cast(values);
        System.debug('message ' + message);
        try{
            Log__c newLog = new Log__c(Message__c = message);
            newLog.Context__c = (contextId == null) ? DEFAULT_CONTEXT : ' '+contextId;
            populateLocation(newLog);
            insert(newLog);
        }
        catch (exception err){
            System.debug(err);
        }
    }


    private static List<String> cast(List<Object> values) {
        List<String> result = new List<String>();
        for(Object value : values) {
            System.debug('value: '+value);
            result.add(' ' + value);
        }
        System.debug('result: '+result);
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

}