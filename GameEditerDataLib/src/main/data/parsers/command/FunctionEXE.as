package main.data.parsers.command
{
	public class FunctionEXE extends Execute
	{
		private var thisObj:*;
		private var func:Function;
		private var args:Array;
		
		public function FunctionEXE(thisObj:*,func:Function,args:Array)
		{
			this.thisObj = thisObj;
			this.func = func;
			this.args = args;
		}
		
		override public function excute():void {
			func.apply(thisObj,args);
		}
	}
}