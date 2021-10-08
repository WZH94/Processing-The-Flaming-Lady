/******************************************************************************/
/*!
 \file   Hoop.pde
 \author Filip Ivanov
 \par    email: f.ivanov.student.utwente.nl
 \date
 \brief
 This file contains the implementation of the hoops
 */
/******************************************************************************/
class Hoop {
  //VARIABLES
  float x, y, size;
  color hoopColor;
  int redValue, greenValue, blueValue;
  int shape;

   //CONSTRUCTORS
  Hoop(float initX, float initY, int initShape) {
    x = initX;
    y = initY;

    //0 - circle hoop, 1 - triangle hoop
    shape = initShape;
    size = height / 5.5f;

    //Sets the hoop color and stores it's RGB values individually so we can transition back to them (used in animation)
    hoopColor = color (255, 220, 100);
    redValue = 255;
    greenValue = 220;
    blueValue = 100;
  }

  //METHODS

  //Displays the part of the hoop that should be in front of the bird
  void displayFront() {
    noFill();
    strokeWeight(size*.1);
    stroke(hoopColor);

    if (shape == 0) arc(x, y, size, size, -PI/2, PI/2);
    else 
    {
      pushMatrix();

      translate(x, y);
      rotate(-flaming_lady.Get_Forearm_Rotation());
      line(0,  -size*.5, size*.5, size*.5);

      popMatrix();
    }
  }

  //Displays the part of the hoop that should be behind of the bird
  void displayBack() {
    noFill();
    strokeWeight(size*.1);
    stroke(hoopColor);

    if (shape == 0) ellipse(x, y, size, size);
    else 
    {
      pushMatrix();

      translate(x, y);
      rotate(-flaming_lady.Get_Forearm_Rotation());
      triangle(0, - size*.5, size*.5, size*.5, - size*.5, + size*.5);

      popMatrix();
    }
  }
  
  //Updates position, size and color and checks if it's colliding with the bird
  void update() {
    birdCollision();
    updatePos();
    updateSize();
    updateColor();
  }

  //Snaps the hoops to the appropriate arms of the flaming lady
  void updatePos() {
    if (shape == 0)
    {
      x = flaming_lady.Transform_To_Left_Hoop().x;
      y = flaming_lady.Transform_To_Left_Hoop().y;
    } else
    {
      x = flaming_lady.Transform_To_Right_Hoop().x;
      y = flaming_lady.Transform_To_Right_Hoop().y;
    }
  }

  //Returns the size to the initial value smoothly in case we've changed it
  void updateSize() {
    if (size > height / 5.5) size -= .825;
    else size = height / 5.5;
  }

  //Returns the color to the initial color smoothly in case we've changed it
  void updateColor() {

    if (greenValue > 220) greenValue -= 2;
    else greenValue = 220;

    if (blueValue > 100) blueValue -= 2;
    else blueValue = 100;

    hoopColor = color(redValue, greenValue, blueValue);
  }

  //Handles the bird passing though the hoop
  void birdCollision() {
    /*Checks to see if the birds head, but also its tail end are in the correct positions to avoid weird interactions
    where the bird didn't pass through the hoop but it still counted because the tail end was in the correct spot*/
    //Then checks to see if the hoop is not animating currently
    //Then checks to see if we haven't passed through it already (to avoid being able to move the hoop along with the bird and pass it twice)
    if (isOver(bird.x + 50, bird.y) && isOver(bird.x - size*.3, bird.y) && size == height / 5.5f && bird.getLastHoop() != shape) {
      //If all the aforementioned conditions are met
      
      //Make the hoop bigger and white in color to set off the animation
      size = height / 3.3f;
      hoopColor = color(255);
      redValue = 255;
      greenValue = 255;
      blueValue = 255;
      
      //Change the shape next to the bunny
      bunny.changeShape(shape);
      
      //Set the last hoop we passed to be this one
      bird.changeLastHoop(shape);
    }
  }

  //Used for collision checking
  boolean isOver(float collisionX, float collisionY) {
    if (dist(x, y, collisionX, collisionY) < size*.6) return true;
    else return false;
  }
}