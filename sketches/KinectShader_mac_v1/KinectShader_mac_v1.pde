//
// KinectShader_mac_v1.pde
//
// Version for Mac and Kinect v1
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


import org.openkinect.freenect.*;
import org.openkinect.processing.*;

Kinect kinect;

PShader kShader;


void setup() {
	size(640, 480, P3D);
	//fullScreen(P3D);

	frameRate(30); //60);

	kinect = new Kinect(this);

	kinect.initVideo();

	kShader = loadShader("brcosa.glsl");
}


void draw() {
	//background(0, .05);

  // mouse position controls shader settings
  kShader.set("brightness", 1.0);
  kShader.set("contrast", map(mouseX, 0, width, -5, 5));
  kShader.set("saturation", map(mouseY, 0, height, -5, 5));
	shader(kShader);

	pushMatrix();

	// flip image to look correct
	translate(640,0);
	scale(-1,1);

	// draw color image from Kinect through shader
	image(kinect.getVideoImage(), 0, 0);

	popMatrix();

	text(String.format("%.2f", frameRate), 10, height-10);
}
