/*
 * Fiji macro
 * Beta catenin quantification
 * Taras Sych
 * Yubing Guo
 * v 1.0
 * 
 */

run("Z Project...", "projection=[Max Intensity]");
rename("Raw_Data");
run("Split Channels");
selectWindow("C1-Raw_Data");
rename("Nuclei");
selectWindow("C2-Raw_Data");
rename("Beta_Cat");

selectWindow("Nuclei");
run("Smooth");
run("Smooth");
run("Smooth");

setAutoThreshold("Huang dark");
run("Analyze Particles...", "add");

selectWindow("Nuclei");
close();

N = roiManager("count");
Mean_inside = newArray(N);

run("Set Measurements...", "mean redirect=None decimal=3");


selectWindow("Beta_Cat");
for (i = 0; i < N; i++) {
	roiManager("Select", i);
	run("Measure");
	Mean_inside[i] = getResult("Mean", i);
}

Array.show(Mean_inside);
run("Select None");

selectWindow("Beta_Cat");
run("Duplicate...", " ");
rename("Beta_Cat_Mask");
run("Smooth");
run("Smooth");
run("Smooth");

for (i = 0; i < N; i++) {
	roiManager("Select", i);
	run("Clear");
}


run("Select None");

setAutoThreshold("Otsu dark");

run("Analyze Particles...", "add");