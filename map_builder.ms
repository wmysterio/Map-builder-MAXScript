try ( closeUtility mapBuilderUtility ) catch ()

utility mapBuilderUtility "Map builder" (

	label dummyLabel00 "Half road width:" align:#left
	spinner halfRoadWidthSpinner type:#float range:[4.0, 10.0, 5.0] align:#left width:150
	
	label dummyLabel01 "Sidewalk width:" align:#left
	spinner sidewalkWidthSpinner type:#float range:[4.0, 6.0, 5.0] align:#left width:150
	
	label dummyLabel02 "Sidewalk height:" align:#left
	spinner sidewalkHeightSpinner type:#float range:[0.1, 0.5, 0.1] align:#left width:150
	
	label dummyLabel03 "Sidewalk side segments:" align:#left
	spinner sidewalkSideSegmentsSpinner type:#integer range:[2, 8, 4] align:#left width:150 scale:2

	checkbox useSidewalkInnerSideCheckbox "Use sidewalk inner side" checked:false align:#left width:150
	checkbox welkSidewalkFloorCheckbox "Weld sidewalk floor" checked:true align:#left width:150
	checkbox removeInnerSpaceCheckbox "Remove inner space" checked:false align:#left width:150

	label dummyLabel04 ""
	label dummyLabel05 "Road floor material ID:" align:#left
	spinner materialIdForRoadSpinner type:#integer range:[1, 100, 1] align:#left width:150
	
	label dummyLabel06 "Sidewalk side material ID:" align:#left
	spinner materialIdForSidewalkSideSpinner type:#integer range:[1, 100, 2] align:#left width:150
	
	label dummyLabel07 "Sidewalk floor material ID:" align:#left
	spinner materialIdForSidewalkFloorSpinner type:#integer range:[1, 100, 3] align:#left width:150
	
	label dummyLabel08 "Inner space material ID:" align:#left
	spinner materialIdForInnerSpaceSpinner type:#integer range:[1, 100, 4] align:#left width:150
	
	checkbox assignMaterialsCheckbox "Assign materials" checked:true align:#left width:150
	
	label dummyLabel09 " "
	button makeMapButton "Make map"
	label dummyLabel10 " "
	label dummyLabel11 "----------"
	
	label dummyLabel12 "Path grid sections count:" align:#left
	spinner pathGridSectionsSpinner type:#integer range:[1, 64, 8] align:#left width:150
	
	label dummyLabel13 "Path grid cell size:" align:#left
	spinner pathGridCellSizeSpinner type:#float range:[10.0, 4000.0, 750.0] align:#left width:150 scale:10.0
	
	button spawnPathsGridButton "Create paths grid"
	label dummyLabel14 " "
	label dummyLabel15 "----------"
	
	label dummyLabel16 "Chunks grid sections count:" align:#left
	spinner chunksGridSectionsSpinner type:#integer range:[1, 128, 30] align:#left width:150
	
	label dummyLabel17 "Chunks grid cell size:" align:#left
	spinner chunksGridCellSizeSpinner type:#float range:[10.0, 4000.0, 200.0] align:#left width:150 scale:10.0
	
	button spawnChunksGridButton "Create chunks grid"
	button spawnFlatPlaneButton "Create flat plane"
	label dummyLabel18 " "
	
	on makeMapButton pressed do (
		
		if selection.count != 1 then (
			messageBox ("You need select one object before creation!") title:"Script Error" beep:true
			return()
		)
		
		local obj = selection[1]
		if superClassOf obj != GeometryClass then (
			messageBox ("You need select object with GeometryClass!") title:"Script Error" beep:true
			return()
		)
		
		local materialIdForRoad = materialIdForRoadSpinner.value 
		local materialIdForSidewalkFloor = materialIdForSidewalkFloorSpinner.value 
		local materialIdForSidewalkSide = materialIdForSidewalkSideSpinner.value 
		local materialIdForInnerSpace = materialIdForInnerSpaceSpinner.value 
		
		if( materialIdForRoad == materialIdForSidewalkFloor or materialIdForRoad == materialIdForSidewalkSide or materialIdForRoad == materialIdForInnerSpace or materialIdForSidewalkFloor == materialIdForSidewalkSide or materialIdForSidewalkFloor == materialIdForInnerSpace or materialIdForSidewalkSide == materialIdForInnerSpace ) then (
			messageBox ("Need unique materials ID's!") title:"Script Error" beep:true
			return()
		)
		
		fn getEdgeBetweenVertices obj vertexIndexA vertexIndexB = (
			local edgesA1 = polyOp.getEdgesUsingVert obj vertexIndexA
			local edgesA2 = polyOp.getEdgesUsingVert obj vertexIndexB
			local sharedEdge = edgesA1 * edgesA2
			if not sharedEdge.isEmpty then (sharedEdge as array)[1] else 0
		)
			
		local halfRoadWidth = halfRoadWidthSpinner.value 
		local sidewalkWidth = sidewalkWidthSpinner.value 
		local sidewalkHeight = sidewalkHeightSpinner.value 
		local sidewalkSideSegments = sidewalkSideSegmentsSpinner.value / 2
		local tempArray1 = #()
		local tempArray2 = #()
		local tempArray3 = #{}
		
		maxOps.cloneNodes obj cloneType:#copy #nodialog
		
		obj.isHidden = false
		
		-------------------------------
		
		convertToPoly obj
		max modify mode
		
		subobjectLevel = 4
		polyop.setFaceSelection obj #All
		polyop.setFaceMatID obj (polyop.getFaceSelection obj) materialIdForRoad
		$.insetType = 1
		$.insetAmount = halfRoadWidth
		$.EditablePoly.buttonOp #Inset
		polyop.setFaceMatID obj (polyop.getFaceSelection obj) materialIdForSidewalkSide
		$.extrusionType = 1
		$.faceExtrudeHeight = sidewalkHeight
		$.EditablePoly.ButtonOp #Extrude
		polyop.setFaceMatID obj (polyop.getFaceSelection obj) materialIdForSidewalkFloor
		macros.run "Editable Polygon Object" "EPoly_Convert_Sel_To_Edge"
		tempArray1 = polyop.getEdgeSelection obj
		$.EditablePoly.GrowSelection ()
		polyop.setEdgeSelection obj ((polyop.getEdgeSelection obj) - tempArray1)
		$.edgeChamferMiteringType = 2
		$.edgeChamfer = halfRoadWidth
		$.edgeChamferSegments = sidewalkSideSegments
		$.edgeChamferDepth = 0.5
		$.edgeChamferEndBias = 1.0
		$.edgeChamferRadialBias = 1.0
		$.edgeChamferOpen = off
		$.edgeChamferInvert = off
		$.edgeChamferSmoothThreshold = 30.0
		$.edgeChamferSmooth = on
		$.EditablePoly.buttonOp #Chamfer
		subobjectLevel = 4
		$.EditablePoly.selectByMaterial materialIdForRoad
		macros.run "Editable Polygon Object" "EPoly_Convert_Sel_To_Vertex"
		$.EditablePoly.ConnectVertices ()
		$.weldThreshold = 0.001
		$.EditablePoly.weldFlaggedVertices ()
		
		subobjectLevel = 3
		actionMan.executeAction 0 "40021"
		$.edgeExtrudeHeight = sidewalkHeight
		$.edgeExtrudeWidth = 0.0
		$.EditablePoly.buttonOp #Extrude
		macros.run "Editable Polygon Object" "EPoly_Convert_Sel_To_Face"
		$.faceExtrudeHeight = -halfRoadWidth
		$.extrude_bias = 1.0
		$.extrusionType = 1.0
		$.EditablePoly.buttonOp #Extrude
		subobjectLevel = 3
		actionMan.executeAction 0 "40021"
		$.EditablePoly.delete #Edge
		actionMan.executeAction 0 "40021"
		$.EditablePoly.delete #Edge
		actionMan.executeAction 0 "40021"
		subobjectLevel = 2
		$.extrusionType = 0
		$.faceExtrudeHeight = sidewalkHeight
		$.EditablePoly.ButtonOp #Extrude
		tempArray1 = polyop.getEdgeSelection obj
		$.EditablePoly.GrowSelection ()
		polyop.setEdgeSelection obj ((polyop.getEdgeSelection obj) - tempArray1)
		$.edgeChamferMiteringType = 2
		$.edgeChamfer = halfRoadWidth
		$.edgeChamferSegments = sidewalkSideSegments
		$.edgeChamferDepth = 0.5
		$.edgeChamferEndBias = 1.0
		$.edgeChamferRadialBias = 1.0
		$.edgeChamferOpen = off
		$.edgeChamferInvert = off
		$.edgeChamferSmoothThreshold = 30.0
		$.edgeChamferSmooth = on
		$.EditablePoly.buttonOp #Chamfer
		subobjectLevel = 4
		$.EditablePoly.selectByMaterial materialIdForRoad
		macros.run "Editable Polygon Object" "EPoly_Convert_Sel_To_Vertex"
		$.EditablePoly.ConnectVertices ()
		$.weldThreshold = 0.001
		$.EditablePoly.weldFlaggedVertices ()
		subobjectLevel = 3
		actionMan.executeAction 0 "40021"
		$.EditablePoly.GrowSelection ()
		macros.run "Editable Polygon Object" "EPoly_Convert_Sel_To_Face"
		$.EditablePoly.delete #Face
		
		subobjectLevel = 4
		$.EditablePoly.selectByMaterial materialIdForSidewalkFloor
		$.insetType = 0
		$.insetAmount = sidewalkWidth
		$.EditablePoly.buttonOp #Inset
		macros.run "Editable Polygon Object" "EPoly_Convert_Sel_To_Vertex"
		$.weldThreshold = sidewalkWidth * 0.5
		$.EditablePoly.weldFlaggedVertices ()
		$.EditablePoly.ShrinkSelection ()
		polyop.setFaceMatID obj (polyop.getFaceSelection obj) materialIdForInnerSpace
		subobjectLevel = 4
		$.EditablePoly.selectByMaterial materialIdForInnerSpace
		polyop.setFaceMatID obj (polyop.getFaceSelection obj) materialIdForSidewalkSide
		$.extrusionType = 0
		$.faceExtrudeHeight = -sidewalkHeight
		$.EditablePoly.buttonOp #Extrude
		polyop.setFaceMatID obj (polyop.getFaceSelection obj) materialIdForInnerSpace
		subobjectLevel = 1	
		PolyToolsSelect.NumericVertex 8 1 false
		tempArray1 = polyop.getVertSelection obj -- upper vertices
		subobjectLevel = 4
		$.EditablePoly.selectByMaterial materialIdForInnerSpace
		macros.run "Editable Polygon Object" "EPoly_Convert_Sel_To_Vertex"
		tempArray2 = polyop.getVertSelection obj -- lower vertices
		local maxDistance = sidewalkHeight + 0.01
		print "Find bottom vertices for inner space..."
		for lowerVertexIndex in tempArray2 do (
			local lowerVertex = (polyop.getVert obj lowerVertexIndex)
			for upperVertexIndex in tempArray1 do (
				local upperVertex = (polyop.getVert obj upperVertexIndex)
				local currentDistance = distance lowerVertex upperVertex
				if currentDistance > 0.0 and maxDistance > currentDistance then (
					append tempArray3 (getEdgeBetweenVertices obj lowerVertexIndex upperVertexIndex)
				)
			)
		)
		subobjectLevel = 2
		polyop.setEdgeSelection obj tempArray3
		$.edgeChamferMiteringType = 2
		$.edgeChamfer = sidewalkWidth + (sidewalkHeight * 2.0)
		$.edgeChamferSegments = sidewalkSideSegments
		$.edgeChamferDepth = 0.5
		$.edgeChamferEndBias = 1.0
		$.edgeChamferRadialBias = 1.0
		$.edgeChamferOpen = off
		$.edgeChamferInvert = off
		$.edgeChamferSmoothThreshold = 30.0
		$.edgeChamferSmooth = on
		$.EditablePoly.buttonOp #Chamfer
		subobjectLevel = 4
		$.EditablePoly.selectByMaterial materialIdForSidewalkFloor
		macros.run "Editable Polygon Object" "EPoly_Convert_Sel_To_Vertex"
		$.weldThreshold = 0.001
		$.EditablePoly.weldFlaggedVertices ()
		$.EditablePoly.ConnectVertices ()
		
		if welkSidewalkFloorCheckbox.checked then (
			subobjectLevel = 4
			$.EditablePoly.selectByMaterial materialIdForSidewalkFloor
			macros.run "Editable Polygon Object" "EPoly_Convert_Sel_To_Vertex"
			$.EditablePoly.ShrinkSelection ()
			$.EditablePoly.Remove ()
			subobjectLevel = 4
			$.EditablePoly.selectByMaterial materialIdForSidewalkFloor
			macros.run "Editable Polygon Object" "EPoly_Convert_Sel_To_Vertex"
			$.EditablePoly.ConnectVertices ()
		)

		if not useSidewalkInnerSideCheckbox.checked then (
			subobjectLevel = 4
			$.EditablePoly.selectByMaterial materialIdForInnerSpace
			macros.run "Editable Polygon Object" "EPoly_Convert_Sel_To_Edge"
			tempArray1 = polyop.getEdgeSelection obj
			$.EditablePoly.GrowSelection ()
			polyop.setEdgeSelection obj ((polyop.getEdgeSelection obj) - tempArray1)
			macros.run "Editable Polygon Object" "EPoly_Convert_Sel_To_Face"
			$.EditablePoly.delete #Face
			subobjectLevel = 4
			$.EditablePoly.selectByMaterial materialIdForInnerSpace
			move $.selectedFaces [0,0,sidewalkHeight]
		)
		
		subobjectLevel = 1
		actionMan.executeAction 0 "40021"
		$.EditablePoly.weldFlaggedVertices ()
		$.weldThreshold = 0.001
		subobjectLevel = 4
		$.EditablePoly.selectByMaterial materialIdForInnerSpace
		macros.run "Editable Polygon Object" "EPoly_Convert_Sel_To_Vertex"
		$.EditablePoly.ConnectVertices ()
		
		subobjectLevel = 4
		polyop.setFaceSmoothGroup obj #All 0
		
		if assignMaterialsCheckbox.checked then (
			$.EditablePoly.selectByMaterial materialIdForRoad
			$.material = meditMaterials[materialIdForRoad]
			$.EditablePoly.selectByMaterial materialIdForSidewalkFloor
			$.material = meditMaterials[materialIdForSidewalkFloor]
			$.EditablePoly.selectByMaterial materialIdForSidewalkSide
			$.material = meditMaterials[materialIdForSidewalkSide]
			$.EditablePoly.selectByMaterial materialIdForInnerSpace
			$.material = meditMaterials[materialIdForInnerSpace]
		)
		
		if removeInnerSpaceCheckbox.checked then (
			$.EditablePoly.selectByMaterial materialIdForInnerSpace
			$.EditablePoly.delete #Face
		)
		
		subobjectLevel = 0
		update obj
		messageBox ("Done!") title:"Info" beep:true
	)

	fn createGrid segments size = (
		local planeSize = segments * size
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
	
	on spawnPathsGridButton pressed do (
		local sectionsCount = pathGridSectionsSpinner.value 
		local cellSize = pathGridCellSizeSpinner.value 
		createGrid sectionsCount cellSize
	)
	
	on spawnChunksGridButton pressed do (
		local sectionsCount = chunksGridSectionsSpinner.value 
		local cellSize = chunksGridCellSizeSpinner.value 
		createGrid sectionsCount cellSize
	)
	
	on spawnFlatPlaneButton pressed do (
		local size = chunksGridSectionsSpinner.value * chunksGridCellSizeSpinner.value 
		local obj = Plane length:size width:size pos:[0.0,0.0,-1] isSelected:on lengthsegs:1 widthsegs:1	
		convertToPoly obj
		selection.showFrozenInGray = false
		freeze obj
		update obj
	)
	
)

openUtility mapBuilderUtility