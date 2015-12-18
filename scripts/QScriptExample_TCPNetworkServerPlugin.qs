//Add and clear a new output window tab
BrainStim.addOutputWindow("NetworkServer");
BrainStim.clearOutputWindow("NetworkServer");
//Construct a new Plugin object
var objTCPNetworkServer = new TCPNetworkServer();
//Two helper variables to store the state
var bServerIsListening = false;
var bServerIsConnected = false;

//Create a custom dialog with only one exit button to exit the script when needed
function Dialog(parent)
{
	QDialog.call(this, parent);
	var frameStyle = QFrame.Sunken | QFrame.Panel;
	var layout = new QGridLayout;
	layout.setColumnStretch(1, 1);	
	layout.setColumnMinimumWidth(1, 500);
	/////////////////////////////////////////////////////
	this.startServerButton = new QPushButton("Start Server --> (Port)");
	layout.addWidget(this.startServerButton, 0, 0);
	this.startServerLineEditPort = new QLineEdit;
	layout.addWidget(this.startServerLineEditPort, 0, 2);
	this.startServerLineEditPort.text = "200";
	
	this.connectToServerButton = new QPushButton("Connect to Server --> (Address, Port)");	
	layout.addWidget(this.connectToServerButton, 1, 0);
	this.connectToServerLineEditAddress = new QLineEdit;
	layout.addWidget(this.connectToServerLineEditAddress, 1, 1);
	this.connectToServerLineEditAddress.text = "127.0.0.1";
	this.connectToServerLineEditPort = new QLineEdit;
	layout.addWidget(this.connectToServerLineEditPort, 1, 2);
	this.connectToServerLineEditPort.text = "200";
	
	this.sendDataButton = new QPushButton("Send Data");	
	layout.addWidget(this.sendDataButton, 2, 0);
	this.sendDataLineEdit = new QLineEdit;
	layout.addWidget(this.sendDataLineEdit, 2, 1);
	this.sendDataLineEdit.text = "Data String.";
	/////////////////////////////////////////////////////
	this.exitButton = new QPushButton("Exit");	
	layout.addWidget(this.exitButton, 99, 0);
	/////////////////////////////////////////////////////
	this.setLayout(layout);
	this.windowTitle = "Menu Dialog";
}

Dialog.prototype = new QDialog();

Dialog.prototype.keyPressEvent = function(e /*QKeyEvent e*/)
{
	if(e.key() == Qt.Key_Escape)
		this.close();
	else
		QDialog.keyPressEvent(e);
}

Dialog.prototype.closeEvent = function() 
{
	Log("Dialog closeEvent() detected!");
	CleanupScript();
}

function CreateServer()
{
	Log("CreateServer() called");
	if((bServerIsListening==false) && (bServerIsConnected==false))
	{
		bServerIsListening = true;
		var retVal = objTCPNetworkServer.startServer("",mainDialog.startServerLineEditPort.text);
		//objTCPNetworkServer.ClientDataAvailable.connect(this, ClientDataAvailable);
		BrainStim.write2OutputWindow("Server is now listening at(address:port): " + retVal, "NetworkServer");
	}
}

function ConnectToServer()
{
	Log("ConnectToServer() called");
	if((bServerIsListening==false) && (bServerIsConnected==false))
	{
		bServerIsConnected = true;
		var retVal = objTCPNetworkServer.connectToServer(mainDialog.connectToServerLineEditAddress.text, mainDialog.connectToServerLineEditPort.text);
		//objTCPNetworkServer.ServerDataAvailable.connect(this, ServerDataAvailable);
		if(retVal)
			BrainStim.write2OutputWindow("Computer is now connected to Server(" + mainDialog.connectToServerLineEditAddress.text + ":" + mainDialog.connectToServerLineEditPort.text + ")", "NetworkServer");
	}
}

function SendData()
{
	Log("SendData() called");
	var retVal;
	if(bServerIsListening)
	{
		retVal = objTCPNetworkServer.sendServerData(mainDialog.sendDataLineEdit.text);
		BrainStim.write2OutputWindow("Server Data Send(" + retVal + "): " + mainDialog.sendDataLineEdit.text, "NetworkServer");
	}
	else if(bServerIsConnected)
	{
		retVal = objTCPNetworkServer.sendClientData(mainDialog.sendDataLineEdit.text);
		BrainStim.write2OutputWindow("Client Data Send(" + retVal + "): " + mainDialog.sendDataLineEdit.text, "NetworkServer");
	}
}

function ServerDataAvailable(sData)
{
	BrainStim.write2OutputWindow("* ServerDataRecieved:" + sData, "NetworkServer");
}

function ClientDataAvailable(sData)
{
	BrainStim.write2OutputWindow("* ClientDataRecieved:" + sData, "NetworkServer");
}

function CleanupScript()
{
	//Close dialog
	mainDialog.close();
	//Disconnect the signal/slots
	ConnectDisconnectScriptFunctions(false);
	//Set all functions and constructed objects to null
	CreateServer = null;
	ConnectToServer = null;
	SendData = null;
	ServerDataAvailable = null;
	ClientDataAvailable = null;
	ConnectDisconnectScriptFunctions = null;
	CleanupScript = null;
	//Dialog
	Dialog.prototype.keyPressEvent = null;
	Dialog.prototype.closeEvent = null;	
	Dialog.prototype.testFunction = null;
	Dialog.prototype = null;
	Dialog = null;
	//Objects
	mainDialog = null;
	objTCPNetworkServer = null;
	//Post
	Log("Finished script cleanup, ready for garbage collection!");
	BrainStim.cleanupScript();
}

function ConnectDisconnectScriptFunctions(Connect)
{
	if(Connect)
	{
		Log("... Connecting Signal/Slots");
		try
		{
			mainDialog.exitButton["clicked()"].connect(this, this.CleanupScript);
			mainDialog.connectToServerButton["clicked()"].connect(this, this.ConnectToServer);
			mainDialog.startServerButton["clicked()"].connect(this, this.CreateServer);
			mainDialog.sendDataButton["clicked()"].connect(this, this.SendData);
			objTCPNetworkServer.ClientDataAvailable.connect(this, ClientDataAvailable);
			objTCPNetworkServer.ServerDataAvailable.connect(this, ServerDataAvailable);
		}
		catch (e)
		{
			Log(".*. Something went wrong connecting the Signal/Slots:" + e);
		}
	}
	else
	{
		Log("... Disconnecting Signal/Slots");
		try
		{
			mainDialog.exitButton["clicked()"].disconnect(this, this.CleanupScript);
			mainDialog.connectToServerButton["clicked()"].disconnect(this, this.ConnectToServer);
			mainDialog.startServerButton["clicked()"].disconnect(this, this.CreateServer);
			mainDialog.sendDataButton["clicked()"].disconnect(this, this.SendData);
			objTCPNetworkServer.ClientDataAvailable.disconnect(this, ClientDataAvailable);
			objTCPNetworkServer.ServerDataAvailable.disconnect(this, ServerDataAvailable);
		}
		catch (e)
		{
			Log(".*. Something went wrong disconnecting the Signal/Slots:" + e);
		}
	}
}

var mainDialog = new Dialog();
mainDialog.windowTitle = "TCP Network Server Example";
mainDialog.show();
ConnectDisconnectScriptFunctions(true);