//
// KinectCapture.pde
//
// Saves skeleton animation data from Kinect to file for later playback
//
// Clay Budin
// clay_budin@hotmail.com
// Mar 28 2018
// Rev: Jun 18 2018
//

import java.io.*;
import java.time.format.DateTimeFormatter;  
import java.time.LocalDateTime;

import KinectPV2.*;

KinectPV2 kinect;

ArrayList<Float> skelAnimData = new ArrayList<Float>();
int nAnimFrms = 0;
boolean isRec = false;

final float ELLIPSE_SIZE = 10.0;
final color SKEL_COLOR = color(0,0,255);

void setup() {
	size(1920, 1080, P3D);
	//size(1280, 800, P3D);
	//fullScreen(P3D);

	frameRate(30); //60);

	kinect = new KinectPV2(this);

	kinect.enableColorImg(true);
	kinect.enableSkeletonColorMap(true);

	kinect.init();
}


void draw() {
	background(0);

	//println(kinect.getColorImage().width + " x " + kinect.getColorImage().height);

	// obtain the color image from the kinect v2
	//image(kinect.getColorImage(), 0, 0, 1920, 1080);

	pushMatrix();

	// flip image to look correct - this will apply to skeleton drawing also
	translate(1920,0);
	scale(-1,1);

	// draw color image from Kinect
	//image(kinect.getColorImage(), -1920, 0);
	image(kinect.getColorImage(), 0, 0);

	// draw skeleton
	strokeWeight(1.0);
	ArrayList<KSkeleton> skeletonArray =  kinect.getSkeletonColorMap();
	int nSkel = skeletonArray.size();

	if (nSkel > 0)  {
	    KSkeleton skeleton = (KSkeleton) skeletonArray.get(0);

	    if (skeleton.isTracked())  {
			// get individual joints in skel
			// 26 joints
			KJoint[] joints = skeleton.getJoints();
			//println("Num joints: " + joints.length);

			if (isRec)  {
				for (int i = 0; i < joints.length; ++i)  {
					skelAnimData.add(joints[i].getX());
					skelAnimData.add(joints[i].getY());
					skelAnimData.add(joints[i].getZ());
				}
				++nAnimFrms;
			}

			drawBody(joints);
		}
	} else  {
		//println("NO SKELETON!!!");
		//skelAnimData.add(float(frameCount));
		//println("sketchPath() = " + sketchPath());
	}

	popMatrix();

	// draw axes
	pushMatrix();
	translate(width/2, height/2, 0);

	stroke(255,0,0);
	line(0,0,0, 100,0,0);
	stroke(0,255,0);
	line(0,0,0, 0,100,0);
	stroke(0,0,255);
	line(0,0,0, 0,0,100);

	popMatrix();

	fill(255, 0, 0);
	//text(frameRate + " " + skeleton.length, 10, height-10);
	//text(String.format("%.2f %d", frameRate, nSkel), 10, height-10);

	text(String.format("%.2f %d %d %s", frameRate, nSkel, nAnimFrms, isRec ? "RECORDING" : ""), 10, height-10);
}

/*
void keyPressed ()  {
	if (key == 's')  {
		//Float[] a = new Float[skelAnimData.size()];
		//a = skelAnimData.toArray(a);
		//Files.write(sketchPath() + "\\data\\skelAnimData.dat", a);

		try {
		    FileOutputStream fos = new FileOutputStream(sketchPath() + "\\data\\skelAnimData_" + System.currentTimeMillis() + ".dat");
		    DataOutputStream dos = new DataOutputStream(fos);  
		    for (Float f : skelAnimData)
		        dos.writeFloat(f); 
		    dos.close(); 
		} catch(Exception ex) {
		    ex.printStackTrace();
		}

		//exit();

		skelAnimData.clear();
		nAnimFrms = 0;
		isRec = false;

	} else if (key == 'r')
		isRec = !isRec;
}
*/

void mousePressed ()  {
	if (mouseButton == RIGHT)  {
		//Float[] a = new Float[skelAnimData.size()];
		//a = skelAnimData.toArray(a);
		//Files.write(sketchPath() + "\\data\\skelAnimData.dat", a);

		try {
		    FileOutputStream fos = new FileOutputStream(sketchPath() + "\\data\\skelAnimData_" + DateTimeFormatter.ofPattern("yyyy_MM_dd_HH_mm_ss").format(LocalDateTime.now()) + ".dat");
		    DataOutputStream dos = new DataOutputStream(fos);  
		    for (Float f : skelAnimData)
		        dos.writeFloat(f); 
		    dos.close(); 
		} catch(Exception ex) {
		    ex.printStackTrace();
		}

		println("Wrote " + skelAnimData.size() + " floats, " + (skelAnimData.size() / 3 / 26) + " skeletons");

		//exit();

		skelAnimData.clear();
		nAnimFrms = 0;
		isRec = false;

	} else if (mouseButton == LEFT)  {
		isRec = !isRec;
	} else if (mouseButton == CENTER)  {
		exit();
	}
}



