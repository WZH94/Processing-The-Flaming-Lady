/******************************************************************************/
/*!
\file   Limb.pde
\author Wong Zhihao
\par    email: wongzhihao.student.utwente.nl
\date
\brief
  This file contains the implementation of the Limb class, which consists of the
  upper arm and forearm, both of which can be independently rotated. The Hoops
  take their coordinates from the position of the wrist.
*/
/******************************************************************************/

class Limb
{
  // Gradient shape for the upper arm
  private PShape upper_arm_shape_group_;
  private PShape [] upper_arm_shape_top_;
  private PShape [] upper_arm_shape_bottom_;

  // Gradient shape for the forearm
  private PShape forearm_shape_group_;
  private PShape [] forearm_shape_top_;
  private PShape [] forearm_shape_bottom_;

  // Gradient shape for the joint
  private PShape joint_shape_group_;
  private PShape [] joint_shapes_;

  // Fill shapes for the upper arm and forearm
  private PShape upper_arm_shape_flat_;
  private PShape forearm_shape_flat_;
  private PShape joint_shape_flat_;

  // Limbs have one joint strand at the joint
  private Strand joint_strand_;

  // Limbs have between 1 - 3 (int) strands (Strand) randomly along the upperarm (PVector) randomly rotated towards the body (float)
  private int num_arm_strands_; 
  private Strand [] arm_strands_;
  private PVector [] arm_strands_pos_;
  private float [] arm_strands_rotation_;

  // Strands that extend from the wrist to the Hoops
  private int num_wrist_strands_;
  private Strand [] wrist_strands_;

  // These positions are the exact coordinates of the joints.
  private PVector shoulder_joint_;

  // All calculations are done for right limb. This inverts all the angles to calculate left limb coordinates instead.
  // Left limb is -1, right limb is 1
  private int sin_multiplier_;

  // Rotation from 0 for right limb
  private float upper_arm_theta_;
  private float upper_arm_theta_default_;

  // Rotation from 0 from the upper arm rotation
  private float forearm_theta_;
  private float forearm_theta_default_;

  // WS rotation control, extends arms outwards
  private float extension_theta_;
  private float extension_theta_max_;

  // LEFT RIGHT arrow keys rotation control
  private float horizontal_input_theta_;
  private float horizontal_input_theta_max_;

  // UP DOWN arrow keys rotation control
  private float vertical_input_theta_;
  private float vertical_input_theta_max_;

  // Length of sections of limb
  private float upper_arm_length_;
  private float forearm_length_;
  private float wrist_length_;

  // Thickness of the arms
  private float upper_arm_thickness_;
  private float forearm_thickness_;

