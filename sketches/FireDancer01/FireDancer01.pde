//
// FireDancer01.pde
//
// Live particle overlay for dancer via Kinect v2
//
// Clay Budin
// clay_budin@hotmail.com
// Mar 28 2018
// Rev: Jun 18 2018
//
// TO DO:
//	add arbitrary background image or movie
//	depth comp of dancer over BG
//	particles start in direction normal to bone
//



import java.io.*;
import java.time.format.DateTimeFormatter;  
import java.time.LocalDateTime;


import controlP5.*;
import KinectPV2.*;

ControlP5 cp5;

KinectPV2 kinect;

ArrayList<P> ps = new ArrayList<P>();

final boolean KINECT_LIVE = true; //true or false;
final String REPLAY_FILE = "skelAnimData_1520819418196.dat";

final int NUM_JOINTS = 26;
final int NUM_JOINT_FLOATS = NUM_JOINTS * 3;

ArrayList<Float> skelAnimData = new ArrayList<Float>();
int nAnimFrms = 0;
int curFrm = 0;

float[] jointData = new float[NUM_JOINTS * 3];

ArrayList<Float> pf = new ArrayList<Float>();

boolean showGUI = false;
final int GUI_X = 10, GUI_Y = 10, GUI_W = 200, GUI_H = 20, GUI_SPACING = 25;
int nGUI = 0;

final float ELLIPSE_SIZE = 10.0;
final color SKEL_COLOR = color(0,0,255);


// parameters controlled by GUI
boolean show_background = true;
boolean show_skeletons = !KINECT_LIVE;
boolean show_axes = false;
boolean show_framerate = true;
boolean head = true, arms = true, hips = true, legs = true;
boolean draw_points = true;
float bg_tint = 128.0;
float particle_size = 5.0;
float particle_life = 25.0;
float particle_density = 1.0;
float particle_min_speed = .5;
float particle_max_speed = 1.25;
float particle_dir_var = .1;
float particle_color_speed = 1.0;
float particle_alpha = 1.0;
float gravity = 0.0;
float particle_hue_min = 0.0;
float particle_hue_max = 60.0;
float particle_sat = .75;
float particle_val = 1.0;


