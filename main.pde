/******************************************************************************/
/*!
\file   main.pde 
\author Wong Zhihao, Filip Ivanov
\par    email: wongzhihao.student.utwente.nl, f.ivanov.student.utwente.nl 
\date
\brief
  This file contains the main loop of the program.
*/
/******************************************************************************/

Keys_Manager keys_manager;
Flaming_Lady flaming_lady;
Bird bird;
Hoop hoop, hoop2;
Bunny bunny;
Background background;

color main_color_range_1 = color(255, 220, 100);
color main_color_range_2 = color(230, 115, 30);

boolean paused;

/******************************************************************************/
/*!
    Initialises the program and allocates memory
*/
/******************************************************************************/
void setup()
{
  // Canvas aspect ratio is 16:9
   size(2560, 1440, P2D);
  // size(1920, 1080, P2D);
  //size(1280, 720, P2D);

  rectMode(CENTER);
  ellipseMode(CENTER);

  frameRate(60);

  flaming_lady = new Flaming_Lady();
  keys_manager = new Keys_Manager();

  bird = new Bird(width + 64, height*.25, height / 10f);
  hoop = new Hoop(width*.5, height*.25, 0);
  hoop2 = new Hoop(width*.25, height*.3, 1);
  bunny = new Bunny();
  background = new Background();
  background.createStars();

  paused = false;
}

/******************************************************************************/
/*!
    Main loop of the program, updates and draws every object
*/
/******************************************************************************/
void draw()
{
  if (!paused)
  {
    background.update();
    flaming_lady.Update();
    bird.update();
    bunny.update();
    hoop.update();
    hoop2.update();

    background.display();

    flaming_lady.Draw();

    bunny.display();
    
    hoop.displayBack();
    hoop2.displayBack();

    bird.display();
    
    hoop.displayFront();
    hoop2.displayFront();
  }
}

/******************************************************************************/
/*!
    Updates the Key Manager of any control keys pressed, and executes other
    non logical functions
*/
/******************************************************************************/
void keyPressed()
{
  // Pauses application
  if (key == 'p' || key == 'P')
    paused = paused ? false : true;

  // Toggles low and high performance for the dress strands
  if (key == 'm' || key == 'M')
    flaming_lady.Set_Dress_Strands_Performance();

  // Toggles flat and gradient colouring
  if (key == 'n' || key == 'N')
    flaming_lady.Set_Colouring_Type();

  if (key == ' ') bird.flap();

  ///////////////
  // KEY MANAGER
  if (key == 'w' || key == 'W')
    keys_manager.Key_Pressed(KEY.W);

  if (key == 's' || key == 's')
    keys_manager.Key_Pressed(KEY.S);

  if (key == 'a' || key == 'A')
    keys_manager.Key_Pressed(KEY.A);

  if (key == 'd' || key == 'D')
    keys_manager.Key_Pressed(KEY.D);

  if (key == CODED)
  {
    if (keyCode == LEFT)
      keys_manager.Key_Pressed(KEY.LEFT);

    if (keyCode == RIGHT)
      keys_manager.Key_Pressed(KEY.RIGHT);

    if (keyCode == UP)
      keys_manager.Key_Pressed(KEY.UP);

    if (keyCode == DOWN)
      keys_manager.Key_Pressed(KEY.DOWN);
  }
}

/******************************************************************************/
/*!
    Updates the Key Manager of any control keys released
*/
/******************************************************************************/
void keyReleased()
{
  if (key == 'w' || key == 'W')
    keys_manager.Key_Released(KEY.W);

  if (key == 's' || key == 's')
    keys_manager.Key_Released(KEY.S);

  if (key == 'a' || key == 'A')
    keys_manager.Key_Released(KEY.A);

  if (key == 'd' || key == 'D')
    keys_manager.Key_Released(KEY.D);

  if (key == CODED)
  {
    if (keyCode == LEFT)
      keys_manager.Key_Released(KEY.LEFT);

    if (keyCode == RIGHT)
      keys_manager.Key_Released(KEY.RIGHT);

    if (keyCode == UP)
      keys_manager.Key_Released(KEY.UP);

    if (keyCode == DOWN)
      keys_manager.Key_Released(KEY.DOWN);
  }
}
