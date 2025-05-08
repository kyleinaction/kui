package kimgui;

/**
 * Main interface for Kimgui.
 */
class Kimgui {

  /**
   * An array of windows to be drawn. 
   */
  private var m_windows: Array<WindowDrawList>;

  private var m_ended: Bool;

  public function new() {

  }


  /**
   * Creates a new window.
   * 
   * @param handle The handle for the window.
   * @param title The title of the window.
   * @param draggable Whether the window is draggable or not.
   */
  public function window(handle: Handle, title: String, draggable: Bool = true):Void {

  }

  /**
   * Ends the current element.
   */
  public function end():Void {

  }
}


/**
 * WindowDrawList is a class that represents a draw list for a window.
 * Whenever a new window is created, 
 */
class WindowDrawList {
  private var m_list: Array<Drawable>;

  public function new() {
    // Constructor code here
  }
}

class Drawable {
  public function new() {
  }
}