package flower.binding.compiler.structs
{
	import flower.data.member.Value;

	/**
	 * 表达式属性，例如 abc.x   x   y   func(...) 等等
	 *
	 */
	public class ExprAtr
	{
		public var type:String = "attribute";
		public var list:Vector.<ExprAtrItem>;
		private var value:Value;
		private var before:*;
		private var beforeClass:Boolean;
		private var equalBefore:Boolean;
		
		public function ExprAtr()
		{
			list = new Vector.<ExprAtrItem>();
			equalBefore = false;
		}
		
		public function addItem(item:ExprAtrItem):void {
			this.list.push(item);
		}
		
		/**
		 * 需要检查的属性在哪里,比如在 this 中，或者在 DataManager 中
		 */
		public function checkPropertyBinding(commonInfo:Object):void {
			var atr:*;
			if(list[0].type == "()") {
				(list[0].val as Expr).checkPropertyBinding(commonInfo);
			} else if(list[0].type == "object") {
				(list[0].val as ObjectAtr).checkPropertyBinding(commonInfo);
			}
			else if(list[0].type == "id") {
				var name:String = list[0].val;
				if(commonInfo.objects[name]) {
					before = commonInfo.objects[name];
					beforeClass = false;
					equalBefore = true;
				} else if(commonInfo.classes[name]) {
					before = commonInfo.classes[name];
					beforeClass = true;
					equalBefore = true;
				} else if(commonInfo.checks) {
					for(var c:int = 0; c < commonInfo.checks.length; c++) {
						try{
							atr = commonInfo.checks[c][name];
							if(atr) {
								before = commonInfo.checks[c];
							}
						} catch(e){
							atr = null;
							before = null;
						}
						if(atr) {
							break;
						}
					}
				}
			}
			for(var i:int = 1; i < this.list.length; i++) {
				if(list[i].type == ".") {
					if(atr) {
						var atrName:String = this.list[i].val;
						try {
							atr = atr[atrName];
						} catch(e) {
							atr = null;
						}
					}
				} else if(list[i].type == "call") {
					atr = null;
					list[i].val.checkPropertyBinding(commonInfo);
				}
			}
			if(atr && atr is Value) {
				value = atr;
				commonInfo.result.push(atr);
			}
		}
		
		public function getValue():* {
			if(value) {
				return value.value;
			}
			var atr:*;
			var lastAtr:* = null;
			if(list[0].type == "()") {
				atr = (list[0].val as Expr).getValue();
			} else if(list[0].type == "object") {
				atr = (list[0].val as ObjectAtr).getValue();
			} else if(list[0].type == "id") {
				atr = this.before;
				lastAtr = this.before;
				if(!equalBefore) {
					try {
						atr = atr[list[0].val];
					} catch(e) {
						return null;
					}
				}
			}
			for(var i:int = 1; i < list.length; i++) {
				try {
					if(list[i].type == ".") {
						atr = atr[this.list[i].val];
					} else if(list[i].type == "call") {
						if(i == 2 && beforeClass) {
							atr = atr.apply(null,(list[i].val as CallParams).getValueList());
						} else {
							atr = atr.apply(lastAtr,(list[i].val as CallParams).getValueList());
						}
					}
					if(i < this.list.length - 1 && this.list[i+1].type == "call") {
						continue;
					}
					lastAtr = atr;
				} catch(e) {
					return null;
				}
			}
			return atr;
		}
		
		public function print():String {
			var content:String = "";
			for(var i:int = 0; i < list.length; i++) {
				content += list[i].print();
			}
			return content;
		}
	}
}