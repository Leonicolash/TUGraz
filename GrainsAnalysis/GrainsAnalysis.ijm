ImageName = getTitle();
ImagePath = getDirectory("image");


run("8-bit");
setAutoThreshold("Default");
setOption("BlackBackground", true);
run("Convert to Mask");
run("Set Scale...", "distance=177.5 known=500 unit=µm");

getDimensions(width, height, dn, dn, dn);
makeRectangle(0, 0, width, height-75);
run("Crop");

run("Analyze Particles...", "  show=Ellipses display exclude");

Array.getStatistics(Table.getColumn("AR"), dn, dn, ARmean, dn);
Array.getStatistics(Table.getColumn("Feret"), dn, dn, MeanFeret, dn);
GSferet = MeanFeret/sqrt(2);

setResult("ARmean", 0, ARmean);
setResult("GSferet", 0, GSferet);

updateResults();

SumArea = 0;
SumGSiWeightedByArea = 0;

for (row=0; row<nResults; row++) {
	Area=getResult("Area", row);
	Major=getResult("Major", row);
	Minor=getResult("Minor", row);
	
	GSi=sqrt((pow(Minor, 2) + pow(Major, 2))/2);
	GSiWeightedByArea=GSi*Area;
	
	setResult("GSi", row, GSi);
	setResult("GSiWeightedByArea", row, GSiWeightedByArea);
	
    SumArea += Area;
    SumGSiWeightedByArea += GSiWeightedByArea;
}
updateResults();

setResult("SumArea", 0, SumArea);
setResult("SumGSiWeightedByArea", 0, SumGSiWeightedByArea);
setResult("GSmeanAreaFraction", 0, SumGSiWeightedByArea/SumArea);

Array.getStatistics(Table.getColumn("GSi"), dn, dn, GSmeanNumFrac, stdGSmeanNF);
setResult("GSmeanNumFrac", 0, GSmeanNumFrac);
setResult("stdGSmeanNF", 0, stdGSmeanNF);

updateResults();

close(ImageName);


selectWindow("Drawing of " + ImageName);
ResultPath = File.getParent(ImagePath) + "\\Analysis\\";
saveAs("tiff", ResultPath + substring(ImageName, 0, lengthOf(ImageName)-4) + "_Drawing.tif");
run("Close");

selectWindow("Results");
saveAs("Results", ResultPath + substring(ImageName, 0, lengthOf(ImageName)-4) + "_Results.csv");
close("Results");