/******************************************************************************/
/*!
\file   Keys_Manager.pde
\author Wong Zhihao
\par    email: wongzhihao.student.utwente.nl
\date
\brief
  This file contains the implementation of the Keys_Manager class. It simply
  stores keys that require unbuffered inputs only
*/
/******************************************************************************/

enum KEY
{
  // Give each key a value (why can't it be automated in Java why why why???)
  W(0),
  S(1),
  A(2),
  D(3),
  UP(4),
  DOWN(5),
  LEFT(6),
  RIGHT(7),

  LAST(8);

  int value;

  // Constructor for the key
  private KEY(int value_)
  {
    value = value_;
  }
};

class Keys_Manager
{
  private boolean [] keys_; // Whether the key is pressed or released
  private int num_keys_;    // How many keys is being kept tracked of

  /******************************************************************************/
  /*!
      Constructor
  */
  /******************************************************************************/
  Keys_Manager()
  {
    num_keys_ = KEY.LAST.value;

    keys_ = new boolean[num_keys_];

    // Set all keys to released
    for (int i = 0; i < num_keys_; ++i)
      keys_[i] = false;
  }

  // Return if key is pressed or released
  boolean Check_Key(KEY key)
  {
    return keys_[key.value];
  }

  // Set key to pressed
  void Key_Pressed(KEY key)
  {
    keys_[key.value] = true;
  }

  // Set key to released
  void Key_Released(KEY key)
  {
    keys_[key.value] = false;
  }
}
