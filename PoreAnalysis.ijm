/*  
 * 	Written by Nicolas Hing, 25.05.2022
 */

setTool("hand");

run("8-bit");

run("Set Measurements...", "area perimeter bounding fit shape feret's area_fraction stack redirect=None decimal=3");

//assign to "distance" the picture's lenght in px (dn: don't need)
getDimensions(distance, dn, dn, dn, dn);


PictureName=getTitle(); //get file name
WindowSacaleName = substring(PictureName, 0, lengthOf(PictureName)-4) + "-1.jpg" ;
//open file with the scale
ScalePath = File.getParent(File.getParent(getDirectory("image"))) + "\\";

open(ScalePath + PictureName);

Dialog.create(PictureName); //show dialog box
	Dialog.addMessage("Picture's characteristic:", 15, "#000000");
	DistancesList = newArray("5.58 mm", "2789.08 "  + fromCharCode(181) + "m", "1394.54 "  + fromCharCode(181) + "m"); //fromCharCode(181) = "µ"
	Dialog.addRadioButtonGroup("Known distance: ", DistancesList, 3, 1, "5.58");
	Dialog.addString("If not displayed: ", "");
Dialog.show;

//set results in variables
KnowDistanceUnit = Dialog.getRadioButton;
KnowDistanceString = Dialog.getString();
//if the case is NOT empty
if (KnowDistanceString != "") { 
	KnowDistanceUnit = KnowDistanceString;
}

//[0]: value, [1]: unit
KnowDistanceUnit = split(KnowDistanceUnit, " "); 

known = replace(KnowDistanceUnit[0], ",", ".");
unit = KnowDistanceUnit[1];

minArea = 60; //Later, for data processing 

if (KnowDistanceUnit[1] == "mm") {
	known = parseFloat(known)*1000;
	unit = fromCharCode(181) + "m";
	minArea = 300; //Later, for data processing 
}

if (unit == fromCharCode(181) + "m") { //do nothing
}

else {
	waitForUser("New unit detected or error." + "\n" + "Unit:" + unit + "\n" + "Clic <Cancel> and, restart or ask.");
}

selectWindow(PictureName);
run("Set Scale...", "distance=" + distance + " known=" + known + " pixel=1 unit=" + unit);

selectWindow(PictureName);
run("Threshold...");
setAutoThreshold("Default");
setThreshold(0, 0);
selectWindow(WindowSacaleName);
waitForUser("Waiting threshold", "If you click <Cancel>, you will have to restart.\nWhen threshold done, click <OK>.");
selectWindow(PictureName);
run("Convert to Mask");
close("Threshold");

close(WindowSacaleName); //Close file with the scale

PictureNumber=substring(PictureName,lengthOf(PictureName)-8,lengthOf(PictureName)-4); //get picture's numbers in file name
PathAndNumber=getDirectory("image") + PictureNumber; // "X:\...\" + ####

run("Measure");
AreaPoreFraction = getResult("%Area", 0); //get %Area
saveAs("Results", PathAndNumber + " pore fraction.csv");
close("Results");

run("Analyze Particles...", " show=Outlines display clear");
saveAs("Tiff", PathAndNumber + " drawing.tif");
close(PictureNumber + " drawing.tif");

saveAs("Results", PathAndNumber + " pore analysis.csv");

updateResults();

//Data processing//
Table.sort("Area");

if (isOpen(PictureNumber + " pore analysis.csv")) {
	selectWindow("Log");
	waitForUser("Finish the script without pasting results in Excel, then restart it.");
}

if (parseFloat(Table.getString("Area",nResults-1)) < minArea) {
	close(PictureName);
	close("Results");
	String.copy(AreaPoreFraction);
	waitForUser("All area value are under " + minArea + "\n \n" + "Pore fraction value copied. \nValue: " + AreaPoreFraction + "\n \nClic on <Cancel>.");
}

row=0;

while (parseFloat(Table.getString("Area",row)) < minArea) {
	row ++;
}
Table.deleteRows(0, row-1);

SumArea=0;
SumFeretAreaWeighted=0;
SumMinFeretAreaWeighted=0;

for (row=0; row<nResults; row++) {
	Area=getResult("Area", row);
	Feret=getResult("Feret", row);
	MinFeret=getResult("MinFeret", row);
	
	FeretAreaWeighted = Area * Feret;
	MinFeretAreaWeighted = Area * MinFeret;
	setResult("FeretAreaWeighted", row, FeretAreaWeighted);
    setResult("MiniFeretAreaWeighted", row, MinFeretAreaWeighted);
    
    SumArea += Area;
    SumFeretAreaWeighted += FeretAreaWeighted;
    SumMinFeretAreaWeighted += MinFeretAreaWeighted;
}

SumFeretDivided = SumFeretAreaWeighted/SumArea;
SumMinFeretDivided = SumMinFeretAreaWeighted/SumArea;

setResult("SumFeretDivided", 0, SumFeretDivided);
setResult("SumMinFeretDivided", 0, SumMinFeretDivided);

updateResults();

saveAs("Results", PathAndNumber + " pore analysis only large pore.csv");

//Result in the clipboard
String.copy(AreaPoreFraction);
waitForUser("Pore fraction value copied. \nValue: " + AreaPoreFraction); // "\n": new line

String.copy(SumMinFeretDivided);
waitForUser("Pore Min Feret value copied. \nValue: " + SumMinFeretDivided + "\n \nNext: Pore Maximum Feret. \nValue: " + SumFeretDivided);

String.copy(SumFeretDivided);

close("Results"); //Close table

close(PictureName); //Close picture