  /******************************************************************************/
  /*!
      Constructor for the limb
  */
  /******************************************************************************/
  Limb(float shoulder_joint_x, float shoulder_joint_y, float body_height, int sin_multiplier)
  {
    // Left is -1, right is 1
    sin_multiplier_ = sin_multiplier;

    // Pivot position of the limb
    shoulder_joint_ = new PVector(shoulder_joint_x, shoulder_joint_y);

    upper_arm_theta_ = radians(-45);
    upper_arm_theta_default_ = radians(-45);
    upper_arm_length_ = body_height / 2.1f;
    upper_arm_thickness_ = body_height / 12 * 1.2f;

    forearm_theta_ = radians(135);
    forearm_theta_default_ = radians(135);

    forearm_length_ = upper_arm_length_ / 1.1f;
    forearm_thickness_ = upper_arm_thickness_ / 2;

    wrist_length_ = forearm_thickness_ / 2;

    extension_theta_ = 0;
    extension_theta_max_ = radians(20);

    horizontal_input_theta_ = 0;
    horizontal_input_theta_max_ = radians(15);

    vertical_input_theta_ = 0;
    vertical_input_theta_max_ = radians(20);

    num_arm_strands_ = int(random(1, 4));
    arm_strands_ = new Strand[num_arm_strands_];

    for (int i = 0; i < num_arm_strands_; ++i)
      arm_strands_[i] = new Strand(STRAND_TYPE.wavy, random(1f, 1.6f), random(upper_arm_length_ / 7, upper_arm_length_ / 6), random(radians(0.3f), radians(1.2f)), 
                                   random(upper_arm_length_, upper_arm_length_ * 2f), random(upper_arm_length_ / 10, upper_arm_length_ / 6), true);

    arm_strands_pos_ = new PVector[num_arm_strands_];

    for (int i = 0; i < num_arm_strands_; ++i)
      arm_strands_pos_[i] = new PVector(random(upper_arm_length_ * 0.2f, upper_arm_length_ * 0.8f), 0);

    arm_strands_rotation_ = new float[num_arm_strands_];

    for (int i = 0; i < num_arm_strands_; ++i)
    {
      // Right limb
      if (sin_multiplier_ == 1)
        arm_strands_rotation_[i] = random(QUARTER_PI);

      else arm_strands_rotation_[i] = random(-QUARTER_PI);
    }

    // Create PShapes of the limb
    Create_Upper_Arm_Shape();
    Create_Forearm_Shape();
    Create_Joint_Shape();

    Create_Upper_Arm_Shape_Flat();
    Create_Forearm_Shape_Flat();
    Create_Joint_Shape_Flat();

    // Strand at the joint
    joint_strand_ = new Strand(STRAND_TYPE.wavy, 1, random(upper_arm_length_ / 4, upper_arm_length_ / 3), random(radians(0.2f), radians(1)), 
                               random(upper_arm_length_ * 2, upper_arm_length_ * 3), random(upper_arm_length_ / 8, upper_arm_length_ / 6), true);

    num_wrist_strands_ = 6;
    wrist_strands_ = new Strand[num_wrist_strands_];

    for (int i = 0; i < num_wrist_strands_; ++i)
      wrist_strands_[i] = new Strand(STRAND_TYPE.wavy, random(0.5f, 1.5f), forearm_thickness_ / 4, random(radians(0.5f), radians(1.2f)), 
                                     forearm_thickness_ * 1.7f, forearm_thickness_ / 4, true);
  }

  /******************************************************************************/
  /*!
      Updates the limb
  */
  /******************************************************************************/
  void Update(float body_rotation, float max_body_rotation)
  {
    // Check inputs
    Input();

    // Rotates the limbs based on input and body rotation
    Rotate_Limb(body_rotation, max_body_rotation);

    joint_strand_.Update();

    for (int i = 0; i < num_wrist_strands_; ++i)
      wrist_strands_[i].Update();

    for (int i = 0; i < num_arm_strands_; ++i)
      arm_strands_[i].Update();
  }

  /******************************************************************************/
  /*!
      Draws the limb
  */
  /******************************************************************************/
  void Draw(boolean colour_type)
  {
    pushMatrix(); 

    translate(shoulder_joint_.x, shoulder_joint_.y);

    // Right arm
    if (sin_multiplier_ == 1)
      rotate(-upper_arm_theta_);

    // Left arm
    else rotate(upper_arm_theta_ + PI);

    /************************************ PRINTS ARM STRANDS ************************************/

    for (int i = 0; i < num_arm_strands_; ++i)
    {
      pushMatrix();

      translate(arm_strands_pos_[i].x, arm_strands_pos_[i].y);
      rotate(arm_strands_rotation_[i]);

      arm_strands_[i].Draw();

      popMatrix();
    }

    /************************************ PRINTS UPPER ARM ************************************/

    if (colour_type)
      shape(upper_arm_shape_group_);

    else shape(upper_arm_shape_flat_);
    
    /************************************ PRINTS WRIST STRANDS ************************************/

    pushMatrix();

    translate(upper_arm_length_, upper_arm_thickness_ * sin_multiplier_ * 0.5f);

    // Right arm
    if (sin_multiplier_ == 1)
      rotate(-forearm_theta_);

    // Left arm
    else rotate(forearm_theta_);

    for (int i = 0; i < num_wrist_strands_; ++i)
    {
      pushMatrix(); // Translate to wrist

      translate(forearm_length_, forearm_thickness_ * i / (num_wrist_strands_ - 1) * sin_multiplier_);

      wrist_strands_[i].Draw();

      popMatrix();
    }

    /************************************ PRINTS FOREARM ************************************/

    if (colour_type)
      shape(forearm_shape_group_);

    else shape(forearm_shape_flat_);

    /************************************ PRINTS ELBOW JOINT ************************************/

    if (colour_type)
      shape(joint_shape_group_);

    else shape(joint_shape_flat_);

    /************************************ PRINTS JOINT STRAND ************************************/

    pushMatrix(); // Reset all previous rotations

    if (sin_multiplier_ == 1)
      rotate(upper_arm_theta_ + forearm_theta_ + HALF_PI);

    else rotate(-upper_arm_theta_ - PI - forearm_theta_ + HALF_PI);

    joint_strand_.Draw();

    popMatrix();  // Reset resetting rotations

    popMatrix();  // Forearm T&R

    popMatrix();  // Upper Arm T&R
  }

