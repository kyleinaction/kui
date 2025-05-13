package kimgui;

import kha.graphics2.Graphics;


/**
 * Main interface for Kimgui.
 */
class Kimgui {
  /**
   * The current graphics context.
   */
  public var g:Graphics;

  /**
   * All UI nodes.
   */
  private var m_nodes: Array<Node>;

  /**
   * Full-screen node. This node gets resized based on the framebuffer size.
   */
  private var m_screenNode: Node;

  /**
   * The current window being drawn.
   */
  private var m_currentWindow: kimgui.Window;

  /**
   * The current window draw list.
   */
  public function new() {
    m_nodes = [];
    m_screenNode = new Node(NodeSplitDirection.NONE);
    m_nodes.push(m_screenNode);
  }

  public function setWindowSize(width: Float, height: Float) {
    for (node in m_nodes) {
      node.resize(width, height);
    }
  }

  public function begin(g: Graphics) {
    this.g = g;
  }

  public function end() {
    if (m_currentWindow != null) {
      endWindow();
    }

    // Render window contents
    for (node in m_nodes) {
      for (window in node.windows) {
        window.render(this.g);
      }
    }
  }

  public function window(handle:Handle) {
    if (m_currentWindow != null) {
      endWindow();
    }

    if (handle.window == null) {
      // Create new node
      var node = new Node(NodeSplitDirection.NONE);
      m_nodes.push(node);

      // Create new window and add it to the node
      m_currentWindow = new Window();
      node.addWindow(m_currentWindow);
      handle.window = m_currentWindow;
    } else {
      m_currentWindow = handle.window;
    }
  }

  public function endWindow() {
    m_currentWindow = null;
  }
}