// setup() is called once at the start of the sketch
void setup() {
	// size of display window and/or projector
	size(1920, 1080, P3D);		// native Kinect color image
	//size(1280, 800, P3D);
	//fullScreen(P3D);

	frameRate(30); //60);

	// initialize Kinect if live, or load one of the recorded animations
	if (KINECT_LIVE)  {
		kinect = new KinectPV2(this);

		kinect.enableColorImg(true);
		kinect.enableSkeletonColorMap(true);
		kinect.init();
	} else  {
		try {
			FileInputStream fis = new FileInputStream(dataPath(REPLAY_FILE));
			DataInputStream dis = new DataInputStream(fis);
			try {
				while (true)
					skelAnimData.add(dis.readFloat());
			} catch (EOFException e)  {
			}
			dis.close();

			println("Read " + skelAnimData.size() + " floats, " + (skelAnimData.size() / NUM_JOINT_FLOATS) + " skeleton frames");
			nAnimFrms = (skelAnimData.size() / NUM_JOINT_FLOATS);
		} catch (Exception ex) {
			ex.printStackTrace();
		}
	}


	// setup GUI
	cp5 = new ControlP5(this);
	cp5.setAutoDraw(false);

	cp5.addToggle("show_background").setPosition(GUI_X, GUI_Y+GUI_SPACING*nGUI++).setSize(GUI_H, GUI_H).getCaptionLabel().align(ControlP5.RIGHT_OUTSIDE, ControlP5.CENTER).setPaddingX(3);
	cp5.addToggle("show_skeletons").setPosition(GUI_X, GUI_Y+GUI_SPACING*nGUI++).setSize(GUI_H, GUI_H).getCaptionLabel().align(ControlP5.RIGHT_OUTSIDE, ControlP5.CENTER).setPaddingX(3);
	cp5.addToggle("show_axes").setPosition(GUI_X, GUI_Y+GUI_SPACING*nGUI++).setSize(GUI_H, GUI_H).getCaptionLabel().align(ControlP5.RIGHT_OUTSIDE, ControlP5.CENTER).setPaddingX(3);
	cp5.addToggle("show_framerate").setPosition(GUI_X, GUI_Y+GUI_SPACING*nGUI++).setSize(GUI_H, GUI_H).getCaptionLabel().align(ControlP5.RIGHT_OUTSIDE, ControlP5.CENTER).setPaddingX(3);

	cp5.addToggle("head").setPosition(GUI_X, GUI_Y+GUI_SPACING*nGUI).setSize(GUI_H, GUI_H).getCaptionLabel().align(ControlP5.RIGHT_OUTSIDE, ControlP5.CENTER).setPaddingX(3);
	cp5.addToggle("arms").setPosition(GUI_X+50, GUI_Y+GUI_SPACING*nGUI).setSize(GUI_H, GUI_H).getCaptionLabel().align(ControlP5.RIGHT_OUTSIDE, ControlP5.CENTER).setPaddingX(3);
	cp5.addToggle("hips").setPosition(GUI_X+100, GUI_Y+GUI_SPACING*nGUI).setSize(GUI_H, GUI_H).getCaptionLabel().align(ControlP5.RIGHT_OUTSIDE, ControlP5.CENTER).setPaddingX(3);
	cp5.addToggle("legs").setPosition(GUI_X+150, GUI_Y+GUI_SPACING*nGUI).setSize(GUI_H, GUI_H).getCaptionLabel().align(ControlP5.RIGHT_OUTSIDE, ControlP5.CENTER).setPaddingX(3);
	++nGUI;

	cp5.addToggle("draw_points").setPosition(GUI_X, GUI_Y+GUI_SPACING*nGUI++).setSize(GUI_H, GUI_H).getCaptionLabel().align(ControlP5.RIGHT_OUTSIDE, ControlP5.CENTER).setPaddingX(3);

	cp5.addSlider("bg_tint").setPosition(GUI_X, GUI_Y+GUI_SPACING*nGUI++).setRange(0.0,255.9).setSize(GUI_W, GUI_H);
	cp5.addSlider("particle_size").setPosition(GUI_X, GUI_Y+GUI_SPACING*nGUI++).setRange(.1,20.0).setSize(GUI_W, GUI_H);
	cp5.addSlider("particle_life").setPosition(GUI_X, GUI_Y+GUI_SPACING*nGUI++).setRange(2.0,100.0).setSize(GUI_W, GUI_H);
	cp5.addSlider("particle_density").setPosition(GUI_X, GUI_Y+GUI_SPACING*nGUI++).setRange(.1,10.0).setSize(GUI_W, GUI_H);
	cp5.addSlider("particle_min_speed").setPosition(GUI_X, GUI_Y+GUI_SPACING*nGUI++).setRange(.1,5.0).setSize(GUI_W, GUI_H);
	cp5.addSlider("particle_max_speed").setPosition(GUI_X, GUI_Y+GUI_SPACING*nGUI++).setRange(.1,5.0).setSize(GUI_W, GUI_H);
	cp5.addSlider("particle_dir_var").setPosition(GUI_X, GUI_Y+GUI_SPACING*nGUI++).setRange(0.0,25.0).setSize(GUI_W, GUI_H);
	cp5.addSlider("particle_color_speed").setPosition(GUI_X, GUI_Y+GUI_SPACING*nGUI++).setRange(.1,5.0).setSize(GUI_W, GUI_H);
	cp5.addSlider("particle_alpha").setPosition(GUI_X, GUI_Y+GUI_SPACING*nGUI++).setRange(.01,1.0).setSize(GUI_W, GUI_H);
	cp5.addSlider("gravity").setPosition(GUI_X, GUI_Y+GUI_SPACING*nGUI++).setRange(0.0,10.0).setSize(GUI_W, GUI_H);
	cp5.addSlider("particle_hue_min").setPosition(GUI_X, GUI_Y+GUI_SPACING*nGUI++).setRange(0.0,360.0).setSize(GUI_W, GUI_H);
	cp5.addSlider("particle_hue_max").setPosition(GUI_X, GUI_Y+GUI_SPACING*nGUI++).setRange(0.0,720.0).setSize(GUI_W, GUI_H);
	cp5.addSlider("particle_sat").setPosition(GUI_X, GUI_Y+GUI_SPACING*nGUI++).setRange(0.0,1.0).setSize(GUI_W, GUI_H);
	cp5.addSlider("particle_val").setPosition(GUI_X, GUI_Y+GUI_SPACING*nGUI++).setRange(0.0,1.0).setSize(GUI_W, GUI_H);

	cp5.addButton("save_settings").setPosition(GUI_X, GUI_Y+GUI_SPACING*nGUI++).setSize(GUI_H*4, GUI_H);
	cp5.addButton("save_image").setPosition(GUI_X, GUI_Y+GUI_SPACING*nGUI++).setSize(GUI_H*4, GUI_H);
	cp5.addButton("quit").setPosition(GUI_X, GUI_Y+GUI_SPACING*nGUI++).setSize(GUI_H*4, GUI_H);
}