  /******************************************************************************/
  /*!
      Handles keyboard inputs
  */
  /******************************************************************************/
  void Input()
  {
    // Moves arms outwards
    if (keys_manager.Check_Key(KEY.W))
    {
      extension_theta_ += radians(0.7f);

      if (extension_theta_ > extension_theta_max_)
        extension_theta_ = extension_theta_max_;
    }

    // Moves arms inwards
    if (keys_manager.Check_Key(KEY.S))
    {
      extension_theta_ -= radians(0.7f);

      // Limits the arms from moving inwards too much
      if (extension_theta_ < -extension_theta_max_ / 3)
        extension_theta_ = -extension_theta_max_ / 3;
    }

    // Moves both arms rightwards
    if (keys_manager.Check_Key(KEY.RIGHT))
    {
      horizontal_input_theta_ += radians(0.7f);

      if (horizontal_input_theta_ > horizontal_input_theta_max_)
        horizontal_input_theta_ = horizontal_input_theta_max_;
    }

    // Moves both arms leftwards
    if (keys_manager.Check_Key(KEY.LEFT))
    {
      horizontal_input_theta_ -= radians(0.7f);

      if (horizontal_input_theta_ < -horizontal_input_theta_max_)
        horizontal_input_theta_ = -horizontal_input_theta_max_;
    }

    // RIGHT arrow key released AND input theta is still rightwards
    if (keys_manager.Check_Key(KEY.RIGHT) == false && horizontal_input_theta_ > 0)
    {
      // Slowly resets the theta
      horizontal_input_theta_ -= radians(1);

      if (horizontal_input_theta_ < 0)
        horizontal_input_theta_ = 0;
    }

    // LEFT arrow key released AND input theta is still leftwards
    if (keys_manager.Check_Key(KEY.LEFT) == false && horizontal_input_theta_ < 0)
    {
      // Slowly resets the theta
      horizontal_input_theta_ += radians(1);

      if (horizontal_input_theta_ > 0)
        horizontal_input_theta_ = 0;
    }

    // Moves forearm upwards
    if (keys_manager.Check_Key(KEY.UP))
    {
      vertical_input_theta_ += radians(1.5f);

      if (vertical_input_theta_ > vertical_input_theta_max_)
        vertical_input_theta_ = vertical_input_theta_max_;
    }

    // Moves forearm downwards
    if (keys_manager.Check_Key(KEY.DOWN))
    {
      vertical_input_theta_ -= radians(1.5f);

      if (vertical_input_theta_ < -vertical_input_theta_max_)
        vertical_input_theta_ = -vertical_input_theta_max_;
    }

    // UP arrow key released AND input theta is still upwards
    if (keys_manager.Check_Key(KEY.UP) == false && vertical_input_theta_ > 0)
    {
      vertical_input_theta_ -= radians(2.5f);

      if (vertical_input_theta_ < 0)
        vertical_input_theta_ = 0;
    }

    // DOWN arrow key released AND input theta is still downwards
    if (keys_manager.Check_Key(KEY.DOWN) == false && vertical_input_theta_ < 0)
    {
      vertical_input_theta_ += radians(2.5f);

      if (vertical_input_theta_ > 0)
        vertical_input_theta_ = 0;
    }
  }

