package kimgui;

/**
 * Handle is a class that represents the state of a UI element.
 * 
 * Parts of this code are from the ZUI library.
 * https://github.com/armory3d/zui
 */
class Handle {
	public var selected = false;
  public var window: Window;

  private var isDragging: Bool;
  private var dragX: Float;
  private var dragY: Float;
  private var dragOffsetX: Float;
  private var dragOffsetY: Float;

	private var m_children: Map<Int, Handle>;

	public function new(ops: HandleOptions = null) {
		if (ops != null) {
			if (ops.selected != null) selected = ops.selected;
		}
	}

	public function nest(i: Int, ops: HandleOptions = null): Handle {
		if (m_children == null) m_children = [];
		var c = m_children.get(i);
		if (c == null) {
			c = new Handle(ops);
			m_children.set(i, c);
		}
		return c;
	}

	public function unnest(i: Int) {
		if (m_children != null) {
			m_children.remove(i);
		}
	}

	public static var global = new Handle();
}