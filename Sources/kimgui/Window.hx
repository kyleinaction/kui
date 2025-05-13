package kimgui;

import kha.graphics2.Graphics;

/**
 * Window is a class that represents a window in the Kimgui UI system.
 */
@:access(kimgui.Node)
class Window {
  /**
   * Parent node of this window.
   */
  private var m_parent: Node;

  /**
   * Window title.
   */
  public var title: String;

  /**
   * Constructor.
   */
  public function new() {
    title = "";
  }

  /**
   * Renders the window & it's contents.
   */
  public function render(ui:Kimgui, theme: Theme) {
    // Window dimensions are based on node dimensions
    var x = m_parent.m_x;
    var y = m_parent.m_y;
    var width = m_parent.m_width;
    var height = m_parent.m_height;

    var bodyX = x + theme.WINDOW_BORDER_SIZE;
    var bodyY = y + theme.WINDOW_BORDER_SIZE + theme.WINDOW_TITLEBAR_HEIGHT;
    var bodyWidth = width - (theme.WINDOW_BORDER_SIZE * 2);
    var bodyHeight = height - (theme.WINDOW_BORDER_SIZE * 2) - theme.WINDOW_TITLEBAR_HEIGHT;

    var titleX = x + theme.WINDOW_BORDER_SIZE;
    var titleY = y + theme.WINDOW_BORDER_SIZE;
    var titleWidth = width - (theme.WINDOW_BORDER_SIZE * 2);
    var titleHeight = theme.WINDOW_TITLEBAR_HEIGHT;

    // Draw border first
    ui.drawRect(x, y, width, height, theme.WINDOW_BORDER_COLOR);

    // Next draw body background
    ui.drawRect(bodyX, bodyY, bodyWidth, bodyHeight, theme.WINDOW_BG_COLOR);

    // Draw title bar
    ui.drawRect(titleX, titleY, titleWidth, titleHeight, theme.WINDOW_TITLEBAR_COLOR);

    // Draw title text
    ui.drawString(
      title, 
      titleX + theme.WINDOW_TITLE_BAR_PADDING, 
      titleY + theme.WINDOW_TITLE_BAR_PADDING, 
      theme.WINDOW_TITLEBAR_TEXT_COLOR, 
      theme.WINDOW_TITLE_BAR_FONT_SIZE
    );
  }
}


class Drawable {
  public function new() {
  }
}