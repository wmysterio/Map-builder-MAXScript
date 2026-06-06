try ( closeUtility mapBuilderUtility ) catch ()

utility mapBuilderUtility "Map builder" (
	
	label dummyLabel01 "Road" align:#left
	label dummyLabel02 "Width:" align:#left width:100 across:2 offset:[-10, 0]
	spinner roadWidthSpinner type:#float range:[4.0, 10.0, 5.0] align:#right width:50 offset:[15, -2]
	label dummyLabel03 ""
	label dummyLabel04 "Sidewalk" align:#left
	label dummyLabel05 "Width:" align:#left width:100 across:2 offset:[-10, 0]
	spinner sidewalkWidthSpinner type:#float range:[4.0, 6.0, 5.0] align:#right width:50 offset:[15, -2]
	label dummyLabel06 "Height:" align:#left width:100 across:2 offset:[-10, 0]
	spinner sidewalkHeightSpinner type:#float range:[0.1, 0.5, 0.1] align:#right width:50 offset:[15, -2]
	label dummyLabel07 "Segments:" align:#left across:2 offset:[-10, 0]
	spinner sidewalkSideSegmentsSpinner type:#integer range:[2, 8, 4] scale:2 align:#right width:50 offset:[15, -2]
	checkbox useInnerSidewalkSideCheckbox "Use Inner Side" checked:false align:#left width:150 offset:[-12, 0]
	label dummyLabel08 ""
	label dummyLabel09 "Material ID" align:#left
	label dummyLabel10 "Road:" align:#left width:80 across:3 offset:[-10, 0]
	spinner roadMaterialIdSpinner type:#integer range:[1, 100, 1] align:#right width:40 offset:[35, 0]
	button selectFacesByRoadMaterialIdButton "|>" width:20 align:#right offset:[15, -2]
	label dummyLabel11 "Sidewalk Side:" align:#left width:80 across:3 offset:[-10, 0]
	spinner sidewalkSideMaterialIdSpinner type:#integer range:[1, 100, 2] align:#right width:40 offset:[35, 0]
	button selectFacesBySidewalkSideMaterialIdButton "|>" width:20 align:#right offset:[15, -2]
	label dummyLabel12 "Sidewalk Top:" align:#left width:80 across:3 offset:[-10, 0]
	spinner sidewalkTopMaterialIdSpinner type:#integer range:[1, 100, 3] align:#right width:40 offset:[35, 0]
	button selectFacesBySidewalkTopMaterialIdButton "|>" width:20 align:#right offset:[15, -2]
	label dummyLabel13 "Inner Space:" align:#left width:80 across:3 offset:[-10, 0]
	spinner innerSpaceMaterialIdSpinner type:#integer range:[1, 100, 4] align:#right width:40 offset:[35, 0]
	button selectFacesByInnerSpaceMaterialIdButton "|>" width:20 align:#right offset:[15, -2]
	label dummyLabel14 ""
	checkbox assignMaterialsCheckbox "Assign Materials" checked:true align:#left width:120
	checkbox removeInnerSpaceCheckbox "Remove Inner Space" checked:false align:#left width:150
	checkbox splitByChunksCheckbox "Split by chunks" checked:false align:#left width:150 enabled:false
	button generateMap "Generate Map" width:160
	label dummyLabel15 ""
	label dummyLabel16 "Chunk Grid   6000.0x6000.0" align:#left
	label dummyLabel17 "Section Count:" align:#left width:90 across:2 offset:[-10, 0]
	spinner chunkGridSectionCountSpinner type:#integer range:[2, 500, 40] align:#right width:60 offset:[12, 0]
	label dummyLabel18 "Cell Size:" align:#left width:90 across:2 offset:[-10, 0]
	spinner chunkGridCellSizeSpinner type:#float range:[32.0, 512.0, 150.0] align:#right scale:10.0 width:60 offset:[12, 0]
	button createChunkGridButton "Create" width:75 across:2 offset:[-10, 0]
	button createFlatPlaneButton "Create Plane" align:#right width:82 offset:[13, 0]
	button createFlatPlaneWithSegmentsButton "Create Plane With Segments" width:160 offset:[-3, 0]
	label dummyLabel19 ""
	label dummyLabel20 "Path Grid   6000.0x6000.0" align:#left
	label dummyLabel21 "Section Count:" align:#left width:90 across:2 offset:[-10, 0]
	spinner pathGridSectionCountSpinner type:#integer range:[1, 128, 8] align:#right width:60 offset:[12, 0]
	label dummyLabel22 "Cell Size:" align:#left width:90 across:2 offset:[-10, 0]
	spinner pathGridCellSizeSpinner type:#float range:[64.0, 2000.0, 750.0] align:#right width:60 offset:[12, 0]
	button createPathGridButton "Create Path Grid" width:160
	label dummyLabel23 ""
	
	on generateMap pressed do (
		
		if selection.count != 1 then (
			messageBox ("Please select an object before creation.") title:"Script Error" beep:true
			return()
		)
		
		local obj = selection[1]
		if superClassOf obj != GeometryClass then (
			messageBox ("Please select a geometry object.") title:"Script Error" beep:true
			return()
		)
		
		local roadMaterialId = roadMaterialIdSpinner.value 
		local sidewalkTopMaterialId = sidewalkTopMaterialIdSpinner.value 
		local sidewalkSideMaterialId = sidewalkSideMaterialIdSpinner.value 
		local innerSpaceMaterialId = innerSpaceMaterialIdSpinner.value
		
		if( roadMaterialId == sidewalkTopMaterialId or roadMaterialId == sidewalkSideMaterialId or roadMaterialId == innerSpaceMaterialId or sidewalkTopMaterialId == sidewalkSideMaterialId or sidewalkTopMaterialId == innerSpaceMaterialId or sidewalkSideMaterialId == innerSpaceMaterialId ) then (
			messageBox ("Material IDs must be unique.") title:"Script Error" beep:true
			return()
		)
		
		fn fixInset obj = (
			local innerSpaceFaces = polyop.getFaceSelection obj
			for f in innerSpaceFaces do (
				subobjectLevel = 4
				polyop.setFaceSelection obj f
				local targetVertices = polyop.getVertsUsingFace obj f
				$.EditablePoly.GrowSelection ()
				macros.run "Editable Polygon Object" "EPoly_Convert_Sel_To_Vertex"
				local temp = (polyop.getVertSelection obj) - targetVertices
				for v in targetVertices do (
					local targetPos = polyOp.getVert obj v
					local maxDistance = 1000000.0
					local tempVertex = undefined
					for tv in temp do (
						local tempPos = polyOp.getVert obj tv
						local currentDistance = distance targetPos tempPos
						if maxDistance > currentDistance do (
							maxDistance = currentDistance
							tempVertex = tempPos
						)
					)
					polyOp.setVert obj v [targetPos.x, targetPos.y, tempVertex.z]
				)
			)
		)
		
		local roadWidth = roadWidthSpinner.value 
		local sidewalkWidth = sidewalkWidthSpinner.value 
		local sidewalkHeight = sidewalkHeightSpinner.value 
		local sidewalkSideSegments = sidewalkSideSegmentsSpinner.value / 2
		local sidewalkHalfWidth = sidewalkWidth * 0.5
		local temp1 = #()
		
		local objOldName = obj.name
		obj.name = uniqueName objOldName
		maxOps.cloneNodes obj cloneType:#copy newNodes:&temp1 #nodialog
		temp1[1].name = objOldName
		obj.isHidden = false
		convertToPoly obj
		max modify mode
		
		-------------------------------
		
		subobjectLevel = 4
		polyop.setFaceSelection obj #All
		polyop.setFaceMatID obj (polyop.getFaceSelection obj) roadMaterialId
		$.insetType = 1
		$.insetAmount = roadWidth
		$.EditablePoly.buttonOp #Inset
		polyop.setFaceMatID obj (polyop.getFaceSelection obj) sidewalkSideMaterialId
		fixInset obj
		subobjectLevel = 4
		$.EditablePoly.selectByMaterial sidewalkSideMaterialId
		$.insetType = 1
		$.insetAmount = sidewalkWidth
		$.EditablePoly.buttonOp #Inset
		polyop.setFaceMatID obj (polyop.getFaceSelection obj) innerSpaceMaterialId
		fixInset obj

		-------------------------------
		
		subobjectLevel = 4
		$.EditablePoly.selectByMaterial sidewalkSideMaterialId
		$.extrusionType = 1
		$.faceExtrudeHeight = sidewalkHeight
		$.EditablePoly.ButtonOp #Extrude
		polyop.setFaceMatID obj (polyop.getFaceSelection obj) sidewalkTopMaterialId
		subobjectLevel = 4
		$.EditablePoly.selectByMaterial sidewalkSideMaterialId
		macros.run "Editable Polygon Object" "EPoly_Convert_Sel_To_Edge"
		temp1 = polyop.getEdgeSelection obj
		subobjectLevel = 4
		$.EditablePoly.selectByMaterial roadMaterialId
		macros.run "Editable Polygon Object" "EPoly_Convert_Sel_To_Edge"
		temp1 = temp1 - (polyop.getEdgeSelection obj)
		subobjectLevel = 4
		$.EditablePoly.selectByMaterial innerSpaceMaterialId
		macros.run "Editable Polygon Object" "EPoly_Convert_Sel_To_Edge"
		temp1 = temp1 - (polyop.getEdgeSelection obj)
		subobjectLevel = 4
		$.EditablePoly.selectByMaterial sidewalkTopMaterialId
		macros.run "Editable Polygon Object" "EPoly_Convert_Sel_To_Edge"
		temp1 = temp1 - (polyop.getEdgeSelection obj)
		polyop.setEdgeSelection obj temp1
		$.edgeChamferMiteringType = 2
		$.edgeChamfer = sidewalkHalfWidth
		$.edgeChamferSegments = sidewalkSideSegments
		$.edgeChamferDepth = 0.5
		$.edgeChamferEndBias = 1.0
		$.edgeChamferRadialBias = 1.0
		$.edgeChamferOpen = off
		$.edgeChamferInvert = off
		$.edgeChamferSmoothThreshold = 30.0
		$.edgeChamferSmooth = on
		$.EditablePoly.buttonOp #Chamfer

		-------------------------------
		
		subobjectLevel = 3
		actionMan.executeAction 0 "40021"
		$.faceExtrudeHeight = sidewalkHeight
		$.edgeExtrudeWidth = 0
		$.EditablePoly.ButtonOp #Extrude
		macros.run "Editable Polygon Object" "EPoly_Convert_Sel_To_Face"
		$.extrusionType = 1
		$.faceExtrudeHeight = -roadWidth
		$.extrude_bias = 0
		$.EditablePoly.buttonOp #Extrude
		subobjectLevel = 3
		actionMan.executeAction 0 "40021"
		$.EditablePoly.delete #Edge
		actionMan.executeAction 0 "40021"
		$.EditablePoly.delete #Edge
		actionMan.executeAction 0 "40021"
		$.faceExtrudeHeight = sidewalkHeight
		$.edgeExtrudeWidth = 0
		$.EditablePoly.ButtonOp #Extrude
		subobjectLevel = 2
		temp1 = polyop.getEdgeSelection obj
		$.EditablePoly.GrowSelection ()
		polyop.setEdgeSelection obj ((polyop.getEdgeSelection obj) - temp1)
		$.edgeChamferMiteringType = 2
		$.edgeChamfer = sidewalkHalfWidth
		$.edgeChamferSegments = sidewalkSideSegments
		$.edgeChamferDepth = 0.5
		$.edgeChamferEndBias = 1.0
		$.edgeChamferRadialBias = 1.0
		$.edgeChamferOpen = off
		$.edgeChamferInvert = off
		$.edgeChamferSmoothThreshold = 30.0
		$.edgeChamferSmooth = on
		$.EditablePoly.buttonOp #Chamfer
		subobjectLevel = 3
		actionMan.executeAction 0 "40021"
		$.EditablePoly.delete #Edge

		-------------------------------
		
		subobjectLevel = 1
		actionMan.executeAction 0 "40021"
		$.weldThreshold = 0.001
		$.EditablePoly.weldFlaggedVertices ()
		subobjectLevel = 4
		$.EditablePoly.selectByMaterial innerSpaceMaterialId
		if removeInnerSpaceCheckbox.checked then (
			if not useInnerSidewalkSideCheckbox.checked then (
				$.EditablePoly.GrowSelection ()
			)
			$.EditablePoly.delete #Face
		) else (
			if not useInnerSidewalkSideCheckbox.checked then (
				macros.run "Editable Polygon Object" "EPoly_Convert_Sel_To_Vertex"
				$.EditablePoly.GrowSelection ()
				$.weldThreshold = sidewalkHeight + sidewalkHeight
				$.EditablePoly.weldFlaggedVertices ()
				subobjectLevel = 4
				$.EditablePoly.selectByMaterial innerSpaceMaterialId
				move $.selectedFaces [0,0,(sidewalkHeight * 0.5)]			
			)
		)
		
		subobjectLevel = 1
		actionMan.executeAction 0 "40021"
		$.weldThreshold = 0.001
		$.EditablePoly.weldFlaggedVertices ()
		$.EditablePoly.ConnectVertices ()
		subobjectLevel = 4
		polyop.setFaceSmoothGroup obj #All 0
		$.EditablePoly.autosmooth ()
		
		-------------------------------
		
		if assignMaterialsCheckbox.checked then (
			$.EditablePoly.selectByMaterial roadMaterialId
			$.material = meditMaterials[roadMaterialId]
			$.EditablePoly.selectByMaterial sidewalkTopMaterialId
			$.material = meditMaterials[sidewalkTopMaterialId]
			$.EditablePoly.selectByMaterial sidewalkSideMaterialId
			$.material = meditMaterials[sidewalkSideMaterialId]
			if not removeInnerSpaceCheckbox.checked then (
				$.EditablePoly.selectByMaterial innerSpaceMaterialId
				$.material = meditMaterials[innerSpaceMaterialId]
			)
			polyop.setFaceSelection obj #{}
		)
		
		-------------------------------
		
		if splitByChunksCheckbox.checked then (
			--modPanel.addModToSelection (SliceModifier ()) ui:on
			--$.modifiers[#Slice].PlanarX = on
			--$.modifiers[#Slice].PlanarY = on
			--$.modifiers[#Slice].PlanarZ = off
			--$.modifiers[#Slice].Slice_Type = 1
			--$.modifiers[#Slice].Faces___Polygons_Toggle = 1
			-- ...
			obj.pivot = obj.center 
		) else (
			obj.pivot = obj.center 
		)
		
		-------------------------------
		
		subobjectLevel = 0
		update obj
		forceCompleteRedraw()
		messageBox ("Done.") title:"Info" beep:true
	)

	fn createGrid segments size = (
		local planeSize = size * segments
		local obj = Plane length:planeSize width:planeSize pos:[0.0,0.0,0.0] isSelected:on lengthsegs:segments widthsegs:segments	
		convertToPoly obj
		max modify mode
		subobjectLevel = 2
		actionMan.executeAction 0 "40021"
		$.edgeExtrudeWidth = 0
		$.edgeExtrudeHeight = -1
		$.EditablePoly.buttonOp #Extrude
		macros.run "Editable Polygon Object" "EPoly_Convert_Sel_To_Face"
		max select invert
		$.EditablePoly.delete #Face
		subobjectLevel = 0
		selection.showFrozenInGray = false
		freeze obj
		update obj
	)	

	on createPathGridButton pressed do (
		local sectionCount = pathGridSectionCountSpinner.value 
		local cellSize = pathGridCellSizeSpinner.value 
		createGrid sectionCount cellSize
	)
	
	on createChunkGridButton pressed do (
		local sectionCount = chunkGridSectionCountSpinner.value 
		local cellSize = chunkGridCellSizeSpinner.value 
		createGrid sectionCount cellSize
	)
	
	on createFlatPlaneButton pressed do (
		local size = chunkGridCellSizeSpinner.value * chunkGridSectionCountSpinner.value
		local obj = Plane length:size width:size pos:[0.0,0.0,-1.0] isSelected:on lengthsegs:1 widthsegs:1	
		convertToPoly obj
		selection.showFrozenInGray = false
		freeze obj
		update obj
	)

	on createFlatPlaneWithSegmentsButton pressed do (
		local segments = chunkGridSectionCountSpinner.value - 1 
		local size = chunkGridCellSizeSpinner.value * segments
		local obj = Plane length:size width:size pos:[0.0,0.0,0.0] isSelected:on lengthsegs:segments widthsegs:segments	
		convertToPoly obj
		selection.showFrozenInGray = false
		update obj
	)

	fn selectFacesByMaterial id = (
		if selection.count != 1 then (
			return()
		)
		local obj = selection[1]
		if superClassOf obj != GeometryClass then (
			return()
		)
		convertToPoly obj
		max modify mode
		subobjectLevel = 4
		$.EditablePoly.selectByMaterial id
		--setCommandPanelTaskMode #utility 
		--UtilityPanel.OpenUtility MAXScript
	)

	on selectFacesByRoadMaterialIdButton pressed do ( selectFacesByMaterial roadMaterialIdSpinner.value )
	
	on selectFacesBySidewalkSideMaterialIdButton pressed do ( selectFacesByMaterial sidewalkSideMaterialIdSpinner.value )
	
	on selectFacesBySidewalkTopMaterialIdButton pressed do ( selectFacesByMaterial sidewalkTopMaterialIdSpinner.value )
	
	on selectFacesByInnerSpaceMaterialIdButton pressed do ( selectFacesByMaterial innerSpaceMaterialIdSpinner.value )

	on chunkGridCellSizeSpinner changed val do (
		local size = (val * chunkGridSectionCountSpinner.value) as string
		dummyLabel16.text = "Chunk Grid   " + size + "x" + size
	)
	
	on chunkGridSectionCountSpinner changed val do (
		local size = (chunkGridCellSizeSpinner.value * val) as string
		dummyLabel16.text = "Chunk Grid   " + size + "x" + size
	)

	on pathGridSectionCountSpinner changed val do (
		local size = (val * pathGridCellSizeSpinner.value) as string
		dummyLabel20.text = "Path Grid   " + size + "x" + size
	)
	
	on pathGridCellSizeSpinner changed val do (
		local size = (pathGridSectionCountSpinner.value * val) as string
		dummyLabel20.text = "Path Grid   " + size + "x" + size
	)
	
)

openUtility mapBuilderUtility