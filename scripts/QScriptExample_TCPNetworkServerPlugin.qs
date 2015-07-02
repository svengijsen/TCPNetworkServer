Include("JavaScript/underscore.js");
Include("QtScript/MainControlDialog.qs");
//Add and clear a new output window tab
BrainStim.addOutputWindow("NetworkServer");
BrainStim.clearOutputWindow("NetworkServer");
//Construct a new Plugin object
var objTCPNetworkServer1 = new TCPNetworkServer();
var objTCPNetworkServer2 = new TCPNetworkServer();
var ServerAddress;

function ServerDataAvailable(sData)
{
    Log("* ServerDataRecieved:" + sData);
}

function ClientDataAvailable(sData)
{
    Log("* ClientDataRecieved:" + sData);
}

function CleanupScript()
{
	ConnectDisconnectScriptFunctions(false);
	ServerDataAvailable = null;
	ClientDataAvailable = null;
	customButton1Pressed = null;
	customButton2Pressed = null;
	customButton3Pressed = null;
	customButton4Pressed = null;
	customButton5Pressed = null;
	customButton6Pressed = null;
	customButtonPressed = null;
	ConnectDisconnectScriptFunctions = null;
	objTCPNetworkServer1 = null;
	objTCPNetworkServer2 = null;
	ServerAddress = null;

	Log("CleanupScript succeeded!");
	CleanupScript = null;
	BrainStim.cleanupScript();
}

function ConnectDisconnectScriptFunctions(Connect)
{
    if(Connect)
    {
        Log("... Connecting Signal/Slots");
        try
        {
		mainDialog.customButton1["clicked()"].connect(this, this.customButton1Pressed);
		mainDialog.customButton2["clicked()"].connect(this, this.customButton2Pressed);
		mainDialog.customButton3["clicked()"].connect(this, this.customButton3Pressed);
		mainDialog.customButton4["clicked()"].connect(this, this.customButton4Pressed);
		mainDialog.customButton5["clicked()"].connect(this, this.customButton5Pressed);
		mainDialog.customButton6["clicked()"].connect(this, this.customButton6Pressed);
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
		mainDialog.customButton1["clicked()"].disconnect(this, this.customButton1Pressed);
		mainDialog.customButton2["clicked()"].disconnect(this, this.customButton2Pressed);
		mainDialog.customButton3["clicked()"].disconnect(this, this.customButton3Pressed);
		mainDialog.customButton4["clicked()"].disconnect(this, this.customButton4Pressed);
		mainDialog.customButton5["clicked()"].disconnect(this, this.customButton5Pressed);	
		mainDialog.customButton6["clicked()"].disconnect(this, this.customButton6Pressed);	
        }
        catch (e)
        {
            Log(".*. Something went wrong disconnecting the Signal/Slots:" + e);
        }
    }
}

function customButton1Pressed()
{
	customButtonPressed(1);
}

function customButton2Pressed()
{
	customButtonPressed(2);
}

function customButton3Pressed()
{
	customButtonPressed(3);
}

function customButton4Pressed()
{
	customButtonPressed(4);
}

function customButton5Pressed()
{
	customButtonPressed(5);
}

function customButton6Pressed()
{
	customButtonPressed(6);
}

