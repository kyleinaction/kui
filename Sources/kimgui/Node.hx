package kimgui;

@:access(kimgui.Window)
class Node {
  private var m_parent: Node;

  private var m_windows: Array<Window>;
  public var windows(get, null):Array<Window>;
  
  private var m_activeWindow: Window;

  private var m_splitDirection: NodeSplitDirection;
  private var m_nodes: Array<Node>;

  // Size
  private var m_x: Float;
  private var m_y: Float;
  private var m_width: Float;
  private var m_height: Float;

  public function new(splitDirection: NodeSplitDirection, x:Float = 0, y:Float = 0, width:Float = 0, height:Float = 0) {
    m_splitDirection = splitDirection;
    m_windows   = [];
    m_nodes     = [];

    m_x         = x;
    m_y         = y;
    m_width     = width;
    m_height    = height;
  }

  public function resize(width: Float, height: Float) {
    if (m_width != width || m_height != height) {
      m_width = width;
      m_height = height;

      resizeNodes();
    }
  }

  public function get_windows(): Array<Window> {
    return m_windows;
  }

  public function addWindow(window: Window) {
    if (m_activeWindow == null) {
      m_activeWindow = window;
    }

    window.m_parent = this;
    m_windows.push(window);
  }

  private function resizeNodes() {
    // Don't resize if there are no nodes
    if (m_nodes.length == 0) {
      return;
    }

    if (m_splitDirection == NodeSplitDirection.NONE) {
      return;
    } else if (m_splitDirection == NodeSplitDirection.HORIZONTAL) {
      final firstNodeWidth = m_nodes[0].m_width;
      final secondNodeWidth = m_width - firstNodeWidth;
      m_nodes[1].resize(secondNodeWidth, m_height);
    } else if (m_splitDirection == NodeSplitDirection.VERTICAL) {
      final firstNodeHeight = m_nodes[0].m_height;
      final secondNodeHeight = m_height - firstNodeHeight;
      m_nodes[1].resize(m_width, secondNodeHeight);
    }
  }
}