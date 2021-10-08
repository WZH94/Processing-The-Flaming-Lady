/******************************************************************************/
/*!
\file   Flaming_Lady.pde
\author Wong Zhihao
\par    email: wongzhihao.student.utwente.nl
\date
\brief
  This file contains the implementation of the Flaming Lady class, which only
  contains data about the main position of the class, and acts mainly as an
  interface.
*/
/******************************************************************************/

class Flaming_Lady 
{
  private Body body_;

  private float scale_;           // Scales flaming lady
  private PVector pos_;           // This will be the point where the body meets the "dress", also pos of the body
  private boolean colour_type_;   // Gradient colouring <true> or flat <false>

  /******************************************************************************/
  /*!
      Constructor
  */
  /******************************************************************************/
  Flaming_Lady()
  { 
    // Default position
    pos_ = new PVector(width / 3, height * 0.65f);

    scale_ = 1.2f;
    colour_type_ = false;

    body_ = new Body(scale_);
  }

  /******************************************************************************/
  /*!
      Update components
  */
  /******************************************************************************/
  void Update()
  {
    body_.Update();
  }

  /******************************************************************************/
  /*!
      Draw components
  */
  /******************************************************************************/
  void Draw()
  {
    pushMatrix();

    translate(pos_.x, pos_.y);

    body_.Draw(colour_type_);

    popMatrix();
  }

  /******************************************************************************/
  /*!
      Called from main, calls to body, toggles dress strands high or low performance
  */
  /******************************************************************************/
  void Set_Dress_Strands_Performance()
  {
    body_.Set_Dress_Strands_Performance();
  }

  /******************************************************************************/
  /*!
      Called from main, toggles colouring lady with gradient strands or flat colour
  */
  /******************************************************************************/
  void Set_Colouring_Type()
  {
    colour_type_ = colour_type_ ? false : true;
  }

  /******************************************************************************/
  /*!
      Transforms the coordinates of the left hoop position on the lady's wrist
      to local coordinates
  */
  /******************************************************************************/
  PVector Transform_To_Left_Hoop()
  {
    // Translate
    PVector transform_vector = new PVector(pos_.x, pos_.y);

    transform_vector = body_.Transform_To_Left_Hoop_Local(transform_vector);

    return transform_vector;
  }

  /******************************************************************************/
  /*!
      Transforms the coordinates of the right hoop position on the lady's wrist
      to local coordinates
  */
  /******************************************************************************/
  PVector Transform_To_Right_Hoop()
  {
    // Translate
    PVector transform_vector = new PVector(pos_.x, pos_.y);

    transform_vector = body_.Transform_To_Right_Hoop_Local(transform_vector);

    return transform_vector;
  }

  /******************************************************************************/
  /*!
      Gets the rotation of the forearm so that the right Hoop can rotate with it
  */
  /******************************************************************************/
  float Get_Forearm_Rotation()
  {
    return body_.Get_Forearm_Rotation();
  }
}