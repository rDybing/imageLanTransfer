function imagesToByte(img1 as integer, img2 as integer, img3 as integer, img4 as integer)
	
	ia as integer[3]
	mba as integer[3] = [0, 1, 2, 3]
	
	ia[0] = img1
	ia[1] = img2
	ia[2] = img3
	ia[3] = img4
	
	if GetMemblockExists(mba[i])
		DeleteMemblock(mba[i])
	endif
	
	for i = 0 to ia.length
		if GetMemblockExists(mba[i])
			DeleteMemblock(mba[i])
		endif
		mba[i] = CreateMemblockFromImage(ia[i])
	next i
	
endFunction mba
