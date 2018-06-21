//
// KinectImage.pde
//
// Clay Budin
// clay_budin@hotmail.com
// Jun 20 2018
//


import KinectPV2.*;

KinectPV2 kinect;


void setup() {
	//size(1920, 1080, P3D);
	//size(1280, 800, P3D);
	fullScreen(P3D);

	frameRate(30); //60);

	kinect = new KinectPV2(this);

	kinect.enableColorImg(true);
	kinect.enableDepthImg(true);
	kinect.enableSkeletonColorMap(false);

	kinect.init();

	background(0);
}


void draw() {
	//background(0, .05);

	pushMatrix();

	// flip image to look correct - this will apply to skeleton drawing also
	translate(1920,0);
	scale(-1,1);

	// draw color image from Kinect
	//image(kinect.getColorImage(), 0, 0);
	//image(kinect.getDepthImage(), 0, 0);

/*
	PImage d = kinect.getDepthImage();
	d.resize(1920,1080);
	image(d,0,0);
*/

	PImage img = kinect.getColorImage();


	img.filter(POSTERIZE, 3);

	// add crazy rotation
	translate(960,540);
	rotate(.25*sin(frameCount*.05));
	translate(-960,-540);


	tint(255, 4); //8);
	image(img, 0,0);

	popMatrix();


	text(String.format("%.2f", frameRate), 10, height-10);
}


