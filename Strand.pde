/******************************************************************************/
/*!
\file   Strand.pde
\author Wong Zhihao
\par    email: wongzhihao.student.utwente.nl
\date
\brief
  This file contains the implementation of the Strand class. There are 4 types,
  2 are sin waves, one red one yellow, one is hair type which is thicker at the
  root and thinner at the tip, last is an inverse 3D looking thingy
*/
/******************************************************************************/

enum STRAND_TYPE
{
  dress,   // Sin wave, red
  wavy,    // Sin wave, yellow
  hair,    // Thick curl, yellow
  inverse  // 3D like flat tape thingy
}

class Strand
{
  private boolean low_performance_;       // Colour gradient or flat colour
  
  private STRAND_TYPE strand_type_;       // What type of strand is it
  private PVector [] segments_;           // The coordinates of every segment
  
  private final int num_segments_;        // Total number of segments   
  private final int segs_per_period_;     // Number of segments per period
  
  private float periods_;                 // Number of full periods this strand can whip
  private float amplitude_; 
  private float frequency_;               // How quickly the sin wave progresses
        
  private float sin_theta_;               // Current theta of progression through sin wave
  private float length_;                  // The length of the entire whip
  private float thickness_;               // The thickness of the whip
        
  private float segment_space_;           // Space between each segment
    
  private float wave_theta_;              // Current theta of strand waving around
  private float rotation_theta_;          
  private float wave_speed_;              // Speed at which it whips at
  float wave_range_;                      // Range the strand can whip at
  
  private color colour_range_1_;          // Colour gradiant
  private color colour_range_2_;  
  
  private color low_performance_colour_;  // Flat colour for low performance

  // Vectors to save positions of previous and current segments 
  private PVector [] prev_seg_pos_;
  private PVector [] current_seg_pos_;

  // Vectors to save positions to draw segments at
  private PVector [][] draw_pos_1_;
  private PVector [][] draw_pos_2_;
  private float [] individual_thickness_;

  /******************************************************************************/
  /*!
      Constructor for the Strand, you can edit the type, how many periods the wave
      has, how big the amplitude of the wave is, how quickly it progresses through
      the sin wave, how long the wave is, how thick it is, and the performance.
  */
  /******************************************************************************/
  Strand(STRAND_TYPE type, float periods, float amplitude, float frequency, float length, float thickness, boolean low_performance)
  {
    low_performance_ = low_performance;

    strand_type_ = type;

    // Any lesser and the segment points might be obvious
    segs_per_period_ = 25;

    periods_ = periods;
    amplitude_ = amplitude;
    frequency_ = frequency;
    
    num_segments_ = int(periods_ * segs_per_period_);
    segments_ = new PVector[num_segments_];
    // 1000 is an arbitarily large number that will not be reached in this program
    draw_pos_1_ = new PVector[num_segments_][1000];
    draw_pos_2_ = new PVector[num_segments_][1000];
    individual_thickness_ = new float[num_segments_];

    // Sin wave starts anywhere in the period
    sin_theta_ = random(TWO_PI);
    length_ = length;
    thickness_ = thickness;

    // The space between each segment point
    segment_space_ = length_ / num_segments_;

    // Wave theta starts anywhere in the period
    wave_theta_ = random(TWO_PI);

    // Dress strands have different colour and wave properties
    if (type == STRAND_TYPE.dress)
    {
      colour_range_1_ = color(205, 38, 48);
      colour_range_2_ = color(90, 50, 85);

      wave_speed_ = random(radians(0.2), radians(1));
      wave_range_ = random(radians(2), radians(8));
    }

    else
    {
      colour_range_1_ = color(190, 140, 80);
      colour_range_2_ = color(185, 100, 50);

      // Hair strands wave around less
      if (type == STRAND_TYPE.hair)
      {
        wave_speed_ = random(radians(0.3f), radians(1.2f));
        wave_range_ = random(radians(1), radians(3.5f));
      }

      else
      {
        wave_speed_ = random(radians(0.4f), radians(1.5f));
        wave_range_ = random(radians(3), radians(12));
      }
    }

    // Random colour for each low performance strand
    low_performance_colour_ = lerpColor(colour_range_1_, colour_range_2_, random(1));

    // Allocate memory for segment and position values
    for (int i = 0; i < num_segments_; ++i)
    {
      segments_[i] = new PVector(i * segment_space_, thickness_);

      for (int j = 0; j < 1000; ++j)
      {
        draw_pos_1_[i][j] = new PVector();
        draw_pos_2_[i][j] = new PVector();
      }

      individual_thickness_[i] = 0;
    }

    // 0 is top pos, 1 is bottom pos
    prev_seg_pos_ = new PVector[2];
    current_seg_pos_ = new PVector[2];

    for (int i = 0; i < 2; ++i)
    {
      prev_seg_pos_[i] = new PVector();
      current_seg_pos_[i] = new PVector();
    }
  }

