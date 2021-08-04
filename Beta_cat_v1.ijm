/*
 * Fiji macro
 * Beta catenin quantification
 * Taras Sych
 * Yubing Guo
 * v 1.0
 * 
 */

dir = getDirectory("image"); 
name = getTitle();
print(name);
setBatchMode(false);
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

Color_of_cell = newArray(N);





run("Set Measurements...", "mean redirect=None decimal=3");


selectWindow("Beta_Cat");
for (i = 0; i < N; i++) {
	roiManager("Select", i);
	run("Measure");
	Mean_inside[i] = getResult("Mean", i);
}

//Array.show(Mean_inside);
run("Select None");

selectWindow("Beta_Cat");
run("Duplicate...", " ");
rename("Beta_Cat_Mask");
run("Smooth");
run("Smooth");
run("Smooth");

for (i = 0; i < N; i++) {
	roiManager("Select", i);
	run("Colors...", "foreground=black background=black selection=black");
	run("Clear");
}


run("Select None");
//waitForUser("Threshold");
setAutoThreshold("Huang dark");

run("Analyze Particles...", "add");


N_1 = roiManager("count");

j = N;

run("Set Measurements...", "mean centroid redirect=None decimal=3");

Mean = newArray(N_1 - N);
x = newArray(N_1 - N);
y = newArray(N_1 - N);
Belongs_to = newArray(N_1 - N);

run("Clear Results");


while (j < N_1) {
	selectWindow("Beta_Cat");
	roiManager("Select", j);
	//print(j);
	run("Measure");
	j++;
	Mean[j-N-1] = getResult("Mean", 0);
	x[j-N-1] = getResult("X", 0);
	y[j-N-1] = getResult("Y", 0);
	
	
	run("Clear Results");
	
}

j = 0;
selectWindow("Beta_Cat");
getPixelSize (unit, pixelWidth, pixelHeight);

while (j < N_1-N){
	x_i = x[j];
	y_i = y[j];

	dist_min = 10000;
	cell = 0;
	for (i = 0; i < N; i++) {
		roiManager("Select", i);
		roiManager("rename", "cell " + i)
		getSelectionCoordinates(x_s, y_s);
		//Array.show(x_s, y_s);
		//hasldkjhldkasjhfjk
		
		for (k = 0; k < lengthOf(x_s); k++) {
			dist = sqrt(Math.sqr(x_s[k]*pixelWidth - x_i) + Math.sqr(y_s[k]*pixelWidth - y_i));
			if (dist < dist_min) {
				dist_min = dist;
				cell = i;
			}

		}

	}
	Belongs_to[j] = cell;
	roiManager("Select", j + N);
	roiManager("rename", cell)
	j++;
}




xl=File.open(dir+ File.separator+"Summary_" + name + ".xls");

print(xl, "cell number" + "\t" + "nucleus mean" + "\t" + "clusters");


line = "cell ";

line_all = "all" + "\t";
for (i = 0; i < N; i++) {
	line = line + i + "\t" + Mean_inside[i] + "\t";
	for (j = 0; j < lengthOf(Belongs_to); j++) {
		if (Belongs_to[j] == i) {
			line = line + Mean[j]/Mean_inside[i] + "\t";
			line_all = line_all +  Mean[j]/Mean_inside[i] + "\t";
			
		}
		
	}

print(xl, line);
line = "cell ";	
}

print(xl, line_all);
File.close(xl);


//----------------------------------Output of everything else
selectWindow(name);
close();

selectWindow("Beta_Cat_Mask");
close();
/*
for (i = 0; i < N; i++) {
	
	if (i%8 == 1) {
		Color_of_cell[i] = "blue";
	}

	if (i%8 == 2) {
		Color_of_cell[i] = "cyan";
	}

	if (i%8 == 3) {
		Color_of_cell[i] = "green";
	}

	if (i%8 == 4) {
		Color_of_cell[i] = "magenta";
	}

	if (i%8 == 5) {
		Color_of_cell[i] = "orange";
	}

	if (i%8 == 6) {
		Color_of_cell[i] = "red";
	}

	if (i%8 == 7) {
		Color_of_cell[i] = "white";
	}

	if (i%8 == 0) {
		Color_of_cell[i] = "yellow";
	}

}

selectWindow("Beta_Cat");
run("Grays");
run("RGB Color");

for (i = 0; i < N; i++) {

	roiManager("Select", i);
	color = Color_of_cell[i];
	
	run("Colors...", "foreground=color background=color selection=color");
	run("Line Width...", "line=3");
	run("Draw", "slice");
}*/

selectWindow("Beta_Cat");
close();


roiManager("Deselect");
roiManager("Delete");
waitForUser("done");



