// Face It
// ITP Fall 2013
// Daniel Shiffman
//
// Re-write of LiveFaceDetect.pde from Dan Shiffman's Face-It project, using
//  new webcam caputre system since processing.video Capture is not working for me.
// Oreiginal source from here:
//  https://github.com/shiffman/Face-It
//

// Now we need the video library
//import processing.video.*;
import com.github.sarxos.webcam.Webcam;
import com.github.sarxos.webcam.WebcamPanel;
import com.github.sarxos.webcam.WebcamResolution;
import java.awt.Dimension;
import java.awt.Image;
import java.awt.image.BufferedImage;


// Import the library
import gab.opencv.*;

// We need Java rectangles
import java.awt.Rectangle;

// Library object
OpenCV opencv;

// Capture object
//Capture cam;
Webcam webcam;
PImage capImg;

// Array of faces found
Rectangle[] faces;

void setup() {
  //size(320, 240,P2D);
  size(640,480,P2D);
  
  // Start capturing
  //cam = new Capture(this, 320, 240);
  // cam = new Capture(this, 640,480);
  // cam.start();

  webcam = Webcam.getDefault();
  webcam.setViewSize(WebcamResolution.VGA.getSize());
  webcam.open(true);

  capImg = new PImage(width, height, PConstants.ARGB);

  // Create the OpenCV object
  //opencv = new OpenCV(this, cam.width, cam.height);
  opencv = new OpenCV(this, width, height);
  
  // Which "cascade" are we going to use?
  opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE);  
  //opencv.loadCascade(OpenCV.CASCADE_EYE);  
  //opencv.loadCascade(OpenCV.CASCADE_NOSE);    
}

// New images from camera
// void captureEvent(Capture cam) {
//   cam.read();
// }

void draw () {
  background(0);
  
  BufferedImage cap = webcam.getImage();
  cap.getRGB(0, 0, capImg.width, capImg.height, capImg.pixels, 0, capImg.width);
  capImg.updatePixels();

  // We have to always "load" the camera image into OpenCV 
  //opencv.loadImage(cam);
  opencv.loadImage(capImg);
  
  // Detect the faces
  faces = opencv.detect();
  
  // Draw the video
  //image(cam, 0, 0);
  image(capImg, 0, 0);

  // If we find faces, draw them!
  if (faces != null) {
    for (int i = 0; i < faces.length; i++) {
      strokeWeight(2);
      stroke(255,0,0);
      noFill();
      rect(faces[i].x, faces[i].y, faces[i].width, faces[i].height);
    }
  }
}

