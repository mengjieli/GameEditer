package egret.ui.core.FTEText.history
{
	/**
	 * 文本编辑器备忘录动作
	 * @author featherJ
	 * 
	 */	
	public class Memento
	{
		public var beforeStartIndex:int;
		public var beforeEndIndex:int;
		public var beforeStr:String;
		public var afterStartIndex:int;
		public var afterEndIndex:int;
		public var afterStr:String;
		
		public function toString():String
		{
			return "[s1:"+beforeStartIndex+" ,e1:"+beforeEndIndex+" t1:"+beforeStr+" s2:"+afterStartIndex+" e2:"+afterEndIndex+" t2:"+afterStr+"]"
		}
	}
}