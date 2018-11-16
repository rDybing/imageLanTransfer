/* *******************************************
 *
 * networkIO.agc
 *
 * Project: imageLanTransfer
 *
 * *******************************************/
 
// ************************************************ Server Mode ********************************************************

function setupLAN(gs ref as gameState_t)
	
	gs.netID = hostNetwork("testNet", "Host", gs.netHostPort)
	SetNetworkLatency(gs.netID, 50)
		
endFunction

function openClientsIntake(gs ref as gameState_t)
	
	SetNetworkAllowClients(gs.netID) 
	
endFunction
 
function listenClientsStatus(gs ref as gameState_t)
	
	clientAck as integer
	clientName as string
	clientRemoval as integer
	tc as clients_t
	maxPlayers = 1
	
	clientID = GetNetworkFirstClient(gs.netID)
	
	while clientID > 0 and gs.netClients < 30
		// handle disconnect
		clientRemoval = false
		if GetNetworkClientDisconnected(gs.netID, clientID)
			if GetNetworkClientUserData(gs.netID, clientID, 0) = 0
				SetNetworkClientUserData(gs.netID, clientID, 0, 1)
				DeleteNetworkClient(gs.netID, clientID)
			endif
			removeClient(gs, clientID)
			clientRemoval = true
		endif		
		// seperate out host
		if clientID = GetNetworkMyClientID(gs.netID)
			gs.netHostID = clientID
		else
			clientName = getNetworkClientName(gs.netID, clientID)
			if getClientExists(gs, clientName) = false and clientRemoval = false
				if gs.net.length < maxPlayers
					tc.clientID = clientID
					tc.clientName = clientName
					gs.net.insert(tc)
					clientAck = createNetworkMessage()
					AddNetworkMessageString(clientAck, "OK")
					sendNetworkMessage(gs.netID, clientID, clientAck)
				endif
			endif
		endif
		gs.netClients = GetNetworkNumClients(gs.netID) - 1		
		clientID = GetNetworkNextClient(gs.netID)
	endWhile
		 
endFunction

function sendRoundData(gs as gameState_t, t as string[])

	clientRound = createNetworkMessage()
	AddNetworkMessageString(clientRound, t[0] + ":" + t[1] + ":" + t[2] + ":" + t[3])
	sendNetworkMessage(gs.netID, 0, clientRound)

endFunction

// ************************************************ Client Mode ********************************************************

function joinHost(gs ref as gameState_t)
		
	gs.networkID = JoinNetwork("testNet", gs.netHostPort, "testClient")
	
endFunction

function getServerAck(gs ref as gameState_t)
	
	out as integer = false
	serverAck as integer
	in as string
	temp as string
	
	serverAck = GetNetworkMessage(gs.networkID)
	
	if serverAck <> 0
		temp = GetNetworkMessageString(serverAck)
	endif
	
	if CountStringTokens(temp, ":") > 0
		in = GetStringToken(temp, ":", 1)
	endif
	
	
	if in = "OK"
		out = true
		gs.netClientID = GetNetworkMyClientID(gs.networkID)
		gs.netHostID = val(GetStringToken(temp, ":", 2))
	endif
	
	DeleteNetworkMessage(serverAck)	
	
endFunction out

// ************************************************ Chores *************************************************************

function getClientExists(gs as gameState_t, clientName as string)
	
	out as integer = false
	
	if gs.net.length > -1
		for i = 0 to gs.net.length
			if gs.net[i].clientName = clientName
				out = true
			endif
		next i
	endif
	
endFunction out

function removeClient(gs ref as gameState_t, clientID as integer)
	
	toRemove as integer = -1
	
	for i = 0 to gs.net.length
		if gs.net[i].clientID = clientID
			toRemove = i
		endif
	next i
	
	if toRemove <> -1
		gs.net.remove(toRemove)
		KickNetworkClient(gs.netID, clientID) 
	endif
	
endFunction