  /******************************************************************************/
  /*!
      Updates the strand
  */
  /******************************************************************************/
  void Update()
  {
    noStroke();

    // Amplitude
    float y_offset = sin(TWO_PI + sin_theta_) * amplitude_;

    // Progress through sin waves
    sin_theta_ += frequency_;
    wave_theta_ += wave_speed_;
    // Limit the rotation of the wave to the sin wave's y-axis and multiply by the range of movement
    rotation_theta_ = wave_range_ * sin(wave_theta_);

    // Set the segments to progress through the sin wave
    if (strand_type_ == STRAND_TYPE.hair)
      for (int i = 0; i < num_segments_; ++i)
      {
        // sin of two_pi over the entire segment, added by sin_theta to progress through sin wave. Multiply by i over segs_per_period, so wave is less active at the first few segs and more active 
        // through the segments 
        segments_[i].y = float(i) / float(segs_per_period_ / 2) * (sin(float(i) / float(segs_per_period_) * (TWO_PI) + sin_theta_) * amplitude_) - y_offset * float(i) / float(segs_per_period_ / 2);
      }

    else for (int i = 0; i < num_segments_; ++i)
    {
      // sin of two_pi over the entire segment, added by sin_theta to progress through sin wave. y_offset to keep the first segment in the same spot
      segments_[i].y = (sin(float(i) / float(segs_per_period_) * (TWO_PI) + sin_theta_) * amplitude_) - y_offset;
    }

    // Calculates the drawing of the strand
    Calculate_Strand_Shape();
  }

  /******************************************************************************/
  /*!
      Draws the strand
  */
  /******************************************************************************/
  void Draw()
  {
    // Rotate based on wave
    pushMatrix();
    rotate(rotation_theta_);

    // Prints out little balls at the strand tips so it looks fatter
    if (strand_type_ == STRAND_TYPE.dress)
    {
      if (low_performance_)
      {
        fill(colour_range_2_);
        ellipse(0, 0, thickness_ / 4, thickness_ / 4);
      }

      else
      {
        for (int i = 0; i < thickness_ / 4; ++i)
        {
          stroke(lerpColor(colour_range_1_, colour_range_2_, i / thickness_ / 4));
          ellipse(0, 0, i, i);
        }
      }
    }

    beginShape(TRIANGLE_STRIP);

    // Loop through every segment and print out the draw_pos at those segments
    for (int i = 0; i < num_segments_; i++) 
    {
      // Low performance strand OR inverse strand type
      if (low_performance_ == true || strand_type_ == STRAND_TYPE.inverse)
      {
        // Inverse strand has stroke
        if (strand_type_ == STRAND_TYPE.inverse)
        {
          stroke(0);
          strokeWeight(1);
        }

        else noStroke();

        fill(low_performance_colour_);

        vertex(draw_pos_1_[i][0].x, draw_pos_1_[i][0].y);
        vertex(draw_pos_2_[i][0].x, draw_pos_2_[i][0].y);
      }

      // High performance strand
      else
      {
        noFill();
        strokeWeight(1);

        // Print out one line per pixel of thickness to create gradient effect
        for (int j = 0; j < individual_thickness_[i]; ++j)
        {
          // Gradient colour
          stroke(lerpColor(colour_range_1_, colour_range_2_, j / individual_thickness_[i]));

          vertex(draw_pos_1_[i][j].x, draw_pos_1_[i][j].y);
          vertex(draw_pos_2_[i][j].x, draw_pos_2_[i][j].y);
        }
      }
    }

    endShape();

    popMatrix();
  }

