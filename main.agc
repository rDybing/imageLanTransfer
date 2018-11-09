/* *******************************************
 *
 * Project: imageLanTransfer
 *
 * Test to find out how to transfer images
 * over a LAN network rather than having 
 * clients all ding my API at once...
 *
 * CC-BY Roy Dybing 2018
 *
 * For Milla Says AS
 *
 * *******************************************/

SetErrorMode(2)

SetWindowTitle("imageLanTransfer")
SetWindowSize(1024, 768, 0)
SetWindowAllowResize(1)
SetOrientationAllowed(1, 1, 1, 1)
SetSyncRate(30, 0)
SetScissor(0,0,0,0)
SetClearColor(255, 127, 0)
UseNewDefaultFonts(1)

#constant true = 1
#constant flase = 0
#constant nil = -1

type sprite_t
	image				as integer[]
	imageStart			as integer
endType

type media_t
	image				as integer[]
	imageStart			as integer
endType

type spriteProp_t
	posX				as float
	posY				as float
	width				as float
	height				as float
	offsetX				as float
	offsetY				as float
endType

type gameState_t
	netID				as integer
	netHostID			as integer
	netHostPort			as integer
	netClientID			as integer
	netClientName		as string
endType


global isServer 		as integer = true
global sprite			as sprite_t
global media			as media_t

constants()
main()

function main()

	mode 	as string
	gs		as gameState_t
	titles	as string[3] = ["imgFish.png", "imgFlower.png", "imgFork.png", "imgGoat.png"]
		
	if isServer
		mode = "running as server"
	else
		mode = "running as client"
	endif

	if isServer
		loadMedia(titles)
		assignSprites()
		setupLAN(gs)
	else
		gs.netId = JoinNetwork("testNet", "testClient")
	endif
	
	repeat
		print(mode)
		print("netId: " + str(gs.netId))
		sync()
	until GetPointerPressed()
	
endFunction

function setupLAN(gs ref as gameState_t)
	
	gs.netHostPort = 1025
	gs.netID = hostNetwork("testNet", "Host", gs.netHostPort)
	SetNetworkLatency(gs.netID, 50)
		
endFunction

function sendRoundData(gs as gameState_t, t as string[])

	clientRound = createNetworkMessage()
	AddNetworkMessageString(clientRound, t[0] + ":" + t[1] + ":" + t[2] + ":" + t[3])
	sendNetworkMessage(gs.netID, 0, clientRound)

endFunction

function constants()
	
	sprite.imageStart = 1000
	media.imageStart = 1000
	for i = 0 to 3
		sprite.image.insert(sprite.imageStart + i)
		media.image.insert(media.imageStart + i)
	next i
	
endFunction

function loadMedia(t as string[])
	
	for i = 0 to media.image.length
		loadImage(media.image[i], t[i])
	next i
	
endFunction

function assignSprites()
	
	spr as spriteProp_t
	
	spr.posX = 5
	spr.posY = 5
	spr.width = 30
	spr.height = -1
	
	for i = 0 to sprite.image.length
		
		select i
		case 0
			spr.posX = 5
			spr.posY = 5
		endCase
		case 1
			spr.posX = 55
			spr.posY = 5
		endCase
		case 2
			spr.posX = 5
			spr.posY = 55
		endCase
		case 3
			spr.posX = 55
			spr.posY = 55
		endCase
		endSelect
		
		imageSetup(sprite.image[i], 1, spr, media.image[i])
	
	next i
	
endFunction

function imageSetup(sID	as integer, depth as integer, spr as spriteProp_t, iID as integer)

	if GetSpriteExists(sID) = true
		DeleteSprite(sID)
	endif

	createSprite(sID, iID)
	setSpritePosition(sID, spr.posX, spr.posY)
	setSpriteSize(sID, spr.width, spr.height)
	setSpriteColorAlpha(sID, 255)
	setSpriteDepth(sID, depth)
	setSpriteVisible(sID, 1)

endFunction
