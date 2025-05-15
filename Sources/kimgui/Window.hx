package kimgui;

/**
 * Window is a class that represents a window in the Kimgui UI system.
 */
@:access(kimgui.Node)
class Window {
  /**
   * Parent node of this window.
   */
  public var node: Node;

  /**
   * Window title.
   */
  public var title: String;

  /**
   * Constructor.
   */
  public function new() {
    title = "";
  }

  /**
   * Renders the window & it's contents.
   */
  public function render(ui:Kimgui, theme: Theme, x:Float, y:Float, width:Float, height:Float):Void {
    // Next draw body background
    ui.drawRect(x, y, width, height, theme.WINDOW_BG_COLOR);
  }
}


class Drawable {
  public function new() {
  }
}