  /******************************************************************************/
  /*!
      Handles rotation of the limbs based on keyboard input
  */
  /******************************************************************************/
  void Rotate_Limb(float body_rotation, float max_body_rotation)
  {
    // If body rotating rightwards
    if (body_rotation > 0)
    {
      float body_rotation_ratio = body_rotation / max_body_rotation;

      // If this limb is right limb
      if (sin_multiplier_ == 1)
      {
        // Rotate the arms based on how much the body is rotating, rotates more since right and right
        upper_arm_theta_ = upper_arm_theta_default_ - (body_rotation);
        forearm_theta_ = forearm_theta_default_ - (body_rotation * 3);

        // Modify by HORIZONTAL input theta_vector_
        // If input theta is also angled rightwards
        if (horizontal_input_theta_ > 0)
        {
          // Rotate by normal amount rightwards
          upper_arm_theta_ -= horizontal_input_theta_;
          // Forearm rotates half amount
          forearm_theta_ -= horizontal_input_theta_ / 2;
        }

        // Input theta is angled leftwards
        else
        {
          // Rotate by half amount leftwards
          upper_arm_theta_ -= horizontal_input_theta_ / 2;
          // Forearm rotates half amount
          forearm_theta_ -= horizontal_input_theta_ / 2 / 2;
        }

        // Modify by VERTICAL input theta
        // Rotate by normal amount since right limb and right body, rotation multiplied by ratio of body rotation
        forearm_theta_ += vertical_input_theta_ * body_rotation_ratio;
      }

      // Left limb
      else
      {
        // Rotate the arms based on how much the body is rotating, rotates less since yea it looks natural
        upper_arm_theta_ = upper_arm_theta_default_ + (body_rotation / 2);
        forearm_theta_ = forearm_theta_default_ + body_rotation;

        // Modify by HORIZONTAL input theta
        // If input theta is angled rightwards
        if (horizontal_input_theta_ > 0)
        {
          // Rotate by half amount rightwards
          upper_arm_theta_ += horizontal_input_theta_ / 2;
          // Forearm rotates half amount
          forearm_theta_ += horizontal_input_theta_ / 2 / 2;
        }

        // Input theta is also angled leftwards
        else
        {
          upper_arm_theta_ += horizontal_input_theta_;
          forearm_theta_ += horizontal_input_theta_ / 2;
        }

        // Modify by VERTICAL input theta
        // Rotate by half amount since left limb and right body, rotation multiplied by ratio of body rotation
        forearm_theta_ -= vertical_input_theta_ / 2 * body_rotation_ratio;
      }
    }

    // If body rotation leftwards
    else if (body_rotation < 0)
    {
      float body_rotation_ratio = -body_rotation / max_body_rotation;

      // If left limb, limbs will rotate
      if (sin_multiplier_ == -1)
      {
        // Rotate the arms based on how much the body is rotating, rotates more since left and left
        upper_arm_theta_ = upper_arm_theta_default_ + (body_rotation);
        forearm_theta_ = forearm_theta_default_ + (body_rotation * 3);

        // Modify by input theta
        // If input theta is angled rightwards, increase by half amount
        if (horizontal_input_theta_ > 0)
        {
          upper_arm_theta_ += horizontal_input_theta_ / 2;
          forearm_theta_ += horizontal_input_theta_ / 2 / 2;
        }

        // Input theta is also angled leftwards, increase by normal amount
        else
        {
          upper_arm_theta_ += horizontal_input_theta_;
          forearm_theta_ += horizontal_input_theta_ / 2;
        }

        // Modify by input theta
        // Rotate by normal amount since left limb and left body, rotation multiplied by ratio of body rotation
        forearm_theta_ += vertical_input_theta_ * body_rotation_ratio;
      }

      // Right limb, limbs will reset to default positions
      else
      {
        // Rotate the arms based on how much the body is rotating, rotates less since left and right
        upper_arm_theta_ = upper_arm_theta_default_ - (body_rotation / 2);
        forearm_theta_ = forearm_theta_default_ - body_rotation;

        // Modify by input theta
        // If input theta is also angled rightwards, increase by normal amount
        if (horizontal_input_theta_ > 0)
        {
          upper_arm_theta_ -= horizontal_input_theta_;
          forearm_theta_ -= horizontal_input_theta_ / 2;
        }

        // Input theta is angled leftwards, increase by half amount
        else
        {
          upper_arm_theta_ -= horizontal_input_theta_ / 2;
          forearm_theta_ -= horizontal_input_theta_ / 2 / 2;
        }

        // Modify by input theta
        // Rotate by half amount since right limb and left body, rotation multiplied by ratio of body rotation
        forearm_theta_ -= vertical_input_theta_ / 2 * body_rotation_ratio;
      }
    }

    // Body is at default position
    else 
    {
      upper_arm_theta_ = upper_arm_theta_default_;
      forearm_theta_ = forearm_theta_default_;

      // If left limb
      if (sin_multiplier_ == -1)
      {
        // Modify by input theta
        upper_arm_theta_ += horizontal_input_theta_ / 2;
        forearm_theta_ += horizontal_input_theta_ / 2 / 2;
      }

      // Right limb
      else
      {
        upper_arm_theta_ -= horizontal_input_theta_ / 2;
        forearm_theta_ -= horizontal_input_theta_ / 2 / 2;
      }
    }

    Extend_Arms();
  }

