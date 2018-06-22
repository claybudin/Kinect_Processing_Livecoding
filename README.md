# Kinect & Processing Livecoding
## Sample Code for ITP Camp 2018 Session:  
*Livecoding with Kinect and Processing - Turning Human Motion into Graphics*  
Wednesday June 20, 2018 8-10 PM  
Clay Budin  
clay.budin@gmail.com

### Getting started:
1. Download and install Processing 3 for your computer [here](https://processing.org/)
2. Once installed, launch Processing 3, go to File->Preferences... and choose your sketchbook location (or accept the default).  Also check "Increase maximum available memory to:" and put in a big value like 4000
3. Clone or download the zip of this repository onto your computer at the sketchbook location from above.  The sketches folder should be next to the examples, libraries, modes templates and tools folders.
4. You will also need some libraries to run these sketches.  In Processing, go to Sketch->Import Library...->Add Library...  In the Filter box type "control p5", click on that and install it.  Then in the Filter box type "kinect" and click on "Kinect v2 for Processing" and install that.
5. If you want to work with the Kinect 2 device, you will need to be running on Windows 10.  Download and install the Kinect for Windows SDK 2 from [here](https://www.microsoft.com/en-ca/download/details.aspx?id=44561)
6. Optional/Advanced.  I find the built-in Processing text editor to be difficult to use, so I write Processing code in [Sublime Text](https://www.sublimetext.com/).  And I use [this](https://github.com/b-g/processing-sublime) handy tool which lets you run your Processing sketches directly from Sublime.

### Running the Sketches:
The main sketch is FireDancer01.  Open it in Processing or Sublime Text.  When you run it, you should see a pre-recorded Kinect capture animation playing with a particle effect on top.  If you click right in the window, it will pop up a window with parameters you can play with.  You can save your parameters or save an image with the buttons on the bottom.

If you want to work with a live Kinect 2 device, set the boolean variable KINECT_LIVE at the top of the sketch file to true and run it again.

The KinectCapture sketch will make an animated recording from a Kinect.  Click left to start recording and right to stop recording and save the animation file.  You will need to be running on Windows 10 and install the Kinect for Windows SDK 2 to use this, as described above.

Study the code in the sketches to see how they work.  Bring your questions and ideas for improvement to the session on Wednesday.  Or you can email me at the above address.

Have fun!

### Update: Using Kinect with Mac
Many people were asking if it's possible to use the Kinect on the Mac, since the Kinect is a Microsoft product.  It is possible by using an open-source library, which gives you access to all of the images coming from the Kinect, but not the skeleton information.  Here is how you can do it:
1. Download the open-source OpenKinect-for-Processing library openkinect_processing.zip from [here](https://github.com/shiffman/OpenKinect-for-Processing/releases).  As I write this the latest version is 1.0
2. Unzip the file and move the whole folder (openkinect_processing) into the libraries folder in your Sketchbook location.
3. You will need to re-launch Processing so it can see the new library.
4. Look in the openkinect_processing folder in the examples folder for some sample sketches.

I created new versions of several of the sketches to use this library and tested it on a Mac.

