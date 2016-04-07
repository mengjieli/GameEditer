package main.data.parsers.command
{
	public class Command
	{
		public var exes:Vector.<Execute> = new Vector.<Execute>();
		
		public function Command(args:Array)
		{
			for(var i:int = 0; i < args.length; i++) {
				exes.push(args[i]);
			}
		}
		
		public function excute():void {
			for(var i:int = 0; i < exes.length; i++) {
				exes[i].excute();
			}
		}
		
		public function addCommand(cmd:Command):void {
			for(var i:int = 0; i < cmd.exes.length; i++) {
				exes.push(cmd.exes[i]);
			}
		}
	}
}