  void Extend_Arms()
  {
    // Modify by input theta
    upper_arm_theta_ += extension_theta_;
    forearm_theta_ -= extension_theta_ * 2;
  }

  /******************************************************************************/
  /*!
      Create upper arm shape with gradient colouring
  */
  /******************************************************************************/
  void Create_Upper_Arm_Shape()
  {
    upper_arm_shape_group_ = createShape(GROUP);

    upper_arm_shape_top_ = new PShape[int(upper_arm_thickness_ + 1)];
    upper_arm_shape_bottom_ = new PShape[int(upper_arm_thickness_ + 1)];

    // Creates shape of upper arm for the lower half of the upper arm
    for (int i = int(upper_arm_thickness_); i >= 0; --i)
    {
      //
      float current_y_pos = i * sin_multiplier_;
      float bottom_ratio = i / upper_arm_thickness_;

      upper_arm_shape_bottom_[i] = createShape();
      upper_arm_shape_bottom_[i].beginShape();
      upper_arm_shape_bottom_[i].strokeWeight(2f);

      upper_arm_shape_bottom_[i].stroke(lerpColor(main_color_range_1, main_color_range_2, i / upper_arm_thickness_));

      upper_arm_shape_bottom_[i].vertex(0, current_y_pos);
      upper_arm_shape_bottom_[i].bezierVertex(
             upper_arm_length_ * 0.2f, bottom_ratio * upper_arm_thickness_ * 0.5f * sin_multiplier_ + current_y_pos,  // First control point
             upper_arm_length_ * 0.5f, bottom_ratio * upper_arm_thickness_ * sin_multiplier_ + current_y_pos,         // Second control point
             upper_arm_length_, current_y_pos);                                                                         // Last Point

      upper_arm_shape_bottom_[i].endShape();
      upper_arm_shape_group_.addChild(upper_arm_shape_bottom_[i]);
    }

    // Creates shape of upper arm for the upper half of the upper arm
    for (int i = 0; i < upper_arm_thickness_; ++i)
    {
      //
      float current_y_pos = i * sin_multiplier_;
      float top_ratio = (upper_arm_thickness_ - i) / upper_arm_thickness_;

      upper_arm_shape_top_[i] = createShape();
      upper_arm_shape_top_[i].beginShape();

      upper_arm_shape_top_[i].strokeWeight(2f);

      upper_arm_shape_top_[i].stroke(lerpColor(main_color_range_1, main_color_range_2, i / upper_arm_thickness_));

      upper_arm_shape_top_[i].vertex(0, current_y_pos);

      upper_arm_shape_top_[i].bezierVertex(
             upper_arm_length_ * 0.3f, top_ratio * -upper_arm_thickness_ * 0.1f * sin_multiplier_ + current_y_pos,  // First control point
             upper_arm_length_ * 0.6f, top_ratio * -upper_arm_thickness_ * 1.2f * sin_multiplier_ + current_y_pos,         // Second control point
             upper_arm_length_, current_y_pos);                                                                         // Last Point

      upper_arm_shape_top_[i].endShape();
      upper_arm_shape_group_.addChild(upper_arm_shape_top_[i]);
    }
  }

