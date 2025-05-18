package kimgui;

import kha.Color;
import haxe.Exception;

/**
 * The Node class represents a node in the UI tree. It can either contain two leaf nodes, OR it can
 * contain child windows.
 */
@:access(kimgui.Window)
class Node {
  /**
   * The parent of this node, if one exists.
   */
  public var parent: Node;

  /**
   * Leaf nodes.
   */
  public var nodes: Array<Node>;

  /**
   * Child windows.
   */
  public var windows: Array<Window>;
  
  /**
   * The active window. This is the window that is currently being drawn.
   */
  private var m_activeWindow: Window;

  /**
   * The split axis of this node if it is a split node.
   */
  public var splitAxis: NodeSplitAxis;

  /**
   * The x position of this node.
   */
  public var x: Float;

  /**
   * The y position of this node.
   */
  public var y: Float;

  /**
   * The width of this node.
   */
  public var width: Float;

  /**
   * The height of this node.
   */
  public var height: Float;

  /**
   * Whether this node is highlighted or not. This is used for dragging nodes.
   */
  public var highlighted: Bool = false;

  private var m_debugColor: Int;

  /**
   * The constructor for the Node class.
   */
  public function new(splitAxis: NodeSplitAxis, x:Float = 0, y:Float = 0, width:Float = 0, height:Float = 0) {
    this.splitAxis = splitAxis;
    windows   = [];
    nodes     = [];

    this.x         = x;
    this.y         = y;
    this.width     = width;
    this.height    = height;

    this.m_debugColor = Color.fromFloats(Math.random(), Math.random(), Math.random(), 0.25);
  }

  /**
   * Adds a child node to this node.
   */
  public function addChild(node: Node) {
    if (nodes.length >= 2) {
      throw "Cannot add more than 2 child nodes";
    }

    if (node.parent != null) {
      node.parent.nodes.remove(node);
    }

    node.parent = this;
    nodes.push(node);
  }

  /**
   * Returns the absolute x position of the node on the screen.
   */
  public function getScreenX(): Float {
    if (parent == null) {
      return x;
    } else {
      return parent.getScreenX() + x;
    }
  }

  /**
   * Returns the absolute y position of the node on the screen.
   */
  public function getScreenY(): Float {
    if (parent == null) {
      return y;
    } else {
      return parent.getScreenY() + y;
    }
  }

  /**
   * Resizes the node to the given width and height. This will also resize all child nodes.
   */
  public function resize(width: Float, height: Float) {
    if (this.width != width || this.height != height) {
      this.width = width;
      this.height = height;

      resizeNodes();
    }
  }

  /**
   * Adds a child window to this node.
   */
  public function addWindow(window: Window) {
    window.node = this;
    windows.push(window);

    if (m_activeWindow == null) {
      m_activeWindow = window;
    }
  }

  /**
   * Resizes the child nodes.
   */
  public function resizeNodes() {
    // Don't resize if there are no nodes
    if (nodes.length == 0) {
      return;
    }

    if (splitAxis == NodeSplitAxis.NONE) {
      return;
    } else if (splitAxis == NodeSplitAxis.HORIZONTAL) {
      final firstNodeWidth = nodes[0].width;
      final secondNodeWidth = width - firstNodeWidth;
      
      nodes[0].resize(firstNodeWidth, height);
      nodes[1].resize(secondNodeWidth, height);

    } else if (splitAxis == NodeSplitAxis.VERTICAL) {
      final firstNodeHeight = nodes[0].height;
      final secondNodeHeight = height - firstNodeHeight;
      nodes[0].resize(width, firstNodeHeight);
      nodes[1].resize(width, secondNodeHeight);
    }
  }

  public function resizeToNodes() {
    // Don't resize if there are no nodes
    if (nodes.length == 0) {
      return;
    }

    if (splitAxis == NodeSplitAxis.NONE) {
      return;
    } else if (splitAxis == NodeSplitAxis.HORIZONTAL) {
      final width = nodes[0].width + nodes[1].width;
      final height = Math.max(nodes[0].height, nodes[1].height);
      resize(width, height);

    } else if (splitAxis == NodeSplitAxis.VERTICAL) {
      final width = Math.max(nodes[0].width, nodes[1].width);
      final height = nodes[0].height + nodes[1].height;
      resize(width, height);
    }
  }

  public function resizeAncestors() {
    if (parent != null) {
      parent.resizeToNodes();
      parent.resizeAncestors();
      parent.resizeNodes();
    }
  }

  /**
   * Renders the node and its children.
   */
  public function render(ui:Kimgui, theme:Theme) {
    var sx = getScreenX();
    var sy = getScreenY();

    // ui.drawRect(sx - 10, sy - 10, width + 20, height + 20, m_debugColor);

    // This is a parent node, so delegate rendering to children
    if (nodes.length > 0) {
      for (node in nodes) {
        node.render(ui, theme);
      }
      return;
    }
    
    // Bailout of rendering if there are no windows
    if (windows.length == 0) {
      return;
    }

    var bodyX = sx + theme.WINDOW_BORDER_SIZE;
    var bodyY = sy + theme.WINDOW_BORDER_SIZE + theme.WINDOW_TITLEBAR_HEIGHT;
    var bodyWidth = width - (theme.WINDOW_BORDER_SIZE * 2);
    var bodyHeight = height - (theme.WINDOW_BORDER_SIZE * 2) - theme.WINDOW_TITLEBAR_HEIGHT;

    var titleX = sx + theme.WINDOW_BORDER_SIZE;
    var titleY = sy + theme.WINDOW_BORDER_SIZE;
    var titleWidth = width - (theme.WINDOW_BORDER_SIZE * 2);
    var titleHeight = theme.WINDOW_TITLEBAR_HEIGHT;

    // Draw border first
    ui.drawRect(sx, sy, width, height, theme.WINDOW_BORDER_COLOR);

    // Draw title bar
    ui.drawRect(titleX, titleY, titleWidth, titleHeight, theme.WINDOW_BORDER_COLOR);

    // Render the child windows
    var titleBarX = titleX;
    for (window in windows) {
      // Draw window tab
      var tabBackgrondColor = (m_activeWindow == window) ? theme.WINDOW_TITLEBAR_ACTIVE_COLOR : theme.WINDOW_TITLEBAR_COLOR;
      var tabWidth = ui.options.font.width(theme.WINDOW_TITLE_BAR_FONT_SIZE, window.title) + (theme.WINDOW_TITLE_BAR_PADDING * 2);
      ui.drawRect(titleBarX, titleY, tabWidth, titleHeight, tabBackgrondColor);

      // Draw window title
      ui.drawString(
        window.title,
        titleBarX + theme.WINDOW_TITLE_BAR_PADDING,
        titleY + theme.WINDOW_TITLE_BAR_PADDING,
        theme.WINDOW_TITLEBAR_TEXT_COLOR,
        theme.WINDOW_TITLE_BAR_FONT_SIZE
      );

      // Set the active window if the user clicks on the window tab
      if (ui.getInputInRect(titleBarX, titleY, tabWidth, titleHeight) && ui.inputStarted) {
        m_activeWindow = window;
      }

      // Draw the active window
      if (m_activeWindow == window) {
        window.render(ui, theme, bodyX, bodyY, bodyWidth, bodyHeight);
      }

      if (highlighted) {
        ui.drawRect(sx, sy, width, height, theme.NODE_HIGHLIGHT_COLOR);
      }

      titleBarX = titleBarX + tabWidth + 1;
    }
  }
}