  /******************************************************************************/
  /*!
      Calculates the positions to draw the strands at since the segment positions
      are just one straight line. This gives the strand a thickness and fluidity.
  */
  /******************************************************************************/
  void Calculate_Strand_Shape()
  {
    // Loop through every point and calculate the vertex positions
    for (int i = 0; i < num_segments_; ++i) 
    {
      // The distance in x and y between current segment and the previous
      float diff_x, diff_y;

      if (i == 0) 
      {
        diff_x = segments_[1].x - segments_[0].x;
        diff_y = segments_[1].y - segments_[0].y;
      }

      else 
      {
        diff_x = segments_[i].x - segments_[i - 1].x;
        diff_y = segments_[i].y - segments_[i - 1].y;
      }
      
      // Angle between previous and current segment
      float theta;

      // This was a mistake but it came out looking cool so I kept it as a different strand type
      if (strand_type_ == STRAND_TYPE.inverse)
        theta = -atan2(diff_x, diff_y);

      else theta = -atan2(diff_y, diff_x);
      
      // Position over all the segments
      float pos = i / float(num_segments_ - 1);

      // Gives the strand the thickness
      float thickness_multiplier;

      // Bezier point goes by thickness at root, midway point, midway point, tip, which position of the strand to return the thickness
      if (strand_type_ == STRAND_TYPE.hair)
        // Hair starts out thickest at root and gets thinner
        thickness_multiplier = bezierPoint(thickness_, thickness_ * 0.7f, thickness_ * 0.4f, 2, pos);

      else if (strand_type_ == STRAND_TYPE.dress)
        // Dress just has a little more thickness at root 
        thickness_multiplier = bezierPoint(thickness_ / 10, thickness_, thickness_, 1, pos);

      // Normal sin
      else thickness_multiplier = bezierPoint(1, thickness_, thickness_, 1, pos);

      // Translate to the top and bottom of the current segment by thickness
      float top_x = segments_[i].x - sin(theta) * thickness_multiplier;
      float top_y = segments_[i].y - cos(theta) * thickness_multiplier;
      
      float bottom_x = segments_[i].x + sin(theta) * thickness_multiplier;
      float bottom_y = segments_[i].y + cos(theta) * thickness_multiplier;

      // Low performance just fills out the strand and draws it out through triangle strips
      if (low_performance_ == true || strand_type_ == STRAND_TYPE.inverse)
      {
        draw_pos_1_[i][0].set(top_x, top_y);
        draw_pos_2_[i][0].set(bottom_x, bottom_y);
      }

      // High performance is more complicated
      else
      {
        // Set the previous and current seg pos
        if (i == 0)
        {
          prev_seg_pos_[0].set(top_x, top_y);
          prev_seg_pos_[1].set(bottom_x, bottom_y);
          current_seg_pos_[0].set(top_x, top_y);
          current_seg_pos_[1].set(bottom_x, bottom_y);
        }

        else
        {
          current_seg_pos_[0].set(top_x, top_y);
          current_seg_pos_[1].set(bottom_x, bottom_y);
        }

        // Find the thickness of the previous and current top and bottom points.
        float left_thickness = prev_seg_pos_[1].y - prev_seg_pos_[0].y;
        float right_thickness = bottom_y - top_y;

        // Finds the thicker segment and saves it
        individual_thickness_[i] = Convert_Unsigned(right_thickness) >= Convert_Unsigned(left_thickness) ? right_thickness : left_thickness;

        individual_thickness_[i] = Convert_Unsigned(individual_thickness_[i]);

        // Loops through the thickness
        for (int j = 0; j < individual_thickness_[i]; ++j)
        {
          // Find the y_pos based on where it is looping
          float left_y_pos = float(j) / individual_thickness_[i] * left_thickness;
          float right_y_pos = float(j) / individual_thickness_[i] * right_thickness;

          draw_pos_1_[i][j].set(prev_seg_pos_[0].x, prev_seg_pos_[0].y + left_y_pos);
          draw_pos_2_[i][j].set(current_seg_pos_[0].x, current_seg_pos_[0].y + right_y_pos);
        }

        prev_seg_pos_[0].set(current_seg_pos_[0]);
        prev_seg_pos_[1].set(current_seg_pos_[1]);
      }
    }
  }

  /******************************************************************************/
  /*!
      Helper function to convert negatives to positives
  */
  /******************************************************************************/
  float Convert_Unsigned(float value)
  {
    if (value < 0)
    {
      float unsigned_value = value * -1;

      return unsigned_value;
    }

    else return value;  
  }

  /******************************************************************************/
  /*!
      Toggles the dress strands high and low performance
  */
  /******************************************************************************/
  void Set_Dress_Strands_Performance()
  {
    low_performance_ = low_performance_ ? false : true;
  }
}