  /******************************************************************************/
  /*!
      Create forearm shape with gradient colouring
  */
  /******************************************************************************/
  void Create_Forearm_Shape()
  {
    forearm_shape_group_ = createShape(GROUP);

    forearm_shape_top_ = new PShape[int(forearm_thickness_ + 1)];
    forearm_shape_bottom_ = new PShape[int(forearm_thickness_ + 1)];

    // Creates shape of forearm for the upper half of the forearm
    for (int i = 0; i < forearm_thickness_; ++i)
    {
      //
      float current_y_pos = i * sin_multiplier_;
      float top_ratio = (forearm_thickness_ - i) / forearm_thickness_;

      forearm_shape_top_[i] = createShape();
      forearm_shape_top_[i].beginShape();

      forearm_shape_top_[i].strokeWeight(2.5f);

      forearm_shape_top_[i].stroke(lerpColor(main_color_range_1, main_color_range_2, i / forearm_thickness_));

      forearm_shape_top_[i].vertex(0, current_y_pos);

      forearm_shape_top_[i].bezierVertex(
             forearm_length_ * 0.3f, top_ratio * -forearm_thickness_ * 0.1f * sin_multiplier_ + current_y_pos,  // First control point
             forearm_length_ * 0.7f, top_ratio * -forearm_thickness_ * sin_multiplier_ + current_y_pos,         // Second control point
             forearm_length_, current_y_pos);                                                                         // Last Point

      forearm_shape_top_[i].endShape();
      forearm_shape_group_.addChild(forearm_shape_top_[i]);
    }

    // Creates shape of forearm for the lower half of the forearm
    for (int i = int(forearm_thickness_); i >= 0; --i)
    {
      //
      float current_y_pos = i * sin_multiplier_;
      float bottom_ratio = i / forearm_thickness_;

      forearm_shape_bottom_[i] = createShape();
      forearm_shape_bottom_[i].beginShape();

      forearm_shape_bottom_[i].strokeWeight(2.5f);

      forearm_shape_bottom_[i].stroke(lerpColor(main_color_range_1, main_color_range_2, i / forearm_thickness_));

      forearm_shape_bottom_[i].vertex(0, current_y_pos);
      forearm_shape_bottom_[i].bezierVertex(
             forearm_length_ * 0.2f, bottom_ratio * forearm_thickness_ * sin_multiplier_ + current_y_pos,  // First control point
             forearm_length_ * 0.5f, bottom_ratio * forearm_thickness_ * 2 * sin_multiplier_ + current_y_pos,         // Second control point
             forearm_length_, current_y_pos);                                                                         // Last Point

      forearm_shape_bottom_[i].endShape();
      forearm_shape_group_.addChild(forearm_shape_bottom_[i]);
    }
  }

  /******************************************************************************/
  /*!
      Create joint shape with gradient colouring
  */
  /******************************************************************************/
  void Create_Joint_Shape()
  {
    joint_shape_group_ = createShape(GROUP);

    joint_shapes_ = new PShape[int(upper_arm_thickness_) + 1];

    for (int i = int(upper_arm_thickness_); i > 0; --i)
    {
      joint_shapes_[i] = createShape(ELLIPSE, 0, 0, i, i);
      joint_shapes_[i].setStroke(lerpColor(main_color_range_1, main_color_range_2, i / upper_arm_thickness_));

      joint_shape_group_.addChild(joint_shapes_[i]);
    }
  }

  /******************************************************************************/
  /*!
      Create upper arm shape with flat colouring
  */
  /******************************************************************************/
  void Create_Upper_Arm_Shape_Flat()
  {
    upper_arm_shape_flat_ = createShape();

    upper_arm_shape_flat_.beginShape();

    upper_arm_shape_flat_.noStroke();
    upper_arm_shape_flat_.fill(color(185, 100, 50));

    upper_arm_shape_flat_.vertex(0, 0);
    upper_arm_shape_flat_.bezierVertex(upper_arm_length_ * 0.2f, -upper_arm_thickness_ * 0.5f * sin_multiplier_,  // First control point
                                       upper_arm_length_ * 0.5f, -upper_arm_thickness_ * sin_multiplier_,         // Second control point
                                       upper_arm_length_, 0);

    upper_arm_shape_flat_.vertex(upper_arm_length_, upper_arm_thickness_ * sin_multiplier_);

    upper_arm_shape_flat_.bezierVertex(upper_arm_length_ * 0.6f, upper_arm_thickness_ * 1.4f * sin_multiplier_,  // First control point
                                         upper_arm_length_ * 0.4f, upper_arm_thickness_ * 0.7f * sin_multiplier_,         // Second control point
                                         0, upper_arm_thickness_ * sin_multiplier_);  

    upper_arm_shape_flat_.endShape(CLOSE);
  }

