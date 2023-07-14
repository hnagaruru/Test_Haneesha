uses gw.cmdline.util.MaintenanceToolsArgs
uses gw.lang.cli.CommandLineAccess
uses gw.webservice.pc.pc1000.maintenancetoolsapi.MaintenanceToolsAPI
uses gw.webservice.pc.pc1000.maintenancetoolsapi.types.complex.ProcessID

uses java.net.URL
uses java.text.SimpleDateFormat

function formatDateTime(d : Date) : String {
  if (d == null) {
    return "N/A"
  }
  var dateTimeFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS")
  return dateTimeFormat.format(d)
}

print( "Running ${Gosu.getCurrentProgram().Name}" )

//Initialize the args class for this program
CommandLineAccess.initialize( MaintenanceToolsArgs )

//New up a maintenance soap service
var config = new gw.xml.ws.WsdlConfig()
config.ServerOverrideUrl = new URL(MaintenanceToolsArgs.Server + "/ws/gw/webservice/pc/pc1000/MaintenanceToolsAPI").toURI() as String
config.Guidewire.Authentication.Username = MaintenanceToolsArgs.User
config.Guidewire.Authentication.Password = MaintenanceToolsArgs.Password
var api = new MaintenanceToolsAPI( config );
print( "Connecting as ${config.Guidewire.Authentication.Username} to URL ${config.ServerOverrideUrl}" )

//If start process was passed in, fire it off
if( MaintenanceToolsArgs.StartProcess != null ) {
  var process = MaintenanceToolsArgs.StartProcess
  print( "Running process '${process}'" )
  if( validateProcessName( process ) ) {
    var pid : ProcessID
    if (MaintenanceToolsArgs.Arguments != null && MaintenanceToolsArgs.Arguments.length > 0) {
      print( "Arguments: ${MaintenanceToolsArgs.Arguments.toList()}" )
      pid = api.startBatchProcessWithArguments( process, MaintenanceToolsArgs.Arguments )
    } else {
      pid = api.startBatchProcess( process )
    }
    print( "Process '${process}' is being run with PID ${pid.Pid}" )
  }

//if process status was passed in, fire it off
} else if( MaintenanceToolsArgs.ProcessStatus != null ) {
  var nameOrId = MaintenanceToolsArgs.ProcessStatus

  //number passed in
  if( nameOrId.matches( "\\b\\d+\\b" ) ) {
    var pid = new ProcessID()
    pid.Pid = nameOrId.toLong()

    try {
      var status = api.batchProcessStatusByID( pid )

      print( "Process number ${nameOrId} (${status.Type}):" )

      if (status.Starting) {
        print( "Currently starting" )
      } else if( status.Executing ) {
        print( "Currently running, started at ${formatDateTime(status.StartDate)}, completed ${status.OpsCompleted} operation(s) with ${status.FailedOps} failure(s)" );
        if( status.DetailedStatus != null ) {
          print( "Detailed status: ${status.DetailedStatus}" )
        }
      } else {
        print("Started at ${formatDateTime(status.StartDate)}, completed at ${formatDateTime(status.DateCompleted)}")
        if (status.getSuccess()) {
          print("Ran to completion, completing ${status.OpsCompleted} operation(s) with ${status.FailedOps} failure(s)");
        } else {
          print( "Failed to run to completion: ${status.FailureReason}. Completed ${status.OpsCompleted} operation(s) " +
                 "with ${status.FailedOps } failure(s) before terminating" )
        }
      }
    } catch ( e ) {
      print( "Failed to find process status: " + e.Message )
    }
  }

  else { //name passed in
    if ( validateProcessName (nameOrId ) ) {
      var status = api.batchProcessStatusByName(nameOrId)
      print("Process ${nameOrId}:");

      if (status.Starting) {
        print( "Currently starting" )
      } else if( status.Executing ) {
        print("Process ${nameOrId} is currently running with ${status.OpsCompleted} operation(s) completed and ${status.FailedOps} failure(s) so far")
        if (status.DetailedStatus != null) {
          print( "Detailed status: ${status.DetailedStatus}" )
        }
      } else {
        print("Process ${nameOrId} is not currently running. To view completion status of a particular process instance, please provide the process ID.");
      }
    }
  }
}

else if( MaintenanceToolsArgs.TerminateProcess != null ){
  var nameOrId = MaintenanceToolsArgs.TerminateProcess

  //number passed in
  if( nameOrId.matches( "\\b\\d+\\b" ) ) {
    var pid = new ProcessID()
    pid.Pid = nameOrId.toLong()

    try {
      if( api.requestTerminationOfBatchProcessByID( pid ) ) {
        print( "Terminated process number ${nameOrId}" );
      } else {
        print( "Process ${nameOrId} couldn't be terminated or isn't currently running." )
      }
    } catch ( e ) {
      print ("Failed to terminate process: ${e.LocalizedMessage}" )
    }

  //name passed in
  } else {
    if ( validateProcessName (nameOrId ) ) {
      if( api.requestTerminationOfBatchProcessByName( nameOrId ) ) {
        print( "Terminated process ${nameOrId}" );
      } else {
        print( "Process ${nameOrId} couldn't be terminated or isn't currently running." )
      }
    }
  }
}

else if( MaintenanceToolsArgs.WhenStats ) {
  var calcTime = api.whenStatsCalculated()
  var server = MaintenanceToolsArgs.Server
  if (calcTime == null) {
    print("Server on '${server}' has not calculated statistics")
  } else {
    print("Server on '${server}' calculated statistics at ${formatDateTime(calcTime)}")
 }
}

else {
  CommandLineAccess.showHelp( MaintenanceToolsArgs )
}


print( "done" )

function validateProcessName( process : String ) : boolean {
  if( not api.isBatchProcessNameValid(process) ) {
    var validNames = api.getValidBatchProcessNames().toList().sort().join( ", " )
    print( "'${process}' is not a valid process name. Valid names are: ${validNames}" )
    return false
  }
  return true
}
