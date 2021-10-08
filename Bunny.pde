/******************************************************************************/
/*!
\file   Bunny.pde
\author Filip Ivanov
\par    email: f.ivanov.student.utwente.nl
\date
\brief
  This file contains the implementation of the bunny creature
*/
/******************************************************************************/
class Bunny{
  //Variables
  float size = 175, x = width - size*.75, y = height - size;
  
  color bodyColorLight = color (200, 180, 100);
  color bodyColorMiddle = color(190, 140, 80);
  color bodyColorDark = color(185, 100, 50);
  color shapeColor = color (240, 170, 75);
  color pillowColorLight = color (125, 80, 70);
  color pillowColorDark = color (70, 65, 90);
  
  //Both used to make the bunny float up and down
  float floatOffset = 0;
  int offsetSign = 1;
  
  //Used to make the shape pop when changing
  float shapeScale = 1.25;
  
  //Controls which shape is next to the bunny (0 - circle; 1 - triangle)
  int shape = 1;
  
  //METHODS
  
  //Displays all the appropriate parts of the bunny (as commented below)
  void display(){
    noStroke();
    
    pushMatrix();
    translate(0, floatOffset);
    
    //Pillow
    fill(pillowColorDark);
    rectMode(CENTER);
    rect(x - size*.4, y + size*.5 - floatOffset*.75, size*2, size*.5);
    ellipse(x - size*.4, y + size*.65 - floatOffset*.5, size*2, size);
    fill(pillowColorLight);
    ellipse(x - size*.4, y + size*.3 + floatOffset*.5, size*2, size);
    rectMode(CORNER);
    
    //Tail and paw
    fill(bodyColorDark);
    ellipse(x - size*.3, y + size*.2, size*.5, size*.5);
    ellipse(x - size*.75, y - size*.01 + floatOffset*.4, size*.75, size*.75);
    
    //Body
    ellipse(x - size*.5, y - size*.1 + floatOffset*.5, size, size*.75);
    
    //Shape
    fill(shapeColor);
    pushMatrix();
    translate(x - size*.9, y + size*.15 + floatOffset);
    scale(shapeScale);
    if (shape == 0) ellipse(0, 0, size*.75, size*.75);
    else triangle(-size*.375, size*.25, size*.375, size*.25, 0, -size*.5);
    popMatrix();
    
    //Back ear
    fill(bodyColorDark);
    pushMatrix();
    translate(x + size*.48, y - size*.06);
    rotate(radians(-35 - floatOffset));
    ellipse(0, 0, size*.25, size*.75);
    popMatrix();
    
    //Head
    fill(bodyColorMiddle);
    ellipse(x, y, size, size);
    triangle(x - size*.48, y + size*.2, x + size*.48, y - size*.06, x + size*.15, y + size*.6 + floatOffset*.5);
    bezier(x - size*.5, y + size*.1, x - size*.4, y + size*.4, x - size*.3, y + size*.55, x + size*.15, y + size*.6 + floatOffset*.5);
    bezier(x + size*.5, y - size*.1, x + size*.45, y + size*.4, x + size*.4, y + size*.5, x + size*.15, y + size*.6 + floatOffset*.5);
    
    //Eyes, nose and mouth
    pushMatrix();
    translate(x, y + 16 + floatOffset*.5);
    rotate(radians(-6));
    stroke(bodyColorDark);
    strokeWeight(3);
    line(-size*.2, 0, 0, 0);
    line(size*.25, 0, +size*.4, 0);
    fill(bodyColorDark);
    ellipse(size*.15, size*.4 - 16, size*.2, size*.1);
    ellipse(size*.1, size*.5 - 16, size*.05, size*.001);
    noStroke();
    popMatrix();
    
    //Front ear
    fill(bodyColorLight);
    pushMatrix();
    translate(x - size*.48, y + size*.2);
    rotate(radians(10 - floatOffset));
    ellipse(0, 0, size*.3 , size*.75);
    popMatrix();
    popMatrix();
  }
  
  //Updates the bunny's properties
  void update(){
    
    //Update the float offset to make the bunny float up and down (determines the sign which in term determines which direction it should move)
    if (floatOffset >= 5) offsetSign = -1;
    if (floatOffset <= -5) offsetSign = 1;
    floatOffset += offsetSign*.1;
    
    //Returns the scale back to the initial value if we've changed it
    if (shapeScale > 1.25) shapeScale -=.025;
    else shapeScale = 1.25;
  }
  
  //Changes the shape next to the bunny and also makes it bigger so it has a popping animation
  void changeShape (int inputShape){
    shape = inputShape;
    shapeScale = 1.5;
  }
}