// originally from SkeletonColor example

//DRAW BODY
void drawBody(KJoint[] joints) {
	drawBone(joints, KinectPV2.JointType_Head, KinectPV2.JointType_Neck);
	drawBone(joints, KinectPV2.JointType_Neck, KinectPV2.JointType_SpineShoulder);
	drawBone(joints, KinectPV2.JointType_SpineShoulder, KinectPV2.JointType_SpineMid);
	drawBone(joints, KinectPV2.JointType_SpineMid, KinectPV2.JointType_SpineBase);
	drawBone(joints, KinectPV2.JointType_SpineShoulder, KinectPV2.JointType_ShoulderRight);
	drawBone(joints, KinectPV2.JointType_SpineShoulder, KinectPV2.JointType_ShoulderLeft);
	drawBone(joints, KinectPV2.JointType_SpineBase, KinectPV2.JointType_HipRight);
	drawBone(joints, KinectPV2.JointType_SpineBase, KinectPV2.JointType_HipLeft);

	// Right Arm    
	drawBone(joints, KinectPV2.JointType_ShoulderRight, KinectPV2.JointType_ElbowRight);
	drawBone(joints, KinectPV2.JointType_ElbowRight, KinectPV2.JointType_WristRight);
	drawBone(joints, KinectPV2.JointType_WristRight, KinectPV2.JointType_HandRight);
	drawBone(joints, KinectPV2.JointType_HandRight, KinectPV2.JointType_HandTipRight);
	drawBone(joints, KinectPV2.JointType_WristRight, KinectPV2.JointType_ThumbRight);

	// Left Arm
	drawBone(joints, KinectPV2.JointType_ShoulderLeft, KinectPV2.JointType_ElbowLeft);
	drawBone(joints, KinectPV2.JointType_ElbowLeft, KinectPV2.JointType_WristLeft);
	drawBone(joints, KinectPV2.JointType_WristLeft, KinectPV2.JointType_HandLeft);
	drawBone(joints, KinectPV2.JointType_HandLeft, KinectPV2.JointType_HandTipLeft);
	drawBone(joints, KinectPV2.JointType_WristLeft, KinectPV2.JointType_ThumbLeft);

	// Right Leg
	drawBone(joints, KinectPV2.JointType_HipRight, KinectPV2.JointType_KneeRight);
	drawBone(joints, KinectPV2.JointType_KneeRight, KinectPV2.JointType_AnkleRight);
	drawBone(joints, KinectPV2.JointType_AnkleRight, KinectPV2.JointType_FootRight);

	// Left Leg
	drawBone(joints, KinectPV2.JointType_HipLeft, KinectPV2.JointType_KneeLeft);
	drawBone(joints, KinectPV2.JointType_KneeLeft, KinectPV2.JointType_AnkleLeft);
	drawBone(joints, KinectPV2.JointType_AnkleLeft, KinectPV2.JointType_FootLeft);

	drawJoint(joints, KinectPV2.JointType_HandTipLeft);
	drawJoint(joints, KinectPV2.JointType_HandTipRight);
	drawJoint(joints, KinectPV2.JointType_FootLeft);
	drawJoint(joints, KinectPV2.JointType_FootRight);

	drawJoint(joints, KinectPV2.JointType_ThumbLeft);
	drawJoint(joints, KinectPV2.JointType_ThumbRight);

	drawJoint(joints, KinectPV2.JointType_Head);
}

void drawJoint(KJoint[] joints, int jointType) {
	fill(SKEL_COLOR);
	stroke(SKEL_COLOR);
	pushMatrix();
	translate(joints[jointType].getX(), joints[jointType].getY(), joints[jointType].getZ());
	ellipse(0, 0, ELLIPSE_SIZE, ELLIPSE_SIZE);
	popMatrix();
}

void drawBone(KJoint[] joints, int jointType1, int jointType2) {
	fill(SKEL_COLOR);
	stroke(SKEL_COLOR);
	pushMatrix();
	translate(joints[jointType1].getX(), joints[jointType1].getY(), joints[jointType1].getZ());
	ellipse(0, 0, ELLIPSE_SIZE, ELLIPSE_SIZE);
	popMatrix();
	line(joints[jointType1].getX(), joints[jointType1].getY(), joints[jointType1].getZ(), joints[jointType2].getX(), joints[jointType2].getY(), joints[jointType2].getZ());

	//addBoneParticles(joints, jointType1, jointType2);
}


