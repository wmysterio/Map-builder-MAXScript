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
	
	label dummyLabel16 "Chunk Grid Section Count:" align:#left
	spinner chunkGridSectionCountSpinner type:#integer range:[1, 128, 30] align:#left width:150
	
	label dummyLabel17 "Chunk Grid Cell Size:" align:#left
	spinner chunkGridCellSizeSpinner type:#float range:[10.0, 4000.0, 200.0] align:#left width:150 scale:10.0
	
	button createChunkGridButton "Create Chunk Grid"
	button createFlatPlaneButton "Create Flat Plane"
	button createFlatPlaneWithSegmentsButton "Create Flat Plane With Segments"
	label dummyLabel18 " "
	label dummyLabel15 "----------"
	
	label dummyLabel12 "Path Grid Section Count:" align:#left
	spinner pathGridSectionCountSpinner type:#integer range:[1, 64, 8] align:#left width:150
	
	label dummyLabel13 "Path Grid Cell Size:" align:#left
	spinner pathGridCellSizeSpinner type:#float range:[10.0, 4000.0, 750.0] align:#left width:150 scale:10.0
	
	button createPathGridButton "Create Path Grid"
	label dummyLabel14 " "
	
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
		
		local halfRoadWidth = halfRoadWidthSpinner.value 
		local sidewalkWidth = sidewalkWidthSpinner.value 
		local sidewalkHeight = sidewalkHeightSpinner.value 
		local sidewalkSideSegments = sidewalkSideSegmentsSpinner.value / 2
		local sidewalkHalfWidth = sidewalkWidth * 0.5
		local temp1 = #()
		
		maxOps.cloneNodes obj cloneType:#copy #nodialog
		
		obj.isHidden = false
		convertToPoly obj
		max modify mode
		
		-------------------------------
		
		subobjectLevel = 4
		polyop.setFaceSelection obj #All
		polyop.setFaceMatID obj (polyop.getFaceSelection obj) roadMaterialId
		$.insetType = 1
		$.insetAmount = halfRoadWidth
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
		$.faceExtrudeHeight = -halfRoadWidth
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
		local obj = Plane length:size width:size pos:[0.0,0.0,-1] isSelected:on lengthsegs:1 widthsegs:1	
		convertToPoly obj
		selection.showFrozenInGray = false
		freeze obj
		update obj
	)

	on createFlatPlaneWithSegmentsButton pressed do (
		local size = chunkGridCellSizeSpinner.value * chunkGridSectionCountSpinner.value
		local segments = (size / ((halfRoadWidthSpinner.value + sidewalkWidthSpinner.value) * 4.0)) as integer
		local obj = Plane length:size width:size pos:[0.0,0.0,0.0] isSelected:on lengthsegs:segments widthsegs:segments	
		convertToPoly obj
		selection.showFrozenInGray = false
		update obj
	)
	
)

openUtility mapBuilderUtility