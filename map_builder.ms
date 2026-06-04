try ( closeUtility mapBuilderUtility ) catch ()

utility mapBuilderUtility "Map builder" (

	label dummyLabel00 "Half Road Width:" align:#left
	spinner halfRoadWidthSpinner type:#float range:[4.0, 10.0, 5.0] align:#left width:150
	
	label dummyLabel01 "Sidewalk Width:" align:#left
	spinner sidewalkWidthSpinner type:#float range:[4.0, 6.0, 5.0] align:#left width:150
	
	label dummyLabel02 "Sidewalk Height:" align:#left
	spinner sidewalkHeightSpinner type:#float range:[0.1, 0.5, 0.1] align:#left width:150
	
	label dummyLabel03 "Sidewalk Side Segments:" align:#left
	spinner sidewalkSideSegmentsSpinner type:#integer range:[2, 8, 4] align:#left width:150 scale:2

	checkbox useInnerSidewalkSideCheckbox "Use Inner Sidewalk Side" checked:false align:#left width:150
	checkbox weldSidewalkTopCheckbox "Weld Sidewalk Top" checked:true align:#left width:150
	checkbox removeInnerSpaceCheckbox "Remove Inner Space" checked:false align:#left width:150

	label dummyLabel04 ""
	label dummyLabel05 "Road Material ID:" align:#left
	spinner roadMaterialIdSpinner type:#integer range:[1, 100, 1] align:#left width:150
	
	label dummyLabel06 "Sidewalk Side Material ID:" align:#left
	spinner sidewalkSideMaterialIdSpinner type:#integer range:[1, 100, 2] align:#left width:150
	
	label dummyLabel07 "Sidewalk Top Material ID:" align:#left
	spinner sidewalkTopMaterialIdSpinner type:#integer range:[1, 100, 3] align:#left width:150
	
	label dummyLabel08 "Inner Space Material ID:" align:#left
	spinner innerSpaceMaterialIdSpinner type:#integer range:[1, 100, 4] align:#left width:150
	
	checkbox assignMaterialsCheckbox "Assign Materials" checked:true align:#left width:150
	
	label dummyLabel09 " "
	button generateMap "Generate Map"
	label dummyLabel10 " "
	label dummyLabel11 "----------"
	
	label dummyLabel12 "Path Grid Section Count:" align:#left
	spinner pathGridSectionCountSpinner type:#integer range:[1, 64, 8] align:#left width:150
	
	label dummyLabel13 "Path Grid Cell Size:" align:#left
	spinner pathGridCellSizeSpinner type:#float range:[10.0, 4000.0, 750.0] align:#left width:150 scale:10.0
	
	button createPathGridButton "Create Path Grid"
	label dummyLabel14 " "
	label dummyLabel15 "----------"
	
	label dummyLabel16 "Chunk Grid Section Count:" align:#left
	spinner chunkGridSectionCountSpinner type:#integer range:[1, 128, 30] align:#left width:150
	
	label dummyLabel17 "Chunk Grid Cell Size:" align:#left
	spinner chunkGridCellSizeSpinner type:#float range:[10.0, 4000.0, 200.0] align:#left width:150 scale:10.0
	
	button createChunkGridButton "Create Chunk Grid"
	button createFlatPlaneButton "Create Flat Plane"
	label dummyLabel18 " "
	
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
		polyop.setFaceMatID obj (polyop.getFaceSelection obj) roadMaterialId
		$.insetType = 1
		$.insetAmount = halfRoadWidth
		$.EditablePoly.buttonOp #Inset
		polyop.setFaceMatID obj (polyop.getFaceSelection obj) sidewalkSideMaterialId
		$.extrusionType = 1
		$.faceExtrudeHeight = sidewalkHeight
		$.EditablePoly.ButtonOp #Extrude
		polyop.setFaceMatID obj (polyop.getFaceSelection obj) sidewalkTopMaterialId
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
		$.EditablePoly.selectByMaterial roadMaterialId
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
		$.EditablePoly.selectByMaterial roadMaterialId
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
		$.EditablePoly.selectByMaterial sidewalkTopMaterialId
		$.insetType = 0
		$.insetAmount = sidewalkWidth
		$.EditablePoly.buttonOp #Inset
		macros.run "Editable Polygon Object" "EPoly_Convert_Sel_To_Vertex"
		$.weldThreshold = sidewalkWidth * 0.5
		$.EditablePoly.weldFlaggedVertices ()
		$.EditablePoly.ShrinkSelection ()
		polyop.setFaceMatID obj (polyop.getFaceSelection obj) innerSpaceMaterialId
		subobjectLevel = 4
		$.EditablePoly.selectByMaterial innerSpaceMaterialId
		polyop.setFaceMatID obj (polyop.getFaceSelection obj) sidewalkSideMaterialId
		$.extrusionType = 0
		$.faceExtrudeHeight = -sidewalkHeight
		$.EditablePoly.buttonOp #Extrude
		polyop.setFaceMatID obj (polyop.getFaceSelection obj) innerSpaceMaterialId
		subobjectLevel = 1	
		PolyToolsSelect.NumericVertex 8 1 false
		tempArray1 = polyop.getVertSelection obj -- upper vertices
		subobjectLevel = 4
		$.EditablePoly.selectByMaterial innerSpaceMaterialId
		macros.run "Editable Polygon Object" "EPoly_Convert_Sel_To_Vertex"
		tempArray2 = polyop.getVertSelection obj -- lower vertices
		local maxDistance = sidewalkHeight + 0.01
		print "Finding bottom vertices for inner space..."
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
		$.EditablePoly.selectByMaterial sidewalkTopMaterialId
		macros.run "Editable Polygon Object" "EPoly_Convert_Sel_To_Vertex"
		$.weldThreshold = 0.001
		$.EditablePoly.weldFlaggedVertices ()
		$.EditablePoly.ConnectVertices ()
		
		if weldSidewalkTopCheckbox.checked then (
			subobjectLevel = 4
			$.EditablePoly.selectByMaterial sidewalkTopMaterialId
			macros.run "Editable Polygon Object" "EPoly_Convert_Sel_To_Vertex"
			$.EditablePoly.ShrinkSelection ()
			$.EditablePoly.Remove ()
			subobjectLevel = 4
			$.EditablePoly.selectByMaterial sidewalkTopMaterialId
			macros.run "Editable Polygon Object" "EPoly_Convert_Sel_To_Vertex"
			$.EditablePoly.ConnectVertices ()
		)

		if not useInnerSidewalkSideCheckbox.checked then (
			subobjectLevel = 4
			$.EditablePoly.selectByMaterial innerSpaceMaterialId
			macros.run "Editable Polygon Object" "EPoly_Convert_Sel_To_Edge"
			tempArray1 = polyop.getEdgeSelection obj
			$.EditablePoly.GrowSelection ()
			polyop.setEdgeSelection obj ((polyop.getEdgeSelection obj) - tempArray1)
			macros.run "Editable Polygon Object" "EPoly_Convert_Sel_To_Face"
			$.EditablePoly.delete #Face
			subobjectLevel = 4
			$.EditablePoly.selectByMaterial innerSpaceMaterialId
			move $.selectedFaces [0,0,sidewalkHeight]
		)
		
		subobjectLevel = 1
		actionMan.executeAction 0 "40021"
		$.EditablePoly.weldFlaggedVertices ()
		$.weldThreshold = 0.001
		subobjectLevel = 4
		$.EditablePoly.selectByMaterial innerSpaceMaterialId
		macros.run "Editable Polygon Object" "EPoly_Convert_Sel_To_Vertex"
		$.EditablePoly.ConnectVertices ()
		
		subobjectLevel = 4
		polyop.setFaceSmoothGroup obj #All 0
		
		if assignMaterialsCheckbox.checked then (
			$.EditablePoly.selectByMaterial roadMaterialId
			$.material = meditMaterials[roadMaterialId]
			$.EditablePoly.selectByMaterial sidewalkTopMaterialId
			$.material = meditMaterials[sidewalkTopMaterialId]
			$.EditablePoly.selectByMaterial sidewalkSideMaterialId
			$.material = meditMaterials[sidewalkSideMaterialId]
			$.EditablePoly.selectByMaterial innerSpaceMaterialId
			$.material = meditMaterials[innerSpaceMaterialId]
		)
		
		if removeInnerSpaceCheckbox.checked then (
			$.EditablePoly.selectByMaterial innerSpaceMaterialId
			$.EditablePoly.delete #Face
		)
		
		subobjectLevel = 0
		update obj
		messageBox ("Done.") title:"Info" beep:true
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
		local size = chunkGridSectionCountSpinner.value * chunkGridCellSizeSpinner.value 
		local obj = Plane length:size width:size pos:[0.0,0.0,-1] isSelected:on lengthsegs:1 widthsegs:1	
		convertToPoly obj
		selection.showFrozenInGray = false
		freeze obj
		update obj
	)
	
)

openUtility mapBuilderUtility