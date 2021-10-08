/******************************************************************************/
/*!
\file   Bird.pde
\author Filip Ivanov
\par    email: f.ivanov.student.utwente.nl 
\date
\brief
  This file contains the implementation of the flying bird
*/
/******************************************************************************/
class Bird {
  
  //VARIABLES
  color bodyColorLight = color (255, 220, 100);
  color bodyColorMiddle = color (240, 170, 75);
  color bodyColorDark = color (230, 115, 30);
  float x = 100, y = 100, size = 64, rotationAngle = -10, verticalSpeed = 0, horizontalSpeed = -2;
  
  //An array for the joint positions of the wings just so it is easier and more clear when drawing them; and offset of the wings which is used for the flap animation
  float[] wingJointX = new float[3];
  float[] wingJointY = new float[3];
  float wingOffset = 0;
  
  //Stores the last hoop that the bird passed to avoid passing through the same hoop twice because it looks weird (0 - circle hoop; 1 - triangle hoop; -1 - haven't passed any hoops yet) 
  int lastHoopPassed = -1;

  //CONSTRUCTORS
  Bird(float initX, float initY, float initSize) {
    x = initX;
    y = initY;
    size = initSize;
    
    //Set the wing joint positions
    wingJointX[0] = -size*.4;
    wingJointX[1] = size*.25;
    wingJointX[2] = size;

    wingJointY[0] = -size*.25;
    wingJointY[1] = -size*.75;
    wingJointY[2] = -size*.8;
  }

  //METHODS
  
  
  void display() {
    noStroke();

    pushMatrix();
    //Translates and rotates the bird appropriately
    translate(x, y);
    rotate(radians(rotationAngle));
    
    //Display the different bits
    displayHead();
    displayBody();
    displayWings();
    popMatrix();
  }
  
  //Displays the body using bezier curves
  void displayBody() {
    fill(bodyColorMiddle);
    bezier(-size*.75, size*.01, -size*.75, -size*.5, size*.5, -size*.5, size, size*.01);
    bezier(-size*.75, -size*.01, -size*.5, size*.5, size*.75, size*.5, size, -size*.01);
  }
  
  //Displays the head
  void displayHead() {
    
    //Beak
    fill(bodyColorDark);
    triangle( - size*1.6, -size*.25, -size, -size*.25, -size, -size*.75);

    fill(bodyColorMiddle);    
    //Neck
    beginShape();
    vertex(-size*.75, -size*.55);
    vertex(0, -size*.1);
    vertex(-size*.75, 0);
    vertex(-size, -size*.25);
    endShape();

    //Head
    ellipse(-size, -size*.5, size*.6, size*.5);
    
    //Eye
    fill(bodyColorDark);
    ellipse(-size*1.15, -size*.5, size*.2, size*.15);
  }
  
  //Displays the wings based on the joint coordinates and also the wing offset which makes them flap when needed
  void displayWings() {
    //Inner wing
    if (wingOffset < size*.5) {
      fill(bodyColorDark);
      triangle(wingJointX[0], wingJointY[0] + size*.1, wingJointX[1], wingJointY[1] + wingOffset, wingJointX[2], wingJointY[2] + wingOffset + size*.05);
    } else {
      fill(bodyColorLight);
      triangle(wingJointX[0], wingJointY[0] - size*.025, wingJointX[1], wingJointY[1] + wingOffset, wingJointX[2], wingJointY[2] + wingOffset - size*.05);
    }

    //Outer wing
    stroke(bodyColorMiddle);
    strokeWeight(size*.1);
    line(wingJointX[0], wingJointY[0], wingJointX[1], wingJointY[1] + wingOffset);
    stroke(bodyColorLight);
    line(wingJointX[1], wingJointY[1] + wingOffset, wingJointX[2], wingJointY[2] + wingOffset);
  } 

  //Updates all the necessary variables using submethods 
  void update() {
    screenWarp();
    updateVerticalSpeed();
    updateRotationAngle();
    updatePosition();
    updateWingOffset();
  }
  
  //Sets the rotation angle relative to the vertical speed so the bird faces in the appropriate direction when falling or rising
  void updateRotationAngle() {
    rotationAngle = -verticalSpeed*3;
  }
  
  //Moves the bird
  void updatePosition() {
    x += horizontalSpeed;
    y += verticalSpeed;
  }
  
  //Handles gravity
  void updateVerticalSpeed() {
    if (verticalSpeed < 6) verticalSpeed += .1;
    else verticalSpeed = 6;
  }
  
  //Handles the wing offset resetting to its initial value
  void updateWingOffset() {
    if (wingOffset > 0) wingOffset -= 3;
    else wingOffset = 0;
  }
  
  //Flaps the wings, makes the bird rise up and also face up
  void flap() {
    if (wingOffset == 0) {
      rotationAngle = 3;
      verticalSpeed = -3;
      wingOffset = size*1.25;
    }
  }
  
  //Warps around the screen Pacman style (also resets the last hoop we passed when we exit the screen from the left side
  void screenWarp() {
    if (x < -size - 32){
      x = width + size + 32;
      lastHoopPassed = -1;  
    }
    if (y < -size) y = height + size;
    if (y > height + size) y = - size;
  }
  
  //Changes the last hoop we passed
  void changeLastHoop(int currentHoop){
    lastHoopPassed = currentHoop;
  }
  
  //Returns the last hoop we passed
  int getLastHoop(){
    return lastHoopPassed;
  }
}