// draw() is called every frame of the sketch
void draw() {
	background(0);

	pushMatrix();

	// flip image to look correct - this will apply to skeleton drawing also
	//scale(.7);	// adjust for 1280x800 projector
	translate(1920,0);
	scale(-1,1);

	// draw color image from Kinect v2
	if (KINECT_LIVE && show_background)  {
		//println(kinect.getColorImage().width + " x " + kinect.getColorImage().height);
		tint(int(bg_tint));
		image(kinect.getColorImage(), 0, 0);
		noTint();
	}

	// draw skeleton
	strokeWeight(1.0);
	float sx = -1.0, sy = -1.0, sz = -1.0;
	int nSkel = 1;

	if (KINECT_LIVE)  {
		ArrayList<KSkeleton> skeletonArray =  kinect.getSkeletonColorMap();

		nSkel = 0;
		for (int i = 0; i < skeletonArray.size(); ++i)  {
			KSkeleton skeleton = (KSkeleton) skeletonArray.get(i);
			if (skeleton.isTracked())  {
				// get the joint values from this skeleton
				KJoint[] joints = skeleton.getJoints();

				for (int j = 0; j < NUM_JOINTS; ++j)  {
					int idx = 3*j;
					jointData[idx+0] = joints[j].getX();
					jointData[idx+1] = joints[j].getY();
					jointData[idx+2] = joints[j].getZ();
				}

				if (show_skeletons) drawSkeleton();
				addSkelParticles();

				++nSkel;

				// store center of first skeleton - not used
				if (nSkel == 1)  {
					sx = joints[KinectPV2.JointType_SpineBase].getX();
					sy = joints[KinectPV2.JointType_SpineBase].getY();
					sz = joints[KinectPV2.JointType_SpineBase].getZ();
				}
			}
		}
	} else  {
		int idx = curFrm * NUM_JOINT_FLOATS;
		for (int i = 0; i < NUM_JOINT_FLOATS; ++i)
			jointData[i] = skelAnimData.get(idx+i);

		if (show_skeletons) drawSkeleton();
		addSkelParticles();

		sx = jointData[KinectPV2.JointType_SpineBase*3+0];
		sy = jointData[KinectPV2.JointType_SpineBase*3+1];
		sz = jointData[KinectPV2.JointType_SpineBase*3+2];
	}

	// draw particles
	strokeWeight(particle_size);

	// update all the particles
	for (int i = ps.size()-1; i > 0; --i)  {
		P p = ps.get(i);
		if (p.update())  {
			// here we draw the particle - experiment with different methods of drawing

			if (draw_points)  {
				// draw as a point
				p.draw();
			} else  {
				// store points until we accumulate 8 and then draw them as a line
				pf.add(p.p.x);
				pf.add(p.p.y);
				pf.add(p.p.z);
				if (pf.size() >= 8*3)  {
					stroke(p.c);
					noFill();

					for (int l = 0; l <= pf.size()/3; l += 3)
						line(pf.get(l*3+0),pf.get(l*3+1),pf.get(l*3+2), pf.get((l+1)*3+0),pf.get((l+1)*3+1),pf.get((l+1)*3+2));

					// for (int l = 1; l < (pf.size()/3)-1; l += 3)
					// 	bezier(pf.get((l-1)*3+0),pf.get((l-1)*3+1),pf.get((l-1)*3+2),
					// 		pf.get(l*3+0),pf.get(l*3+1),pf.get(l*3+2),
					// 		pf.get((l+1)*3+0),pf.get((l+1)*3+1),pf.get((l+1)*3+2),
					// 		pf.get((l+2)*3+0),pf.get((l+2)*3+1),pf.get((l+2)*3+2));

					pf.clear();
				}
			}
		} else
			ps.remove(i);
	}


	popMatrix();	// this matches pushMatrix() above

	if (show_axes)  {
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
	}

	if (showGUI)  {
		stroke(255);
		strokeWeight(1);
		fill(0,64);
		rect(GUI_X-10, GUI_Y-10, GUI_X+GUI_W+100, GUI_Y+nGUI*GUI_SPACING+10);
		cp5.draw();
	}

	if (show_framerate)  {
		fill(255, 0, 0);
		text(String.format("%.2f %d %d %.2f %.2f %.2f", frameRate, nSkel, curFrm, sx,sy,sz), 10, height-10);
	}

	++curFrm;
	if (!KINECT_LIVE && curFrm >= nAnimFrms) curFrm = 0;
}


