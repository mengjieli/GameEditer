package flower.binding.compiler
{
	import flower.binding.compiler.structs.Expr;
	import flower.binding.compiler.structs.Stmts;
	import flower.data.member.Value;

	public class Compiler
	{
		private var _scanner:Scanner;
		private var _parser:Parser;
		
		public function Compiler()
		{
			_scanner = new Scanner();
			_parser = new Parser();
		}
		
		public function parser(content:String,property:String,checks:Array,result:Array):Stmts {
			var scanner:Scanner = new Scanner();
			var common:Object = {"content":content,"ids":{},"tokenValue":null,"scanner":_scanner,"nodeStack":null,bindList:new Vector.<String>()};
			_scanner.setCommonInfo(common);
			_parser.setCommonInfo(common);
			_parser.parser(content);
			common.result = result;
			common.stmts = common.newNode.expval;
			common.stmts.checkPropertyBinding(checks,common);
			return common.stmts;
		}
		
		public function parserExpr(content:String,property:String,checks:Array,result:Array,thisObj:*):Expr {
			var scanner:Scanner = new Scanner();
			var common:Object = {"content":content,"objects":{"this":thisObj},"ids":{},"tokenValue":null,"scanner":_scanner,"nodeStack":null,bindList:new Vector.<String>()};
			_scanner.setCommonInfo(common);
			_parser.setCommonInfo(common);
			_parser.parser(content);
			common.result = result;
			common.expr = common.newNode.expval;
			common.expr.checkPropertyBinding(checks,common);
			return common.expr;
		}
		
		private static var ist:Compiler;
		
		public static function parserExpr(content:String,property:String,checks:Array,result:Array,thisObj:*):Expr {
			if(!ist) {
				ist = new Compiler();
			}
			return ist.parserExpr(content,property,checks,result,thisObj);
		}
	}
}