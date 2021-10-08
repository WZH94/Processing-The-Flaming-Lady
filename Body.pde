/******************************************************************************/
/*!
\file   Body.pde
\author Wong Zhihao
\par    email: wongzhihao.student.utwente.nl
\date
\brief
  This file contains the implementation of the Flaming Lady's physical features.
  The body is contained here, which contains all the Flaming Lady's physical
  components.
*/
/******************************************************************************/

class Body
{
  // Body shape consists of left side (left of waist to neck), center (in between waist to neck), right (the rest)
  private PShape body_shape_group_;
  private PShape [] left_body_shapes_;
  private PShape [] center_body_shapes_;
  private PShape [] right_body_shapes_;

  // Alternative colour scheme which is just a filled body
  private PShape body_shape_flat_;

  private Head head_;
  private Limb left_limb_;
  private Limb right_limb_;

  // Inverse strand at right waist
  private Strand strand_;

  // Dress strands
  private Strand [] dress_strands_;
  private int num_dress_strands_;

  // Strands behind the shoulder
  private Strand [] shoulder_strands_;

  private float rotation_;           // How much the body is rotating
  private float max_rotation_;       // Max rotation of the body
  
  private float waist_width_;        // Width of the waistline
  private float shoulder_width_;     // Width of the shoulder, derived from waist_width
  private float body_height_;        // Height of the body, derived from canvas height
  private float neck_width_;         // Width of the neck

  // Colour range for gradient effect
  private color body_color_range_2_;

  // BEZIER POINTS
  private PVector bezier_left_waist_;
  private PVector bezier_right_waist_;

  private PVector bezier_left_neck_;
  private PVector bezier_right_neck_;

  /******************************************************************************/
  /*!
      Constructor of the Body
  */
  /******************************************************************************/
  Body(float scale)
  {
    // Rotation default to 0, max rotation is 12 degrees both sides
    rotation_ = radians(0);
    max_rotation_ = radians(13);

    // Body dimensions scales with canvas height
    waist_width_ = height / 12 * scale;
    shoulder_width_ = waist_width_ * 1.2f * scale;
    body_height_ = height / 3.4f * scale;

    body_color_range_2_ = color(222, 177, 13);

    bezier_left_waist_ = new PVector(-waist_width_ / 2, 0);
    bezier_right_waist_ = new PVector(waist_width_ / 2, 0);

    bezier_left_neck_ = new PVector(-waist_width_ / 4, -body_height_);
    bezier_right_neck_ = new PVector(waist_width_ / 4, -body_height_);

    neck_width_ = bezier_right_neck_.x - bezier_left_neck_.x;

    // Create the PShapes for the body
    Create_Body_Shape();
    Create_Body_Shape_Flat();

    head_= new Head(waist_width_);

    // Position the limbs near the shoulders
    left_limb_ = new Limb(bezier_left_waist_.x - (waist_width_ / 8), bezier_left_waist_.y - body_height_ * 1.03f, body_height_ * 1.15f, -1);
    right_limb_ = new Limb(bezier_right_waist_.x + (waist_width_ / 8), bezier_right_waist_.y - body_height_ * 1.03f, body_height_ * 1.15f, 1);

    // Started out as a test strand but now it's just here and looks nice
    strand_ = new Strand(STRAND_TYPE.inverse, 1.2, 15, radians(2), body_height_ * 0.8f, 20, false);

    // Change this number to alter number of dress strands
    num_dress_strands_ = 15;
    dress_strands_ = new Strand[num_dress_strands_];

    for (int i = 0; i < num_dress_strands_; ++i)
      dress_strands_[i] = new Strand(STRAND_TYPE.dress, 2, waist_width_ / 10f, random(radians(1), radians(5)), height / 2 * scale, height / 30 * scale, true);

    shoulder_strands_ = new Strand[2];

    for (int i = 0; i < 2; ++i)
      shoulder_strands_[i] = new Strand(STRAND_TYPE.hair, random(0.5, 1), random(waist_width_ * 0.2f, waist_width_ * 0.35f), 
                                        random(radians(0.3f), radians(1f)), random(waist_width_, shoulder_width_), random(waist_width_ * 0.15f, waist_width_ * 0.3f), true);
  }

