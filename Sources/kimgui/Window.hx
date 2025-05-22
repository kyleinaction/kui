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
   * The inline function to call when the window is processed.
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
    // Handle input for the window
    ui.setCursor(0, 0);

    // Call the function to process the window
    if (fn != null) {
      fn();
    }
  }

  /**
   * Renders the window & it's contents.
   */
  public function render(ui:Kimgui, theme: Theme, x:Float, y:Float, width:Float, height:Float):Void {
    initTexture(previouslyDrawnWidth, previouslyDrawnHeight);

    // Set the texture as the drawing target for Kimgui
    var globalG = ui.g;

    // // End the global graphics context
    globalG.end();

    // // Start the window graphics context
    ui.g = texture.g2;
    ui.g.begin(false, theme.WINDOW_BG_COLOR);

      // Reset the cursor to the top left of the window
      ui.setCursor(0, 0);

      // Draw the window background contents
      ui.drawRect(x, y, width, height, theme.WINDOW_BG_COLOR);

    //   ui.drawString("WTF!!!!", 0, 0, theme.TEXT_COLOR, theme.TEXT_SIZE);

    //   // Iterate over draw list and render each element
    //   // for (element in drawList) {
    //   //   element.render(ui);
    //   // }
    
    //   previouslyDrawnHeight = Math.max(0, height);
    //   previouslyDrawnWidth  = Math.max(0, width);

    // // End the window graphics context
    ui.g.end();

    // // Return the graphics object to the original
    ui.g = globalG;

    // // Restart the original graphics context
    ui.g.begin(false);

    // Draw the window texture to the screen as specified by the parent
    // ui.g.drawScaledSubImage(texture, 0, 0, width, height, x, y, width, height);
  }

  /**
   * Sets the size of the window.
   */
  private function initTexture(width:Float, height:Float) {
    if (texture == null || texture.width != width || texture.height != height) {
      texture = kha.Image.createRenderTarget(Std.int(width), Std.int(height), kha.graphics4.TextureFormat.RGBA32, kha.graphics4.DepthStencilFormat.NoDepthAndStencil, 1);
    }
  }
}