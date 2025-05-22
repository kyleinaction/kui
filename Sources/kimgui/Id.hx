package kimgui;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.ExprTools;

/**
 * Handle generation for UI elements.
 * 
 * From the ZUI library.
 * https://github.com/armory3d/zui
 */
class Id {

  static var i = 0;

  macro public static function pos(): Expr {
    return macro $v{i++};
  }

  macro public static function handle(ops: Expr = null): Expr {
    var code = "kimgui.Handle.global.nest(kimgui.Id.pos()," + ExprTools.toString(ops) + ")";
      return Context.parse(code, Context.currentPos());
  }
}