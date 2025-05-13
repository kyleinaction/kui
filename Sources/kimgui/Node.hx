package kimgui;

@:access(kimgui.Window)
class Node {
  private var m_parent: Node;

  private var m_windows: Array<Window>;
  public var windows(get, null):Array<Window>;

  private var m_splitDirection: NodeSplitDirection;
  private var m_nodes: Array<Node>;

  private var m_x: Float;
  private var m_y: Float;
  private var m_width: Float;
  private var m_height: Float;
  
  public function new(splitDirection: NodeSplitDirection) {
    m_splitDirection = splitDirection;
    m_windows   = [];
    m_nodes     = [];
    m_x         = 0;
    m_y         = 0;
    m_width     = 0;
    m_height    = 0;
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

  // public function splitWith(node: Node, location:NodeLocation): Void {
  //   var splitDirection = NodeSplitDirection.NONE;
  //   if (location == NodeLocation.LEFT || location == NodeLocation.RIGHT) {
  //     splitDirection = NodeSplitDirection.VERTICAL;
  //   } else if (location == NodeLocation.TOP || location == NodeLocation.BOTTOM) {
  //     splitDirection = NodeSplitDirection.HORIZONTAL;
  //   }
    
  //   var newNode = new Node(m_splitDirection);
  //   newNode.m_parent = this;
  //   node.m_parent = this;
  // }

  public function addWindow(window: Window) {
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