  /******************************************************************************/
  /*!
      Create forearmarm shape with flat colouring
  */
  /******************************************************************************/
  void Create_Forearm_Shape_Flat()
  {
    forearm_shape_flat_ = createShape();

    forearm_shape_flat_.beginShape();

    forearm_shape_flat_.noStroke();
    forearm_shape_flat_.fill(color(190, 140, 80));

    forearm_shape_flat_.vertex(0, 0);

    forearm_shape_flat_.bezierVertex(forearm_length_ * 0.3f, -forearm_thickness_ * 0.1f * sin_multiplier_,  // First control point
                                     forearm_length_ * 0.7f, -forearm_thickness_ * sin_multiplier_,         // Second control point
                                     forearm_length_, 0);

    forearm_shape_flat_.quadraticVertex(forearm_length_ + wrist_length_, forearm_thickness_ * 0.5f * sin_multiplier_,
                                        forearm_length_, forearm_thickness_ * sin_multiplier_);

    forearm_shape_flat_.bezierVertex(forearm_length_ * 0.5f, forearm_thickness_ * 2 * sin_multiplier_,  // First control point
                                     forearm_length_ * 0.2f, forearm_thickness_ * sin_multiplier_,         // Second control point
                                     0, forearm_thickness_ * sin_multiplier_);

    forearm_shape_flat_.endShape(CLOSE);
  }

  void Create_Joint_Shape_Flat()
  {
    joint_shape_flat_ = createShape(ELLIPSE, 0, 0, upper_arm_thickness_, upper_arm_thickness_);

    joint_shape_flat_.setFill(color(255, 220, 100));
    joint_shape_flat_.setStrokeWeight(0);
  }

  /******************************************************************************/
  /*!
      Transforms the coordinates of the joint position on the lady
      to local coordinates
  */
  /******************************************************************************/
  PVector Transform_To_Joint_Local(PVector transform_vector, float body_rotation)
  {
    // Translate from shoulder joint
    PVector limb_vector = new PVector(shoulder_joint_.x, shoulder_joint_.y);

    // Rotate
    limb_vector.rotate(body_rotation);

    // Transform
    transform_vector = PVector.add(limb_vector, transform_vector);

    // Translate
    PVector upper_arm = new PVector(upper_arm_length_, 0);

    // Rotate
    upper_arm.rotate(body_rotation);

    // Transform to right limb
    if (sin_multiplier_ == 1)
    {
      upper_arm.rotate(-upper_arm_theta_);

      transform_vector = PVector.add(transform_vector, upper_arm);
    }

    // Transform to left limb
    else
    {
      upper_arm.rotate(upper_arm_theta_ + PI);

      transform_vector = PVector.add(transform_vector, upper_arm);
    }

    return transform_vector;
  }

  /******************************************************************************/
  /*!
      Transforms the coordinates of the hoop position on the lady's wrist
      to local coordinates
  */
  /******************************************************************************/
  PVector Transform_To_Hoop_Local(PVector transform_vector, float body_rotation)
  {
    // Translate
    PVector forearm = new PVector(forearm_length_ + wrist_length_ * 10.5f, 1);

    // Rotate from body rotation
    forearm.rotate(body_rotation);

    // Transform to right limb
    if (sin_multiplier_ == 1)
    {
      // Rotate from upper arm
      forearm.rotate(-upper_arm_theta_);
      forearm.rotate(-forearm_theta_);

      // Transform
      transform_vector = PVector.add(transform_vector, forearm);
    }

    // Transform to left limb
    else
    {
      forearm.rotate(upper_arm_theta_ + PI);
      forearm.rotate(forearm_theta_);

      transform_vector = PVector.add(transform_vector, forearm);
    }

    return transform_vector;
  }

  /******************************************************************************/
  /*!
      Gets the rotation of the forearm so that the right Hoop can rotate with it
  */
  /******************************************************************************/
  float Get_Forearm_Rotation()
  {
    float upper_arm_theta_modifier = upper_arm_theta_ + QUARTER_PI;

    return forearm_theta_ - forearm_theta_default_ + upper_arm_theta_modifier;
  }
}
