package kimgui;

/**
 * Theme definition for Kimgui.
 */
typedef Theme = {
  var TEXT_COLOR: Int;
  var TEXT_SIZE: Int;
  
  var WINDOW_BG_COLOR: Int;
  var WINDOW_BORDER_COLOR: Int;
  var WINDOW_BORDER_SIZE: Float;
  
  var NODE_HIGHLIGHT_COLOR: Int;
  var NODE_HIGHLIGHT_COLOR_ACTIVE: Int;
  
  var WINDOW_BODY_PADDING: Float;
  
  var WINDOW_TITLEBAR_TEXT_COLOR: Int;
  var WINDOW_TITLEBAR_COLOR: Int;
  var WINDOW_TITLEBAR_ACTIVE_COLOR: Int;
  var WINDOW_TITLEBAR_HEIGHT: Float;
  
  var WINDOW_TITLE_BAR_FONT_SIZE: Int;
  var WINDOW_TITLE_BAR_PADDING: Float;
  
  var WINDOW_RESIZE_HANDLE_COLOR: Int;
  var WINDOW_RESIZE_HANDLE_THICKNESS: Float;
  
  var ELEMENT_SPACING: Float;

  var BUTTON_COLOR: Int;
  var BUTTON_HOVER_COLOR: Int;
  var BUTTON_ACTIVE_COLOR: Int;

  var BUTTON_HEIGHT: Float;
  var BUTTON_TEXT_COLOR: Int;
  var BUTTON_TEXT_SIZE: Int;

  var CHECKBOX_SIZE: Float;
  var CHECKBOX_COLOR: Int;
  var CHECKBOX_CHECK_COLOR: Int;
  var CHECKBOX_PADDING: Float;

  var SCROLLBAR_COLOR: Int;
  var SCROLLBAR_THICKNESS: Float;
  var SCROLL_SPEED: Float;
}