  /******************************************************************************/
  /*!
      Updates the Body's components, detects input and rotates accordingly
  */
  /******************************************************************************/
  void Update()
  {
    // Manage inputs
    Input();

    head_.Update();

    strand_.Update();

    for (int i = 0; i < num_dress_strands_; ++i)
      dress_strands_[i].Update();

    for (int i = 0; i < 2; ++i)
      shoulder_strands_[i].Update();

    left_limb_.Update(rotation_, max_rotation_);
    right_limb_.Update(rotation_, max_rotation_);
  }

  /******************************************************************************/
  /*!
      Draws the body's components
  */
  /******************************************************************************/
  void Draw(boolean colour_type)
  {
    pushMatrix();

    rotate(rotation_);

    /******************************* DRAW LIMBS *******************************/

    left_limb_.Draw(colour_type);
    right_limb_.Draw(colour_type);

    /******************************* DRAW SHOULDER STRANDS *******************************/

    pushMatrix();

    // Translate first strand to left side of shoulder, rotate leftwards
    translate(bezier_left_neck_.x , bezier_left_neck_.y);
    rotate(PI + QUARTER_PI);

    shoulder_strands_[0].Draw();

    popMatrix();

    pushMatrix();

    // Translate second strand to right side of shoulder, rotate rightwards
    translate(bezier_right_neck_.x , bezier_right_neck_.y);
    rotate(-HALF_PI + QUARTER_PI);

    shoulder_strands_[1].Draw();

    popMatrix();

    /******************************* DRAW HEAD *******************************/

    pushMatrix();

    translate(bezier_left_neck_.x + waist_width_ / 4, bezier_left_neck_.y);
    rotate(rotation_ / 2);  // Head rotates half of body

    head_.Draw(colour_type);

    popMatrix();

    /******************************* DRAW BODY *******************************/

    if (colour_type)
      shape(body_shape_group_);

    else shape(body_shape_flat_);

    /******************************* DRAW WAIST STRAND *******************************/

    pushMatrix();

    translate(bezier_right_waist_.x, bezier_right_waist_.y - degrees(rotation_));

    strand_.Draw();

    popMatrix();

    popMatrix();  // Pops body rotation

    /******************************* DRAW DRESS STRANDS *******************************/

    pushMatrix();

    // Dress strands rotates a third of body rotation
    rotate(rotation_ / 3);

    for (int i = 0; i < num_dress_strands_; ++i)
    {
      pushMatrix();

      // Translates each subsequent strand 1 / num_dress_strands to the right of the waist
      translate(bezier_left_waist_.x + (float(i) / (num_dress_strands_ - 1) * waist_width_), -body_height_ / 100);
      // Rotates each strand from leftwards to rightwards
      rotate(radians(120) - (float(i) / num_dress_strands_ * radians(60)));

      dress_strands_[i].Draw();

      popMatrix();
    }

    popMatrix();
  }

  /******************************************************************************/
  /*!
      Check for input to rotate the body
  */
  /******************************************************************************/
  void Input()
  {
    if (keys_manager.Check_Key(KEY.A))
    {
      // Speed of rotation of body
      rotation_ -= radians(0.4f);

      // Snap back
      if (rotation_ < -max_rotation_)
        rotation_ = -max_rotation_;
    }

    if (keys_manager.Check_Key(KEY.D))
    {
      rotation_ += radians(0.4f);

      if (rotation_ > max_rotation_)
        rotation_ = max_rotation_;
    }
  }

