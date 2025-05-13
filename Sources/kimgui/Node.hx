package kimgui;

/**
 * The Node class represents a node in the UI tree. It can either contain two leaf nodes, OR it can
 * contain child windows.
 */
@:access(kimgui.Window)
class Node {
  /**
   * The parent of this node, if one exists.
   */
  private var m_parent: Node;

  /**
   * Leaf nodes.
   */
  private var m_nodes: Array<Node>;

  /**
   * Child windows.
   */
  private var m_windows: Array<Window>;
  public var windows(get, null):Array<Window>;
  
  /**
   * The active window. This is the window that is currently being drawn.
   */
  private var m_activeWindow: Window;

  /**
   * The split direction of this node if it is a split node.
   */
  private var m_splitDirection: NodeSplitDirection;

  /**
   * The x position of this node.
   */
  private var m_x: Float;

  /**
   * The y position of this node.
   */
  private var m_y: Float;

  /**
   * The width of this node.
   */
  private var m_width: Float;

  /**
   * The height of this node.
   */
  private var m_height: Float;

  /**
   * The constructor for the Node class.
   */
  public function new(splitDirection: NodeSplitDirection, x:Float = 0, y:Float = 0, width:Float = 0, height:Float = 0) {
    m_splitDirection = splitDirection;
    m_windows   = [];
    m_nodes     = [];

    m_x         = x;
    m_y         = y;
    m_width     = width;
    m_height    = height;
  }

  /**
   * Resizes the node to the given width and height. This will also resize all child nodes.
   */
  public function resize(width: Float, height: Float) {
    if (m_width != width || m_height != height) {
      m_width = width;
      m_height = height;

      resizeNodes();
    }
  }

  /**
   * Returns the child windows.
   */
  public function get_windows(): Array<Window> {
    return m_windows;
  }

  /**
   * Adds a child window to this node.
   */
  public function addWindow(window: Window) {
    window.m_parent = this;
    m_windows.push(window);
    m_activeWindow = window;
  }

  /**
   * Resizes the child nodes.
   */
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