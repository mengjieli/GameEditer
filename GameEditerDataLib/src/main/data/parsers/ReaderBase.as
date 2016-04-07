package main.data.parsers
{

	import flash.events.KeyboardEvent;
	
	import egret.ui.components.TabPanel;
	
	import main.data.directionData.DirectionDataBase;
	import main.data.parsers.command.Command;

	public class ReaderBase extends TabPanel
	{
		protected var _changeFlag:Boolean = false;
		protected var dir:DirectionDataBase;
		protected var commands:Vector.<Command> = new Vector.<Command>();
		protected var inExeCommand:Boolean = false;
		
		public function ReaderBase()
		{
			_data.panel = this;
			this.addEventListener(KeyboardEvent.KEY_DOWN,onKeyDown);
		}
		
		protected function onKeyDown(event:KeyboardEvent):void {
			if(event.keyCode == 90) {
				if(event.ctrlKey && !event.shiftKey && !event.altKey) {
					this.backCommand();
				}
			}
		}
		
		public function pushCommand(...args):void {
			if(inExeCommand) {
				return;
			}
			commands.push(new Command(args));
		}
		
		public function memgerCommandTo(len:int):void {
			if(commands.length > len && len > 0) {
				for(var i:int = len; i < commands.length; i++) {
					var cmd:Command = commands[i];
					commands[len-1].addCommand(cmd);
				}
				commands.length = len;
			}
		}
		
		public function get commandLength():int {
			return commands.length;
		}
		
		public function backCommand():void {
			if(!commands.length) {
				return;
			}
			inExeCommand = true;
			var cmd:Command = commands.pop();
			cmd.excute();
			inExeCommand = false;
		}
		
		public function get readerName():String {
			return "";
		}
		
		public function showData(d:DirectionDataBase):void {
			this.dir = d;
		}
		
		public function get directionData():DirectionDataBase {
			return this.dir;
		}
		
		public function get changeFlag():Boolean {
			return this._changeFlag;
		}
	}
}