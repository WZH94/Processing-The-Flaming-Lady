/******************************************************************************/
/*!
\file   Head.pde
\author Wong Zhihao
\par    email: wongzhihao.student.utwente.nl
\date
\brief
  This file contains the implementation of the Head class, which consists of the
  head and neck, and the hair strand(s).
*/
/******************************************************************************/

class Head
{
  // Head shape gradient
  private PShape head_shape_group_;
  private PShape [] head_shapes_;

  // Neck shape gradient
  private PShape neck_shape_group_;
  private PShape [] neck_shapes_;

  // Neck shape flat colour
  private PShape neck_shape_flat_;

  private Strand hair_strands_;

  private float neck_height_;
  private float neck_width_;

  private PVector head_size_;
  private PVector head_pos_;

  private float head_y_offset_multiplier_;

  private color head_colour_range_1_;
  private color head_colour_range_2_;
  private color neck_colour_;
  
  // BEZIER POINTS
  private PVector left_neck_base_;
  private PVector right_neck_base_;
  
  private PVector left_neck_top_;
  private PVector right_neck_top_;

  /******************************************************************************/
  /*!
      Constructor for the Head
  */
  /******************************************************************************/
  Head(float shoulder_width)
  {
    head_y_offset_multiplier_ = 1.35f;

    left_neck_base_ = new PVector(-shoulder_width / 4, 0);
    right_neck_base_ = new PVector(shoulder_width / 4, 0);

    neck_width_ = right_neck_base_.x - left_neck_base_.x;
    neck_height_ = shoulder_width * 1.25f;

    left_neck_top_ = new PVector(left_neck_base_.x, left_neck_base_.y - neck_height_);

    head_size_ = new PVector(neck_height_ * 0.8f, neck_height_);
    head_pos_ = new PVector(left_neck_top_.x + (neck_width_ / head_y_offset_multiplier_), left_neck_top_.y);

    right_neck_top_ = new PVector(head_pos_.x + (head_size_.x / 2), right_neck_base_.y - neck_height_);

    head_colour_range_1_ = main_color_range_1;
    head_colour_range_2_ = color(67, 166, 245);
    neck_colour_ = color(185, 100, 50);

    // Create PShapes
    Create_Head_Shape();

    Create_Neck_Shape();
    Create_Neck_Shape_Flat();

    hair_strands_ = new Strand(STRAND_TYPE.hair, 0.6f, head_size_.y / 2, random(radians(0.2), radians(1.2)), head_size_.y * 2, head_size_.x / 3, true);
  }

  /******************************************************************************/
  /*!
      Updates the Head's components
  */
  /******************************************************************************/
  void Update()
  {
    hair_strands_.Update();
  }

  /******************************************************************************/
  /*!
      Draws the Head's components
  */
  /******************************************************************************/
  void Draw(boolean colour_type)
  {
    pushMatrix();

    translate(left_neck_top_.x + neck_width_ / 2, left_neck_top_.y);
    rotate(radians(260));

    hair_strands_.Draw();

    popMatrix();

    /******************************************* PRINTS NECK *******************************************/

    if (colour_type)
      shape(neck_shape_group_);

    else shape(neck_shape_flat_);

    pushMatrix();

    translate(head_pos_.x, head_pos_.y);

    /******************************************* PRINTS HEAD *******************************************/

    shape(head_shape_group_);

    popMatrix();
  }

  /******************************************************************************/
  /*!
      Creates the PShape for the Head with colour gradient
  */
  /******************************************************************************/
  void Create_Head_Shape()
  {
    head_shape_group_ = createShape(GROUP);
    head_shapes_ = new PShape[int(head_size_.x) + 1];

    head_shapes_[int(head_size_.x)] = createShape(ELLIPSE, 0, 0, head_size_.x, head_size_.y);
    head_shapes_[int(head_size_.x)].setStroke(color(81, 107, 206));
    head_shapes_[int(head_size_.x)].setStrokeWeight(7);

    head_shape_group_.addChild(head_shapes_[int(head_size_.x)]);

    for (int i = int(head_size_.x); i > 0; --i)
    {
      head_shapes_[i] = createShape(ELLIPSE, 0, 0, i, i / head_size_.x * head_size_.y);

      // Randomise stroke colour
      head_shapes_[i].setStroke(lerpColor(head_colour_range_1_, head_colour_range_2_, i / head_size_.x));
      head_shapes_[i].setStrokeWeight(1);

      head_shape_group_.addChild(head_shapes_[i]);
    } 
  }

