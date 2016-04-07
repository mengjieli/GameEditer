package flower.binding
{
	import flower.binding.compiler.Compiler;
	import flower.binding.compiler.structs.Expr;

	public class Binding
	{
		private var singleValue:Boolean = false;
		private var list:Array = [];
		private var exprs:Array = [];
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
								exprs.push(content.slice(lastEnd,i));
								lastEnd = j + 1;
							}
							var expr:Expr = Compiler.parserExpr(content.slice(i+1,j),property,checks,list,thisObj);
							exprs.push(expr);
							i = j;
							break;
						}
					}
				}
			}
			if(lastEnd < content.length) {
				exprs.push(content.slice(lastEnd,content.length));
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
					thisObj[property] = exprs[0].getValue();
				} catch(e) {
					thisObj[property] = null;
				}
			} else {
				var str:String = "";
				for(var i:int = 0; i < exprs.length; i++) {
					var expr:* = exprs[i];
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