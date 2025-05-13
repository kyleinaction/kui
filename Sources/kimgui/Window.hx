package kimgui;

import kha.graphics2.Graphics;

/**
 * WindowDrawList is a class that represents a draw list for a window.
 * Whenever a new window is created, 
 */
@:access(kimgui.Node)
class Window {
  private var m_drawList: Array<Drawable>;
  private var m_parent: Node;

  private var m_debugColor: Int;

  public function new() {
    m_debugColor = kha.Color.Blue;
    // Constructor code here
  }

  public function render(g: Graphics) {
    // Window dimensions are based on node dimensions
    var x = m_parent.m_x;
    var y = m_parent.m_y;
    var width = m_parent.m_width;
    var height = m_parent.m_height;

    g.begin(false);
      g.color = kha.Color.Blue;
      g.fillRect(x, y, width, height);
    g.end();
  }
}


class Drawable {
  public function new() {
  }
}