package kimgui;

import kha.graphics2.Graphics;
import kimgui.themes.DarkTheme;

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
  private var m_currentWindow: Window;

  /**
   * The current window being dragged (if any)
   */
  private var m_dragWindow: Handle;

  private var m_options: Options;

  private var m_textPipeline: kha.graphics4.PipelineState; // Rendering text into rendertargets

  /**
   * The current window draw list.
   */
  public function new(options: Options) {
    m_nodes = [];
    m_screenNode = new Node(NodeSplitDirection.NONE);
    m_nodes.push(m_screenNode);
    m_options = options;

    if (m_options.theme == null) {
      m_options.theme = DarkTheme.theme;
    }

    var textVS = kha.graphics4.Graphics2.createTextVertexStructure();
		m_textPipeline = kha.graphics4.Graphics2.createTextPipeline(textVS);
		m_textPipeline.alphaBlendSource = BlendOne;
		m_textPipeline.compile();
  }

  /**
   * Set the size of the window.
   * This will resize all nodes to the given width and height.
   */
  public function setWindowSize(width: Float, height: Float) {
    m_screenNode.resize(width, height);
  }

  /**
   * Begins the drawing context.
   */
  public function begin(g: Graphics) {
    this.g = g;
  }

  /**
   * Renders the final window contents.
   */
  public function end() {
    if (m_currentWindow != null) {
      endWindow();
    }

    g.begin(false);

    // Render window contents
    for (node in m_nodes) {
      for (window in node.windows) {
        window.render(this, m_options.theme);
      }
    }

    g.end();
  }

  public function window(handle:Handle, title:String = "", x:Float = 0.0, y:Float = 0.0, width:Float = 200.0, height:Float = 200.0):Bool {
    if (m_currentWindow != null) {
      endWindow();
    }

    if (handle.window == null) {
      // Create new node
      var node = new Node(NodeSplitDirection.NONE, x, y, width, height);
      m_nodes.push(node);

      // Create new window and add it to the node
      m_currentWindow = new Window();
      node.addWindow(m_currentWindow);
      handle.window = m_currentWindow;
    } else {
      m_currentWindow = handle.window;
    }

    m_currentWindow.title = title;

    return true;
  }

  public function endWindow() {
    m_currentWindow = null;
  }

  public function drawRect(x: Float, y: Float, width: Float, height: Float, color: Int) {
    g.color = color;
    g.fillRect(x, y, width, height);
  }

  public function drawString(text: String, x: Float, y: Float, color: Int, fontSize: Int = 12) {
    g.pipeline = m_textPipeline;
    g.font = m_options.font;
		g.fontSize = fontSize;
    g.color = color;
    g.drawString(text, x, y);
    g.pipeline = null;
  }
}