function customButtonPressed(nIndex)
{
	Log("Button #" + nIndex + " was pressed.");
	if(nIndex==1)
	{
		var retVal = objTCPNetworkServer1.startServer("","201");
		objTCPNetworkServer1.ClientDataAvailable.connect(this, this.ClientDataAvailable);
		Log("listen() result -> " + retVal);
		ServerAddress = retVal.split(":");
	}
	else if(nIndex==2)
	{
		//listen() result -> The server is running on
		//IP: 137.120.137.130
		//port: 56688
		//Run the Client now.
		//Debug: "Network Server started @ 137.120.13.108:54855"  (mainwindow.cpp:468, void __thiscall MainWindow::setupNetworkServer(void))
		//Debug: "Network Server started @ 137.120.137.130:200"  (mainwindow.cpp:476, void __thiscall MainWindow::setupNetworkServer(const class QString &,unsigned short))
		//ServerAddress = Array["137.120.137.130", "200"];
		//ServerAddress = Array["137.120.237.117", "200"];
		ServerAddress = Array["169.254.64.14", "201"];
		if(ServerAddress.length > 1)
		{
		    Log("connectToServer() result -> " + objTCPNetworkServer2.connectToServer(ServerAddress[0],ServerAddress[1]));
		    objTCPNetworkServer2.ServerDataAvailable.connect(this, this.ServerDataAvailable);
		}
		else
		{
		    Log("No Server defined!");
		}		
	}
	else if(nIndex==3)
	{
		Log("3 pressed.");//Client sends data to server
		Log("sendClientData() result -> " + objTCPNetworkServer2.sendClientData("Log('clientdata')"));
	}
	else if(nIndex==4)
	{
		Log("4 pressed.");//Client sends data to server
		Log("sendServerData() result -> " + objTCPNetworkServer1.sendServerData("serverdata"));
	}
	else if(nIndex==5)
	{
		Log("w pressed.");//Client sends data to server
		Log("sendClientData() result -> " + objTCPNetworkServer2.sendClientData("changeStimuli(1,0)"));		
	}
	else if(nIndex==6)
	{
		Log("s pressed.");//Client sends data to server
		Log("sendClientData() result -> " + objTCPNetworkServer2.sendClientData("changeStimuli(2,0)"));
	}
}

mainDialog = new Dialog();
mainDialog.show();

//*!The below wrapper function can use the compose method because the original function has one or no parameters
Dialog.prototype.closeEvent = _.compose(mainDialog.closeEvent, function()//this function is first called, afterwards the original function
{
	Log("Dialog closeEvent() (wrapped) called");
	CleanupScript();
	//*!Return the first argument if there is one defined
	return;
})

//Set the dialogs title
mainDialog.windowTitle = "TCP Network Server Example";
//Create and configure Layout
var customLayout = new QGridLayout;
customLayout.setColumnStretch(1, 1);	
customLayout.setColumnMinimumWidth(1, 500);
//Create and configure some new labels
mainDialog.customLabel1 = new QLabel;
mainDialog.customLabel1.setFrameStyle(QFrame.Sunken | QFrame.Panel);
mainDialog.customLabel2 = new QLabel;
mainDialog.customLabel2.setFrameStyle(QFrame.Sunken | QFrame.Panel);
mainDialog.customLabel3 = new QLabel;
mainDialog.customLabel3.setFrameStyle(QFrame.Sunken | QFrame.Panel);
mainDialog.customLabel4 = new QLabel;
mainDialog.customLabel4.setFrameStyle(QFrame.Sunken | QFrame.Panel);
mainDialog.customLabel5 = new QLabel;
mainDialog.customLabel5.setFrameStyle(QFrame.Sunken | QFrame.Panel);
mainDialog.customLabel6 = new QLabel;
mainDialog.customLabel6.setFrameStyle(QFrame.Sunken | QFrame.Panel);
//Create and configure some new buttons
mainDialog.customButton1 = new QPushButton("Button #1");
mainDialog.customButton2 = new QPushButton("Button #2");
mainDialog.customButton3 = new QPushButton("Button #3");
mainDialog.customButton4 = new QPushButton("Button #4");
mainDialog.customButton5 = new QPushButton("Button #5");
mainDialog.customButton6 = new QPushButton("Button #6");
//Add created controls to layout and set the new layout
customLayout.addWidget(mainDialog.customButton1, 0, 0);
customLayout.addWidget(mainDialog.customLabel1, 0, 1);
customLayout.addWidget(mainDialog.customButton2, 1, 0);
customLayout.addWidget(mainDialog.customLabel2, 1, 1);
customLayout.addWidget(mainDialog.customButton3, 2, 0);
customLayout.addWidget(mainDialog.customLabel3, 2, 1);
customLayout.addWidget(mainDialog.customButton4, 3, 0);
customLayout.addWidget(mainDialog.customLabel4, 3, 1);
customLayout.addWidget(mainDialog.customButton5, 4, 0);
customLayout.addWidget(mainDialog.customLabel5, 4, 1);
customLayout.addWidget(mainDialog.customButton6, 5, 0);
customLayout.addWidget(mainDialog.customLabel6, 5, 1);

mainDialog.setLayout(customLayout);
ConnectDisconnectScriptFunctions(true);