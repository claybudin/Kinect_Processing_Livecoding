//
// KinectShader.pde
//
// Clay Budin
// clay_budin@hotmail.com
// Jun 20 2018
//


import KinectPV2.*;

KinectPV2 kinect;

PShader kShader;


void setup() {
	size(1920, 1080, P3D);
	//size(1280, 800, P3D);
	//fullScreen(P3D);

	frameRate(30); //60);

	kinect = new KinectPV2(this);

	kinect.enableColorImg(true);
	kinect.enableSkeletonColorMap(false);

	kinect.init();

	kShader = loadShader("brcosa.glsl");
}


void draw() {
	//background(0, .05);

    kShader.set("brightness", 1.0);
    kShader.set("contrast", map(mouseX, 0, width, -5, 5));
    kShader.set("saturation", map(mouseY, 0, height, -5, 5));
	shader(kShader);

	pushMatrix();

	// flip image to look correct
	translate(1920,0);
	scale(-1,1);

	// draw color image from Kinect through shader
	image(kinect.getColorImage(), 0, 0);

	popMatrix();


	text(String.format("%.2f", frameRate), 10, height-10);
}

void mousePressed ()  {
	if (mouseButton == RIGHT)  {
	} else if (mouseButton == LEFT)  {
	} else if (mouseButton == CENTER)  {
		exit();
	}
}
