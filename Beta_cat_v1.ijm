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
	print(j);
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


for (i = 0; i < N; i++) {
	line = line + i + "\t" + Mean_inside[i] + "\t";
	for (j = 0; j < lengthOf(Belongs_to); j++) {
		if (Belongs_to[j] == i) {
			line = line + Mean[j] + "\t";
			
		}
		
	}

print(xl, line);
line = "cell ";	
}





File.close(xl);

/*Array.show(x);
Array.show(y);
Array.show(Mean);*/
/*
roiManager("Select", 0);
getSelectionCoordinates(x, y);

Array.show(x);
Array.show(y);*/






