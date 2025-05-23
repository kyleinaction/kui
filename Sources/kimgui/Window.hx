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
   * Constructor.
   */
  public function new() {
    title = "";
    previouslyDrawnHeight = 0;
    previouslyDrawnWidth  = 0;
  }

  public function isActive(): Bool {
    return node.activeWindow == this;
  }

  /**
   * Renders the window & it's contents.
   */
  public function begin(ui:Kimgui, theme: Theme):Void {
    initTexture(previouslyDrawnWidth, previouslyDrawnHeight);
    ui.setCursor(0, 0);
    ui.g = texture.g2;
    ui.g.begin(true, theme.WINDOW_BG_COLOR);

    // Draw the window background contents
    ui.drawRect(0, 0, previouslyDrawnWidth, previouslyDrawnHeight, theme.WINDOW_BG_COLOR);
  }

  /**
   * Ends the window rendering.
   */
  public function end(ui:Kimgui, theme:Theme):Void {
    ui.g.end();

    var bodyDimensions = node.getBodyRect(theme);
    var bodyWidth = bodyDimensions[2];
    var bodyHeight = bodyDimensions[3];

    previouslyDrawnWidth  = Math.max(0, bodyWidth);
    previouslyDrawnHeight = Math.max(0, bodyHeight);
  }

  /**
   * Sets the size of the window.
   */
  private function initTexture(width:Float, height:Float) {
    var width = Math.max(1, width);
    var height = Math.max(1, height);

    if (texture == null || texture.width != width || texture.height != height) {
      texture = kha.Image.createRenderTarget(Std.int(width), Std.int(height), kha.graphics4.TextureFormat.RGBA32, kha.graphics4.DepthStencilFormat.NoDepthAndStencil, 1);
    }
  }
}


class Drawable {
  public function new() {
  }
}