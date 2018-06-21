//
// Capture.pde
//
// Working code to access my laptop's built-in camera when the standard Capture
//  functionality from the processing.video library wasn't working (camera.available()
//	was always false)
//
// This code comes from
//  https://github.com/processing/processing-video/issues/32
// and the links contained there
//	https://organicmonkeymotion.wordpress.com/2015/08/22/getting-webcams-working-in-processing/
//	http://webcam-capture.sarxos.pl/
// the blog posts mentions replacing webcam-capture-0.3.10.jar with
//  webcam-capture-0.3.11-20150713.101234-10.jar, but the link to the
//  newer file was broken.  The older version of the .jar file seems to
//  work fine
//

import com.github.sarxos.webcam.Webcam;
import com.github.sarxos.webcam.WebcamPanel;
import com.github.sarxos.webcam.WebcamResolution;

import java.awt.Dimension;
import java.awt.Image;
import java.awt.image.BufferedImage;

Webcam webcam;

void setup ()  {
	size(displayWidth, displayHeight);
	imageMode(CENTER);

	for (Webcam camlist : Webcam.getWebcams ()) {
		println(camlist.getName());
		for (Dimension res : camlist.getViewSizes()) println(res.toString());
	}

	webcam = Webcam.getDefault();
	//webcam = Webcam.getWebcamByName("iLook 300 0");

	webcam.setViewSize(WebcamResolution.VGA.getSize());
	webcam.open(true);
}


void draw ()  {
	BufferedImage cap = webcam.getImage();
	PImage screen = new PImage(cap.getWidth(),cap.getHeight(),PConstants.ARGB);
	cap.getRGB(0, 0, screen.width, screen.height, screen.pixels, 0, screen.width);
	screen.updatePixels();

	image(screen, width/2, height/2);
}
