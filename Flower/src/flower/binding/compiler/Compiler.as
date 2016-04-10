package flower.binding.compiler
{
	import flower.binding.compiler.structs.Stmts;

	public class Compiler
	{
		private var _scanner:Scanner;
		private var _parser:Parser;
		
		public function Compiler()
		{
			_scanner = new Scanner();
			_parser = new Parser();
		}
		
		public function parserExpr(content:String,checks:Array,objects:Object,classes:Object,result:Array):Stmts {
			var scanner:Scanner = new Scanner();
			var common:Object = {"content":content,"objects":objects,"classes":classes,"checks":checks,"ids":{},"tokenValue":null,"scanner":_scanner,"nodeStack":null,bindList:new Vector.<String>()};
			_scanner.setCommonInfo(common);
			_parser.setCommonInfo(common);
			_parser.parser(content);
			common.result = result;
			common.expr = common.newNode.expval;
			common.expr.checkPropertyBinding(common);
			return common.expr;
		}
		
		private static var ist:Compiler;
		
		public static function parserExpr(content:String,checks:Array,objects:Object,classes:Object,result:Array):Stmts {
			if(!ist) {
				ist = new Compiler();
			}
			return ist.parserExpr(content,checks,objects,classes,result);
		}
	}
}