//
// KinectImage_mac_v1.pde
//
// Version for Mac using Kinect v1
//
// Notes:
// Need to download OpenKinect-for-Processing library from:
//  https://github.com/shiffman/OpenKinect-for-Processing/releases
// Then unzip and move folder into libraries folder in Sketchbook
//
// Clay Budin
// clay_budin@hotmail.com
// Jun 20 2018
//

// https://github.com/shiffman/OpenKinect-for-Processing
// http://shiffman.net/p5/kinect/

import org.openkinect.freenect.*;
import org.openkinect.processing.*;


Kinect kinect;


void setup() {
	size(640, 480, P3D);
	//fullScreen(P3D);

	frameRate(30); //60);

	kinect = new Kinect(this);

	kinect.initVideo();
	kinect.initDepth();
	kinect.enableColorDepth(false);

	background(0);
}


void draw() {
	//background(0, .05);

	pushMatrix();

	// flip image to look correct
	translate(640,0);
	scale(-1,1);

	// draw color image from Kinect
	//image(kinect.getVideoImage(), 0, 0);
	//image(kinect.getDepthImage(), 0, 0);

/*
	PImage d = kinect.getDepthImage();
	image(d,0,0);
*/

	PImage img = kinect.getVideoImage();
  //println("img.width = " + img.width + " height = " + img.height);

	img.filter(POSTERIZE, 3);

	// add crazy rotation
	translate(320,240);
	rotate(.25*sin(frameCount*.05));
	translate(-320,-240);

  // draw current image on top of previous images with very high transparency
	tint(255, 4); //8);
	image(img, 0,0);

	popMatrix();


	text(String.format("%.2f", frameRate), 10, height-10);
}