  /******************************************************************************/
  /*!
      Creates the shape of the body through the use of lines in increasing and
      decreasing gradients. Draws U-D, gradient changes L-R
  */
  /******************************************************************************/
  void Create_Body_Shape()
  {
    body_shape_group_ = createShape(GROUP);

    /************************************************** CREATE LEFT SHAPE **************************************************/

    // Just took a modifier in the bezier vertices and used it as the amount of times to draw
    int num_left_body_strands = int(shoulder_width_ * 1.15f) + 1;

    left_body_shapes_ = new PShape[num_left_body_strands];

    // Create left side of body shape
    for (int i = num_left_body_strands - 1; i >= 0; --i)
    {
      float ratio = float(i + 1) / num_left_body_strands;

      left_body_shapes_[i] = createShape();

      left_body_shapes_[i].beginShape();

      left_body_shapes_[i].stroke(lerpColor(lerpColor(main_color_range_1, main_color_range_2, 0.35f), lerpColor(main_color_range_1, main_color_range_2, 0.2f), ratio));
      left_body_shapes_[i].strokeWeight(1);

      left_body_shapes_[i].vertex(bezier_left_waist_.x, bezier_left_waist_.y);
      left_body_shapes_[i].bezierVertex(bezier_left_waist_.x - i, bezier_left_waist_.y - (body_height_ * 1.15f * ratio),
                   bezier_left_neck_.x, bezier_left_neck_.y - (body_height_ * 0.08f * ratio),
                   bezier_left_neck_.x, bezier_left_neck_.y);

      left_body_shapes_[i].endShape();

      body_shape_group_.addChild(left_body_shapes_[i]);
    }

    /************************************************** CREATE CENTER SHAPE **************************************************/

    // Waist is thicker than neck so use that
    int num_center_body_strands = int(bezier_right_waist_.x - bezier_left_waist_.x) + 1;
    center_body_shapes_ = new PShape[num_center_body_strands];

    for (int i = 0; i < num_center_body_strands; ++i)
    {
      float ratio = float(i + 1) / num_center_body_strands;

      // First third
      if (i <= num_center_body_strands / 3f)
      {
        // Ratio out of a third
        float third_ratio = float(i + 1) / (num_center_body_strands / 3f);

        center_body_shapes_[i] = createShape(LINE, bezier_left_waist_.x + i, bezier_left_waist_.y, 
                                                   bezier_left_neck_.x + neck_width_ * ratio, bezier_left_neck_.y - (bezier_left_neck_.y * 0.01f) * third_ratio);

        center_body_shapes_[i].setStroke(lerpColor(lerpColor(main_color_range_1, main_color_range_2, 0.35f), lerpColor(main_color_range_1, main_color_range_2, 0.15f), third_ratio));
      }

      // Last third
      else if (i >= 2f * num_center_body_strands / 3f)
      {
        center_body_shapes_[i] = createShape(LINE, bezier_left_waist_.x + i, bezier_left_waist_.y, 
                                                   bezier_left_neck_.x + neck_width_ * ratio, bezier_left_neck_.y - (bezier_left_neck_.y * 0.01f) * (num_center_body_strands - i) / (num_center_body_strands / 3f));

        center_body_shapes_[i].setStroke(lerpColor(lerpColor(main_color_range_1, main_color_range_2, 0.15f), lerpColor(main_color_range_1, main_color_range_2, 0.35f), (float(i + 1) - (2f * (num_center_body_strands / 3f))) / (num_center_body_strands / 3f)));
      }

      // Middle third
      else 
      {
        center_body_shapes_[i] = createShape(LINE, bezier_left_waist_.x + i, bezier_left_waist_.y, 
                                                   bezier_left_neck_.x + neck_width_ * ratio, bezier_left_neck_.y - (bezier_left_neck_.y * 0.01f));

        center_body_shapes_[i].setStroke(lerpColor(main_color_range_1, main_color_range_2, 0.15f));
      }

      center_body_shapes_[i].setStrokeWeight(1);

      body_shape_group_.addChild(center_body_shapes_[i]);
    }

    /************************************************** CREATE RIGHT SHAPE **************************************************/

    // Just took a modifier in the bezier vertices and used it as the amount of times to draw
    int num_right_body_strands = int(shoulder_width_ * 1.15f) + 1;
    right_body_shapes_ = new PShape[num_right_body_strands];

    // Create right side of body shape
    for (int i = num_right_body_strands - 1; i >= 0; --i)
    {
      float ratio = float(i + 1) / num_right_body_strands;

      right_body_shapes_[i] = createShape();

      right_body_shapes_[i].beginShape();

      right_body_shapes_[i].stroke(lerpColor(lerpColor(main_color_range_1, main_color_range_2, 0.35f), lerpColor(main_color_range_1, main_color_range_2, 0.7f), ratio));
      right_body_shapes_[i].strokeWeight(1);

      right_body_shapes_[i].vertex(bezier_right_waist_.x, bezier_right_waist_.y);
      right_body_shapes_[i].bezierVertex(bezier_right_waist_.x + i, bezier_right_waist_.y - (body_height_ * 1.15f * ratio),
                   bezier_right_neck_.x, bezier_right_neck_.y - (body_height_ * 0.08f * ratio),
                   bezier_right_neck_.x, bezier_right_neck_.y);

      right_body_shapes_[i].endShape();

      body_shape_group_.addChild(right_body_shapes_[i]);
    }
  }

