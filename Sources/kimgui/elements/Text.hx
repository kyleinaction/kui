package kimgui.elements;

/**
 * Text UI element.
 */
class Text extends BaseDrawable {
  public var text: String;
  public var color: Int;
  public var size: Int;

  /**
   * Constructor.
   */
  public function new(x: Float, y: Float, text: String, color: Int, size: Int) {
    super(x, y);
    this.text = text;
    this.color = color;
    this.size = size;
  }

  /**
   * Render the text element.
   */
  public function render(ui: Kimgui):Void {
    ui.drawString(text, x, y, color, size);
  }
}