  /******************************************************************************/
  /*!
      Creates the PShape for the Neck with colour gradient
  */
  /******************************************************************************/
  void Create_Neck_Shape()
  {
    neck_shape_group_ = createShape(GROUP);

    int num_strands = int(neck_width_) + 1;
    neck_shapes_ = new PShape[num_strands];

    // SAME CONCEPT AND COLOURS AS THE CENTER BODY SHAPE
    for (int i = 0; i < num_strands; ++i)
    {
      neck_shapes_[i] = createShape();

      // First third
      if (i <= num_strands / 3f)
      {
        float third_ratio = ((num_strands / 3f) - float(i)) / (num_strands / 3f);

        neck_shapes_[i].beginShape();

        neck_shapes_[i].strokeWeight(1);
        neck_shapes_[i].noFill();

        neck_shapes_[i].stroke(lerpColor(lerpColor(main_color_range_1, main_color_range_2, 0.35f), lerpColor(main_color_range_1, main_color_range_2, 0.15f), float(i + 1) / (num_strands / 3f)));

        neck_shapes_[i].vertex(left_neck_base_.x + i, left_neck_base_.y + 10f);

        neck_shapes_[i].bezierVertex(left_neck_base_.x + i + (neck_width_ / 4) * third_ratio, left_neck_base_.y - neck_height_ * 0.4f,
                                     left_neck_base_.x + i + (neck_width_ / 5) * third_ratio, left_neck_base_.y - neck_height_ * 0.7f,
                                     left_neck_base_.x + i, left_neck_top_.y);

        neck_shapes_[i].endShape();
      }

      // Last third
      else if (i >= 2f * num_strands / 3f)
      {
        float third_ratio = (float(i + 1) - (2f * (num_strands / 3f))) / (num_strands / 3f);

        neck_shapes_[i].beginShape();

        neck_shapes_[i].strokeWeight(1);
        neck_shapes_[i].noFill();

        neck_shapes_[i].stroke(lerpColor(lerpColor(main_color_range_1, main_color_range_2, 0.15f), lerpColor(main_color_range_1, main_color_range_2, 0.35f), (float(i + 1) - (2f * (num_strands / 3f))) / (num_strands / 3f)));

        neck_shapes_[i].vertex(left_neck_base_.x + i, left_neck_base_.y + 10f);

        neck_shapes_[i].bezierVertex(left_neck_base_.x + i - (neck_width_ / 10) * third_ratio, right_neck_base_.y - neck_height_ * 0.7f,
                                     left_neck_base_.x + i - (neck_width_ / 10) * third_ratio, right_neck_base_.y - neck_height_ * 0.4f,
                                     left_neck_base_.x + i, left_neck_top_.y);

        neck_shapes_[i].endShape();
      }

      // Middle third
      else 
      {
        neck_shapes_[i] = createShape(LINE, left_neck_base_.x + i, left_neck_base_.y + 10f, 
                                            left_neck_base_.x + i, left_neck_top_.y);

        neck_shapes_[i].setStroke(lerpColor(main_color_range_1, main_color_range_2, 0.15f));
      }

      neck_shape_group_.addChild(neck_shapes_[i]);
    }
  }

  /******************************************************************************/
  /*!
      Creates the PShape for the Head with flat colour
  */
  /******************************************************************************/
  void Create_Neck_Shape_Flat()
  {
    neck_shape_flat_ = createShape();

    neck_shape_flat_.beginShape();

    neck_shape_flat_.noStroke();
    neck_shape_flat_.fill(neck_colour_);

      // Draws from left neck base to top head
      neck_shape_flat_.vertex(left_neck_base_.x, left_neck_base_.y + 10f);

      neck_shape_flat_.bezierVertex(left_neck_base_.x + ((right_neck_base_.x - left_neck_base_.x) / 4), left_neck_base_.y - neck_height_ * 0.4f,
                   left_neck_base_.x + ((right_neck_base_.x - left_neck_base_.x) / 5), left_neck_base_.y - neck_height_ * 0.7f,
                   left_neck_top_.x, left_neck_top_.y);

      // Draws from left neck top to right neck top
      neck_shape_flat_.bezierVertex(left_neck_top_.x, left_neck_top_.y,
                   left_neck_top_.x, left_neck_top_.y,
                   right_neck_top_.x, right_neck_top_.y);

      neck_shape_flat_.bezierVertex(right_neck_base_.x - ((right_neck_base_.x - left_neck_base_.x) / 10), right_neck_base_.y - neck_height_ * 0.7f,
                   right_neck_base_.x - ((right_neck_base_.x - left_neck_base_.x) / 10), right_neck_base_.y - neck_height_ * 0.4f,
                   right_neck_base_.x, right_neck_base_.y + 10f);

    neck_shape_flat_.endShape();
  }
}