void mousePressed ()  {
	// if (mouseButton == CENTER)  {
	// 	exit();
	// }
	if (mouseButton == RIGHT)  {
		showGUI ^= true;
	}
}

void save_settings ()  {
	//println("save_settings()");
	try {
		//PrintWriter out = new PrintWriter(sketchPath() + "/settings/settings_" + System.currentTimeMillis() + ".dat");
		PrintWriter out = new PrintWriter(sketchPath() + "/settings/settings_" + DateTimeFormatter.ofPattern("yyyy_MM_dd_HH_mm_ss").format(LocalDateTime.now()) + ".dat");
		out.println("particle_size = " + particle_size);
		out.println("particle_life = " + particle_life);
		out.println("particle_density = " + particle_density);
		out.println("particle_min_speed = " + particle_min_speed);
		out.println("particle_max_speed = " + particle_max_speed);
		out.println("particle_dir_var = " + particle_dir_var);
		out.println("particle_color_speed = " + particle_color_speed);
		out.println("particle_alpha = " + particle_alpha);
		out.println("gravity = " + gravity);
		out.println("particle_hue_min = " + particle_hue_min);
		out.println("particle_hue_max = " + particle_hue_max);
		out.println("particle_sat = " + particle_sat);
		out.println("particle_val = " + particle_val);
		out.close();
	} catch(Exception ex) {
		ex.printStackTrace();
	}
}

void save_image ()  {
	saveFrame(String.format("frm/Dancer01_%s.png", DateTimeFormatter.ofPattern("yyyy_MM_dd_HH_mm_ss").format(LocalDateTime.now())));
}

void quit ()  {
	exit();
}




// fire particle
class P  {
	PVector p, v;
	color c;
	int l;

	P (float _x, float _y, float _z)  {
		p = new PVector(_x, _y, _z);
		v = new PVector(0, -10*random(particle_min_speed, particle_max_speed), 0);	// negative is up
		v.add(sphRand().mult(particle_dir_var));
		//c = color(255, 128+128*sin(frameCount/30.0*particle_color_speed), 64, int(random(particle_alpha*.5, particle_alpha) * 255.999));
		float ct = .5 + .5*sin(frameCount/30.0*particle_color_speed);
		c = hsv2rgb(particle_hue_min+ct*(particle_hue_max-particle_hue_min), particle_sat, particle_val, int(random(particle_alpha*.5, particle_alpha) * 255.999));
		l = 0;
	}

	boolean update ()  {
		v.add(0, gravity*.1, 0);
		p.add(v);
		return (++l <= particle_life);
	}

	void draw ()  {
		stroke(c);
		point(p.x,p.y,p.z);
	}
};



