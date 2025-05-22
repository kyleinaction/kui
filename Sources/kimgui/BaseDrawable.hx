package kimgui;

abstract class BaseDrawable implements Drawable {
  public var x: Float;
  public var y: Float;

  public function new(x: Float, y: Float) {
    this.x = x;
    this.y = y;
  }
}