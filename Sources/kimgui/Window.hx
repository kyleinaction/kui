package kimgui;

import kha.Image;

/**
 * Window is a class that represents a window in the Kimgui UI system.
 */
@:access(kimgui.Node)
class Window {
  /**
   * Parent node of this window.
   */
  public var node: Node;

  public var drawList: Array<Drawable>;

  /**
   * Window title.
   */
  public var title: String;

  /**
   * The window's texture.
   */
  public var texture: Image;

  /**
   * The final height of all elements drawn in the window on the previous frame, OR
   * the height of the parent node, whichever is greater.
   */
  public var previouslyDrawnHeight: Float;

  /**
   * The final width of all elements drawn in the window on the previous frame, OR
   * the width of the parent node, whichever is greater.
   */
  public var previouslyDrawnWidth: Float;

  /**
   * The function to process the main body of the window. This will generate
   * the draw list to be rendered later and will handle all input for the window.
   */ 
  public var fn: Void->Void;

  /**
   * Constructor.
   */
  public function new() {
    title = "";
    previouslyDrawnHeight = 0;
    previouslyDrawnWidth  = 0;
  }

  public function handleInput(ui:Kimgui, theme: Theme, x:Float, y:Float, width:Float, height:Float):Void {
    ui.setCursor(0, 0);
    drawList = [];
    // Call the function to process the window
    if (fn != null) {
      fn();
    }
  }

  /**
   * Renders the window & it's contents.
   */
  public function render(ui:Kimgui, theme: Theme, x:Float, y:Float, width:Float, height:Float):Void {
    // End main graphics context and store
    ui.g.end();
    var globalG = ui.g;

    // Update the window texture size if it has changed
    initTexture(previouslyDrawnWidth, previouslyDrawnHeight);

    // Attach the texture as the UI draw target
    ui.g = texture.g2;

    // Clear the texture
    ui.g.begin(true, theme.WINDOW_BG_COLOR);

    // Draw elements
    for (element in drawList) {
      element.render(ui);
    }

    // Finish texture drawing
    ui.g.end();

    // Restore the main graphics context
    ui.g = globalG;

    // Draw the window texture to the screen
    ui.g.begin(false);
    ui.g.drawScaledSubImage(texture, 0, 0, Std.int(width), Std.int(height), Std.int(x), Std.int(y), Std.int(width), Std.int(height));

    previouslyDrawnHeight = Math.max(0, height);
    previouslyDrawnWidth  = Math.max(0, width);
  }

  /**
   * Sets the size of the window.
   */
  private function initTexture(width:Float, height:Float) {
    width = Math.max(1, width);
    height = Math.max(1, height);

    if (texture == null || texture.width != width || texture.height != height) {
      texture = kha.Image.createRenderTarget(Std.int(width), Std.int(height), kha.graphics4.TextureFormat.RGBA32, kha.graphics4.DepthStencilFormat.NoDepthAndStencil, 1);
    }
  }
}