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
   * The vetical scroll position of the window.
   */
  public var scrollY: Float;

  /**
   * The width of the window (cached from the last frame, might be stale). For the most accurate width, use `node.getBodyRect(theme)`.
   */
  public var width: Float;

  /**
   * The height of the window (cached from the last frame, might be stale). For the most accurate height, use `node.getBodyRect(theme)`.
   */
  public var height: Float;

  /**
   * Constructor.
   */
  public function new() {
    title = "";
    width = 0;
    height = 0;
    previouslyDrawnHeight = 0;
    previouslyDrawnWidth  = 0;
    scrollY = 0;
  }

  /**
   * Will return TRUE if this window is the active window of it's parent node.
   */
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
    width = bodyDimensions[2];
    height = bodyDimensions[3];

    previouslyDrawnWidth  = Math.max(0, width);
    previouslyDrawnHeight = Math.max(ui.cursorY, height);

    var visibleBottom = height + scrollY;
    if (visibleBottom > previouslyDrawnHeight) {
      scrollY -= visibleBottom - previouslyDrawnHeight;
    }
  }

  /**
   * Scrolls the window by a given delta.
   */
  public function scroll(delta:Float, theme:Theme):Void {
    var bodyDimensions = node.getBodyRect(theme);
    scrollY += delta * theme.SCROLL_SPEED;
    scrollY = Math.max(0, scrollY);
    scrollY = Math.min(scrollY, previouslyDrawnHeight - bodyDimensions[3]);
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