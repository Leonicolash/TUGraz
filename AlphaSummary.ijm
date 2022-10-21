InputPath = getDirectory("Choose a Directory");
FileList = getFileList(InputPath);

Table.create("AlphaAnalysisSummary.csv");
Table.save(InputPath + "AlphaAnalysisSummary.csv");


for (i = 0; i < lengthOf(FileList); i++) {
	if (endsWith(FileList[i], "/")) {
		Class = getFileList(InputPath + FileList[i]);
		for (j = 0; j < lengthOf(Class); j++) {
			
			if (endsWith(Class[j], "_Results.csv")) {
				GetAndSet(InputPath + FileList[i], Class[j]);
				updateResults();
			}
			
		}
	}
}

close("Results");




function GetAndSet(ResultsTablePath, ResultsTable) { 
	open(ResultsTablePath + ResultsTable);

	AreaFraction = getResult("AreaFraction", 0);
	SumThiscknessByArea = getResult("SumThicknessByArea", 0);
	SumArea = getResult("SumArea", 0);
	ThicknnessWeightedByArea = getResult("ThicknessWeightedByArea", 0);
	
	close(ResultsTable);
	
	PicNameSplitted = split(substring(ResultsTable, 0, lengthOf(ResultsTable)-4), "_");
	SampleNum = PicNameSplitted[1];
	DeformationTemperature = PicNameSplitted[2];
	StrainRate = PicNameSplitted[3];
	Strain = PicNameSplitted[4];
	Zone = PicNameSplitted[5];
	PicNum = PicNameSplitted[8];

	selectWindow("AlphaAnalysisSummary.csv");
	Table.set("File name", Table.size, substring(ResultsTable, 0, lengthOf(ResultsTable)-12) + ".tif");
	Table.set("Sample number", Table.size-1, substring(SampleNum, 1, lengthOf(SampleNum)));
	Table.set("Deformation temperature (°C)", Table.size-1, substring(DeformationTemperature, 0, lengthOf(DeformationTemperature)-2));
	Table.set("Strain rate (s-1)", Table.size-1, substring(StrainRate, 0, lengthOf(StrainRate)-3));
	Table.set("Strain", Table.size-1, substring(Strain, 6, lengthOf(Strain)));
	Table.set("Zone", Table.size-1, Zone);
	Table.set("Picture number", Table.size-1, PicNum);
	
	Table.set("Area fraction (%)", Table.size-1, AreaFraction);
	Table.set("Sum thickness by area", Table.size-1, SumThiscknessByArea);
	Table.set("Sum area", Table.size-1, SumArea);
	Table.set("Thickness weighted by area (micron)", Table.size-1, ThicknnessWeightedByArea);
	
	Table.save(InputPath + "AlphaAnalysisSummary.csv");
}

