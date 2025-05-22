package kimgui;

/**
 * BaseDrawable is an abstract class that implements the Drawable interface.
 * It provides a base implementation for drawable objects.
 */
abstract class BaseDrawable implements Drawable {
  public var x: Float;
  public var y: Float;

  public function new(x: Float, y: Float) {
    this.x = x;
    this.y = y;
  }
}