void addSkelParticles ()  {
	if (arms)  {
		addBoneParticles(KinectPV2.JointType_SpineShoulder, KinectPV2.JointType_ShoulderRight);
		addBoneParticles(KinectPV2.JointType_ShoulderRight, KinectPV2.JointType_ElbowRight);
		addBoneParticles(KinectPV2.JointType_ElbowRight, KinectPV2.JointType_WristRight);
		addBoneParticles(KinectPV2.JointType_WristRight, KinectPV2.JointType_HandRight);
		addBoneParticles(KinectPV2.JointType_HandRight, KinectPV2.JointType_HandTipRight);

		addBoneParticles(KinectPV2.JointType_SpineShoulder, KinectPV2.JointType_ShoulderLeft);
		addBoneParticles(KinectPV2.JointType_ShoulderLeft, KinectPV2.JointType_ElbowLeft);
		addBoneParticles(KinectPV2.JointType_ElbowLeft, KinectPV2.JointType_WristLeft);
		addBoneParticles(KinectPV2.JointType_WristLeft, KinectPV2.JointType_HandLeft);
		addBoneParticles(KinectPV2.JointType_HandLeft, KinectPV2.JointType_HandTipLeft);
	}

	if (hips)  {
		addBoneParticles(KinectPV2.JointType_SpineBase, KinectPV2.JointType_HipRight);
		addBoneParticles(KinectPV2.JointType_SpineBase, KinectPV2.JointType_HipLeft);
	}

	if (legs)  {
		addBoneParticles(KinectPV2.JointType_HipRight, KinectPV2.JointType_KneeRight);
		addBoneParticles(KinectPV2.JointType_KneeRight, KinectPV2.JointType_AnkleRight);
		addBoneParticles(KinectPV2.JointType_AnkleRight, KinectPV2.JointType_FootRight);

		addBoneParticles(KinectPV2.JointType_HipLeft, KinectPV2.JointType_KneeLeft);
		addBoneParticles(KinectPV2.JointType_KneeLeft, KinectPV2.JointType_AnkleLeft);
		addBoneParticles(KinectPV2.JointType_AnkleLeft, KinectPV2.JointType_FootLeft);
	}

	if (head)
		addJointParticles(KinectPV2.JointType_Head, 75*particle_density);	// could make radius proportional to dist(KinectPV2.JointType_Head, KinectPV2.JointType_Neck)
}

void addBoneParticles (int jointType1, int jointType2)  {
	float x1 = jointData[jointType1*3+0], y1 = jointData[jointType1*3+1], z1 = jointData[jointType1*3+2];
	float x2 = jointData[jointType2*3+0], y2 = jointData[jointType2*3+1], z2 = jointData[jointType2*3+2];

	// add fire particles
	// number of particles should be proportional to length of bone
	int np = int(particle_density * random(3.0, 8.0));
	for (int i = 0; i < np; ++i)  {
		float v = random(1);
		ps.add(new P(x1+v*(x2-x1), y1+v*(y2-y1), z1+v*(z2-z1)));
	}
}

void addJointParticles (int jointType, float rad)  {
	float x = jointData[jointType*3+0], y = jointData[jointType*3+1], z = jointData[jointType*3+2];

	// add fire particles
	// number of particles should be proportional to radius
	int np = int(particle_density * random(8.0, 13.0));
	for (int i = 0; i < np; ++i)  {
		PVector pv = sphRand();
		ps.add(new P(x+pv.x*rad, y+pv.y*rad, z+pv.z*rad));
	}
}