  /******************************************************************************/
  /*!
      Creates the shape of the body through the use of bezier vertices and
      filled colour.
  */
  /******************************************************************************/
  void Create_Body_Shape_Flat()
  {
    body_shape_flat_ = createShape();

    body_shape_flat_.beginShape();

    body_shape_flat_.noStroke();
    body_shape_flat_.fill(color(190, 140, 80));

    body_shape_flat_.vertex(bezier_left_waist_.x, bezier_left_waist_.y);
    body_shape_flat_.bezierVertex(bezier_left_waist_.x - shoulder_width_ * 1.15f, bezier_left_waist_.y - (body_height_ * 1.15f),
                                  bezier_left_neck_.x, bezier_left_neck_.y - (body_height_ * 0.08f),
                                  bezier_left_neck_.x, bezier_left_neck_.y);

    body_shape_flat_.quadraticVertex(bezier_left_neck_.x + (bezier_right_neck_.x - bezier_left_neck_.x) * 0.5f, bezier_left_neck_.y * 0.99f,
                                     bezier_right_neck_.x, bezier_right_neck_.y);

    body_shape_flat_.bezierVertex(bezier_right_neck_.x, bezier_right_neck_.y - (body_height_ * 0.08f),
                                  bezier_right_waist_.x + shoulder_width_ * 1.15f, bezier_right_waist_.y - (body_height_ * 1.15f),
                                  bezier_right_waist_.x, bezier_right_waist_.y);

    body_shape_flat_.endShape(CLOSE);
  }

  /******************************************************************************/
  /*!
      Alternates between low and high performance of the dress strands, only
      for showcasing. Called by Flaming_Lady, calls to Strand
  */
  /******************************************************************************/
  void Set_Dress_Strands_Performance()
  {
    for (int i = 0; i < num_dress_strands_; ++i)
      dress_strands_[i].Set_Dress_Strands_Performance();
  }

  /******************************************************************************/
  /*!
      Transforms the coordinates of the left joint position
      to local coordinates
  */
  /******************************************************************************/
  PVector Transform_To_Left_Joint_Local(PVector transform_vector)
  {
    transform_vector = left_limb_.Transform_To_Joint_Local(transform_vector, rotation_);

    return transform_vector;
  }

  /******************************************************************************/
  /*!
      Transforms the coordinates of the left hoop position on the lady's wrist
      to local coordinates
  */
  /******************************************************************************/
  PVector Transform_To_Left_Hoop_Local(PVector transform_vector)
  {
    transform_vector = left_limb_.Transform_To_Joint_Local(transform_vector, rotation_);
    transform_vector = left_limb_.Transform_To_Hoop_Local(transform_vector, rotation_);

    return transform_vector;
  }

  /******************************************************************************/
  /*!
      Transforms the coordinates of the right joint position
      to local coordinates
  */
  /******************************************************************************/
  PVector Transform_To_Right_Joint_Local(PVector transform_vector)
  {
    transform_vector = right_limb_.Transform_To_Joint_Local(transform_vector, rotation_);

    return transform_vector;
  }

  /******************************************************************************/
  /*!
      Transforms the coordinates of the right hoop position on the lady's wrist
      to local coordinates
  */
  /******************************************************************************/
  PVector Transform_To_Right_Hoop_Local(PVector transform_vector)
  {
    transform_vector = right_limb_.Transform_To_Joint_Local(transform_vector, rotation_);
    transform_vector = right_limb_.Transform_To_Hoop_Local(transform_vector, rotation_);

    return transform_vector;
  }

  /******************************************************************************/
  /*!
      Gets the rotation of the forearm so that the right Hoop can rotate with it
  */
  /******************************************************************************/
  float Get_Forearm_Rotation()
  {
    return right_limb_.Get_Forearm_Rotation();
  }
}
