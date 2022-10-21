Dialog.create("Alpha phase analysis"); //show dialog box
	Dialog.addMessage("Alpha phase analysis.", 15, "#000000");
	DistancesList = newArray("1", "2");
	Dialog.addRadioButtonGroup("In which slice are the particles in black?", DistancesList, 2, 1, "2");
	Dialog.addString("Input: ", "D:\\Desktop\\batch test\\A");
	Dialog.addString("Output: ", "D:\\Desktop\\batch test\\B");
	Dialog.addString("Classifier's path:", "D:\\Desktop\\classifier900C_01_1.model");
Dialog.show;


SliceParticlePosition = parseFloat(Dialog.getRadioButton);
InputPath = Dialog.getString() + File.separator;
OutputPath = Dialog.getString() + File.separator;
ClassifierPath = Dialog.getString();

filelist = getFileList(InputPath);

for (i = 0; i < lengthOf(filelist); i++) {
    if (endsWith(filelist[i], ".tif")) { 
        open(InputPath + filelist[i]);
        ImageName = File.nameWithoutExtension;
        ImageFileName = getTitle();
        
		run("Trainable Weka Segmentation");
		wait(1000);
		call("trainableSegmentation.Weka_Segmentation.loadClassifier", ClassifierPath);
		call("trainableSegmentation.Weka_Segmentation.getProbability");
		selectWindow("Probability maps");
		rename(ImageName + ".tif");
		
		if (SliceParticlePosition==2) {
			run("Next Slice [>]");
		}
		run("Delete Slice");
		
		run("Duplicate...", "title=" + ImageName + "_ProbMaps.tif");
		saveAs("Tiff", OutputPath + ImageName + "_ProbMaps.tif");
		close(ImageName + "_ProbMaps.tif");
		
		run("8-bit");
		setAutoThreshold("Default");
		run("Convert to Mask");
		close("Threshold");
		run("Duplicate...", "title=" + ImageName + "_Threshold.tif");
		saveAs("Tiff", OutputPath + ImageName + "_Threshold.tif");
		close(ImageName + "_Threshold.tif");

		close("Trainable Weka Segmentation v3.3.2");
		
		run("Measure");
		AreaFraction = getResult("%Area", 0);
		saveAs("Results", OutputPath + ImageName + "_AreaResults.csv");
		close("Results");		
		
		run("Particle Analyser", "surface_area feret enclosed_volume moments euler thickness ellipsoids min=1 max=Infinity surface_resampling=2 show_particle show_thickness surface=Gradient split=0.000 volume_resampling=2");
		wait(5000);
		
		selectWindow("Results");
		SumThicknessByArea = 0;
		SumArea = 0;
		for (row = 0; row < nResults; row++) {
		    Area = getResult("SA (µm²)", row);
		    Thickness = getResult("Thickness (µm)", row);
		    
		    ThicknessByArea = Area * Thickness;
		    setResult("ThicknessByArea", row, ThicknessByArea);
		    
		    SumThicknessByArea += ThicknessByArea;
		    SumArea += Area;
		}
		updateResults();

		ThicknessWeightedByArea = SumThicknessByArea/SumArea;
		setResult("SumThicknessByArea", 0, SumThicknessByArea);
		setResult("SumArea", 0, SumArea);
		setResult("ThicknessWeightedByArea", 0, ThicknessWeightedByArea);
		setResult("AreaFraction", 0, AreaFraction);
		
		saveAs("Results", OutputPath + ImageName + "_Results.csv");
		close("Results");
		
		selectWindow(ImageName + "_parts");
		saveAs("Tiff", OutputPath + ImageName + "_parts.tif");
		close(ImageName + "_parts.tif");

		selectWindow(ImageName + "_thickness");
		saveAs("Tiff", OutputPath + ImageName + "_thickness.tif");
		close(ImageName + "_thickness.tif");
		wait(300);
		close(ImageFileName);
	}
}