// originally from SkeletonColor example
// draw a skeleton with data in jointData[]
void drawSkeleton () {
	// spine
	drawBone(KinectPV2.JointType_Head, KinectPV2.JointType_Neck);
	drawBone(KinectPV2.JointType_Neck, KinectPV2.JointType_SpineShoulder);
	drawBone(KinectPV2.JointType_SpineShoulder, KinectPV2.JointType_SpineMid);
	drawBone(KinectPV2.JointType_SpineMid, KinectPV2.JointType_SpineBase);

	// hips
	drawBone(KinectPV2.JointType_SpineBase, KinectPV2.JointType_HipRight);
	drawBone(KinectPV2.JointType_SpineBase, KinectPV2.JointType_HipLeft);

	// Right Arm	
	drawBone(KinectPV2.JointType_SpineShoulder, KinectPV2.JointType_ShoulderRight);
	drawBone(KinectPV2.JointType_ShoulderRight, KinectPV2.JointType_ElbowRight);
	drawBone(KinectPV2.JointType_ElbowRight, KinectPV2.JointType_WristRight);
	drawBone(KinectPV2.JointType_WristRight, KinectPV2.JointType_HandRight);
	drawBone(KinectPV2.JointType_HandRight, KinectPV2.JointType_HandTipRight);
	drawBone(KinectPV2.JointType_WristRight, KinectPV2.JointType_ThumbRight);

	// Left Arm
	drawBone(KinectPV2.JointType_SpineShoulder, KinectPV2.JointType_ShoulderLeft);
	drawBone(KinectPV2.JointType_ShoulderLeft, KinectPV2.JointType_ElbowLeft);
	drawBone(KinectPV2.JointType_ElbowLeft, KinectPV2.JointType_WristLeft);
	drawBone(KinectPV2.JointType_WristLeft, KinectPV2.JointType_HandLeft);
	drawBone(KinectPV2.JointType_HandLeft, KinectPV2.JointType_HandTipLeft);
	drawBone(KinectPV2.JointType_WristLeft, KinectPV2.JointType_ThumbLeft);

	// Right Leg
	drawBone(KinectPV2.JointType_HipRight, KinectPV2.JointType_KneeRight);
	drawBone(KinectPV2.JointType_KneeRight, KinectPV2.JointType_AnkleRight);
	drawBone(KinectPV2.JointType_AnkleRight, KinectPV2.JointType_FootRight);

	// Left Leg
	drawBone(KinectPV2.JointType_HipLeft, KinectPV2.JointType_KneeLeft);
	drawBone(KinectPV2.JointType_KneeLeft, KinectPV2.JointType_AnkleLeft);
	drawBone(KinectPV2.JointType_AnkleLeft, KinectPV2.JointType_FootLeft);

	// draw end points
	//drawJoint(KinectPV2.JointType_Head);
	drawJoint(KinectPV2.JointType_HandTipLeft);
	drawJoint(KinectPV2.JointType_ThumbLeft);
	drawJoint(KinectPV2.JointType_HandTipRight);
	drawJoint(KinectPV2.JointType_ThumbRight);
	drawJoint(KinectPV2.JointType_FootLeft);
	drawJoint(KinectPV2.JointType_FootRight);
}


void drawJoint (int jointType) {
	fill(SKEL_COLOR);
	noStroke();
	pushMatrix();

	int idx = jointType * 3;
	translate(jointData[idx+0], jointData[idx+1], jointData[idx+2]);

	ellipse(0, 0, ELLIPSE_SIZE, ELLIPSE_SIZE);
	popMatrix();
}

void drawBone (int jointType1, int jointType2) {
	fill(SKEL_COLOR);
	noStroke();
	pushMatrix();

	int idx1 = jointType1 * 3;
	translate(jointData[idx1+0], jointData[idx1+1], jointData[idx1+2]);

	ellipse(0, 0, ELLIPSE_SIZE, ELLIPSE_SIZE);
	popMatrix();

	stroke(SKEL_COLOR);
	int idx2 = jointType2 * 3;
	line(jointData[idx1+0], jointData[idx1+1], jointData[idx1+2], jointData[idx2+0], jointData[idx2+1], jointData[idx2+2]);
}





// Utility functions

// convert Hue-Saturation-Value to RGB w/ Alpha
color hsv2rgb (float h, float s, float v, int a)  { 
	if (s <= 0.0)
		return 0;
 
	while (h >= 360.0) h -= 360.0;
	while (h < 0.0) h += 360.0;
	h /= 60.0;

	int hi = int(h);
	float f = h - hi;
	float p = v * (1.0 - s);
	float q = v * (1.0 - (s * f));
	float t = v * (1.0 - (s * (1.0 - f)));
	float r = 0.0, g = 0.0, b = 0.0;

	switch (hi)  {
		case 0: r = v; g = t; b = p; break;
		case 1: r = q; g = v; b = p; break;
		case 2: r = p; g = v; b = t; break;
		case 3: r = p; g = q; b = v; break;
		case 4: r = t; g = p; b = v; break;
		case 5: r = v; g = p; b = q; break;
	}

	return color(int(r*255.99), int(g*255.99), int(b*255.99), a);	
}


// generate a random vector inside a unit sphere
PVector sphRand ()  {
	float xs,ys,zs;
	do  {
		xs = random(-1,1);
		ys = random(-1,1);
		zs = random(-1,1);
	} while (xs*xs+ys*ys+zs*zs > 1.0);
	return new PVector(xs,ys,zs);
}







