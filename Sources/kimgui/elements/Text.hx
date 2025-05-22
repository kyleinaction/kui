package kimgui.elements;

class Text extends BaseDrawable {
  public var text: String;
  public var color: Int;
  public var size: Int;

  public function new(x: Float, y: Float, text: String, color: Int, size: Int) {
    super(x, y);
    this.text = text;
    this.color = color;
    this.size = size;
  }

  public function render(ui: Kimgui):Void {
    ui.drawString(text, x, y, color, size);
  }
}