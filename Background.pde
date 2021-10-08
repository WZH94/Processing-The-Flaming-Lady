/******************************************************************************/
/*!
 \file   Background.pde
 \author Filip Ivanov
 \par    email: f.ivanov.student.utwente.nl 
 \date
 \brief
 This file contains the implementation of the program's background
 */
/******************************************************************************/
class Background {

  //VARIABLES

  //BG colors
  color backgroundColorLight = color(49, 57, 98);
  color backgroundColorMiddle = color(50, 50, 90);
  color backgroundColorDark = color(40, 45, 80);
  color textColor = color(215, 220, 240);

  //Three arrays for three layers of stars to create a 3D 'parallax scrolling' effect (leyer 1 is closest, 3 is farthest)
  Star[] starLayer1 = new Star[100];
  Star[] starLayer2 = new Star[150];
  Star[] starLayer3 = new Star[200];


  //METHODS

  //Fills the three layer arrays with stars appropriately
  void createStars() {
    int i;

    for (i = 0; i < starLayer3.length; i++) {
      starLayer3[i] = new Star(random(0, width), random(0, height), 3);
    }

    for (i = 0; i < starLayer2.length; i++) {
      starLayer2[i] = new Star(random(0, width), random(0, height), 2);
    }

    for (i = 0; i < starLayer1.length; i++) {
      starLayer1[i] = new Star(random(0, width), random(0, height), 1);
    }
  }

  //Displays the background
  void display() {

    //Display the three colored background
    fill(backgroundColorDark);
    noStroke();
    rect(0, 0, width, height);

    pushMatrix();
    rotate(radians(8));

    fill(backgroundColorMiddle);
    ellipse(width*.75, height*.025, width*2, height);

    fill(backgroundColorLight);
    ellipse(width*.75, -height*.5, width*1.5, height);
    popMatrix();

    //Display the stars
    starsDisplay();

    //Display an instruction message
    textSize(32);
    fill(backgroundColorDark);
    text("AD - rotate flaming lady", width - 392, 34);
    text("SPACEBAR - bird's flapping", width - 428, 66);
    text("WS - extend arms", width - 290, 98);
    text("ARROWS - rotate arms", width - 362, 130);
    fill(textColor);
    text("AD - rotate flaming lady", width - 392, 34);
    text("SPACEBAR - bird's flapping", width - 428, 64);
    text("WS - extend arms", width - 290, 98);
    text("ARROWS - rotate arms", width - 362, 130);

    textSize(15);
    text("Press N and M for things to happen", width - 302, 160);
  }

  //Update method
  void update(){
    //Update the stars
    starsUpdate();
  }

  //Display the stars
  void starsDisplay() {
    int i;

    //Layer 3
    for (i = 0; i < starLayer3.length; i++) {
      starLayer3[i].display();
    }

    //Layer 2
    for (i = 0; i < starLayer2.length; i++) {
      starLayer2[i].display();
    }

    //Layer 1
    for (i = 0; i < starLayer1.length; i++) {
      starLayer1[i].display();
    }
  }
  
  //Update the stars
  void starsUpdate() {
    int i;

    //Layer 3
    for (i = 0; i < starLayer3.length; i++) {
      starLayer3[i].update();
    }

    //Layer 2
    for (i = 0; i < starLayer2.length; i++) {
      starLayer2[i].update();
    }

    //Layer 1
    for (i = 0; i < starLayer1.length; i++) {
      starLayer1[i].update();
    }
  }
}
