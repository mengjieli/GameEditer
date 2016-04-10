package flower.binding
{
	import flower.binding.compiler.Compiler;
	import flower.binding.compiler.structs.Expr;
	import flower.binding.compiler.structs.Stmts;
	import flower.tween.Ease;
	import flower.tween.Tween;

	public class Binding
	{
		private var singleValue:Boolean = false;
		private var list:Array = [];
		private var stmts:Array = [];
		private var thisObj:*;
		private var property:String;
		
		public function Binding(thisObj:*,checks:Array,property:String,content:String)
		{
			//分两种情况考虑，一种是 "{...}" 或者其它 就是字符串相加 "" + ... +  {..} + ... + {...}
			var lastEnd:int = 0;
			for(var i:int = 0; i < content.length; i++) {
				if(content.charAt(i) == "{") {
					for(var j:int = i + 1; j < content.length; j++) {
						if(content.charAt(j) == "{") {
							break;
						}
						if(content.charAt(j) == "}") {
							if(i == 0 && j == content.length-1) {
								singleValue = true;
							}
							if(lastEnd < i) {
								stmts.push(content.slice(lastEnd,i));
								lastEnd = j + 1;
							}
							var stmt:Stmts = Compiler.parserExpr(content.slice(i+1,j),checks,{"this":thisObj},{"Tween":Tween,"Ease":Ease},list);
							stmts.push(stmt);
							i = j;
							break;
						}
					}
				}
			}
			if(lastEnd < content.length) {
				stmts.push(content.slice(lastEnd,content.length));
			}
			this.thisObj = thisObj;
			this.property = property;
			for(i = 0; i < list.length; i++) {
				for(j = 0; j <  list.length; j++) {
					if(i != j && list[i] == list[j]) {
						list.splice(j,1);
						i = -1;
						break;
					}
				}
			}
			for(i = 0; i < list.length; i++) {
				list[i].addListener(this.update,this);
			}
			this.update();
		}
		
		private function update(value:*=null,old:*=null):void {
			if(this.singleValue) {
				try {
					thisObj[property] = stmts[0].getValue();
				} catch(e) {
					thisObj[property] = null;
				}
			} else {
				var str:String = "";
				for(var i:int = 0; i < stmts.length; i++) {
					var expr:* = stmts[i];
					if(expr is Expr) {
						try {
							str += expr.getValue();
						} catch(e) {
							str += "null";
						}
					} else {
						str += expr;
					}
				}
				thisObj[property] = str;
			}
		}
		
		public function dispose():void {
			for(var i:int = 0; i < list.length; i++) {
				list[i].removeListener(this.update,this);
			}
		}
	}
}