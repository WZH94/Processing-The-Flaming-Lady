/******************************************************************************/
/*!
 \file   Star.pde
 \author Filip Ivanov
 \par    email: f.ivanov.student.utwente.nl 
 \date
 \brief
 This file contains the implementation of the parallax scrolling stars
 */
/******************************************************************************/
class Star {
  //VARIABLES
  float x, y, size, horizontalSpeed;
  int layer; //1 - closest, 2 - middle, 3 - farthest
  color starColor; //<>//

  //CONSTRUCTORS
  Star(float initX, float initY, int initLayer) {
    x = initX;
    y = initY;
    layer = initLayer;
    
    //Handles setting the color, speed and size of the stars appropriately depending on their layer
    switch(layer) {
    case 1: 
      starColor = color (80, 90, 100); 
      horizontalSpeed = .5;
      size = random(4, 10);
      break;
    case 2: 
      starColor = color (70, 70, 100); 
      horizontalSpeed = .2;
      size = random(4, 8);
      break;
    case 3: 
      starColor = color (60, 60, 80); 
      horizontalSpeed = .2;
      size = random(4, 6);
      break;
    default: 
      starColor = color (120, 130, 160); 
      horizontalSpeed = .35;
      size = random(1, 2);
      break;
    }
  }
  
  //METHODS
  
  //Displays the star
  void display(){
    fill(starColor);
    ellipse(x, y, size, size);
  }
  
  //Updates its position
  void update(){
    x += horizontalSpeed;
    warp();
  }
  
  //Warps it in case it's offscreen so we get an infinite scrolling effect
  void warp(){
    if (x > width + size) x = -size;
  }
}
