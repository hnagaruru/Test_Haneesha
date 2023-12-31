uses gw.wsi.pl.datachangeapi.DataChangeAPI
uses gw.lang.cli.CommandLineAccess
uses gw.cmdline.util.DataChangeArgs
uses gw.cmdline.util.ServerRunLevelVerifier
uses java.io.File
uses gw.cmdline.util.ToolkitUtils
uses java.io.InputStreamReader
uses java.io.FileInputStream
uses java.io.BufferedReader
uses java.io.StringWriter

print( "Running ${Gosu.getCurrentProgram().Name}" )

//Initialize the args class for this program
CommandLineAccess.initialize( DataChangeArgs )
if (DataChangeArgs.Edit == null && DataChangeArgs.Discard == null && DataChangeArgs.Status == null && DataChangeArgs.Result == null) {
  print( "expected -edit, -discard, -status, or -result")
  CommandLineAccess.showHelp( DataChangeArgs )
}
else {
  DataChangeArgs.User = ToolkitUtils.getFromConsole("User:", DataChangeArgs.User)
  DataChangeArgs.Password = ToolkitUtils.getFromConsole("Password:", DataChangeArgs.Password)
var config = ToolkitUtils.initConfig("/ws/gw/wsi/pl/DataChangeAPI",
    DataChangeArgs.Server,
    DataChangeArgs.User,
    DataChangeArgs.Password)
var api = new DataChangeAPI( config )

print( "Connecting as ${config.Guidewire.Authentication.Username} to URL ${config.ServerOverrideUrl}" )

if( DataChangeArgs.Edit != null ) {
  var ref = DataChangeArgs.Edit
  var desc = DataChangeArgs.Description
  if (DataChangeArgs.GosuFile == null) {
    print("Gosu file name required")
    CommandLineAccess.showHelp(DataChangeArgs)
  }
  else {
    var file = new File(DataChangeArgs.GosuFile)
    if (!file.exists()) {
      print("Gosu file must exist")
      CommandLineAccess.showHelp(DataChangeArgs)
    }
    else {
      var rdr = new BufferedReader(new InputStreamReader(new FileInputStream(file), "UTF-8"))
      var buffer = new StringWriter()
      while (rdr.ready()) {
        buffer.append(rdr.readLine()).append("\n")
      }
      var gosu = buffer.Buffer.toString()
      confirmRunLevelMaintenance()
      var rtn = api.updateDataChangeGosu(ref, desc, gosu)
      print( "Edit change ref=" + ref + " publicId=" + rtn )
    }
  }
}

else if( DataChangeArgs.Discard != null ) {
  confirmRunLevelMaintenance()
  var rtn = api.discardDataChange(DataChangeArgs.Discard)
  print("Discarded DataChange ref=" + DataChangeArgs.Discard + " publicId=" + rtn)
}

else if( DataChangeArgs.Status != null ){
  confirmRunLevelMaintenance()
  var rtn = api.getDataChangeStatus(DataChangeArgs.Status)
  print("DataChange ref=" + DataChangeArgs.Status + " status=" + rtn)
}

else if( DataChangeArgs.Result != null ) {
  confirmRunLevelMaintenance()
  var rtn = api.getDataChangeResult(DataChangeArgs.Result)
  print("DataChange ref=" + DataChangeArgs.Result + " results:\n" + rtn)
}
}

function confirmRunLevelMaintenance() {
  var errorMessage = "The server must be at MAINTENANCE runlevel or greater in order to use data change tool operations."
  ServerRunLevelVerifier.confirmRunLevelMaintenance(DataChangeArgs.Server, DataChangeArgs.User, DataChangeArgs.Password, errorMessage)
}
