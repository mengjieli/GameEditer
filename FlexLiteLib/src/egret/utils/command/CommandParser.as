package egret.utils.command
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import egret.utils.Argments;
	import egret.utils.command.subcommand.Copy;
	import egret.utils.command.subcommand.Delete;
	import egret.utils.command.subcommand.Run;

	[Event(name="complete", type="flash.events.Event")]
	
	[Event(name="standard_output_data", type="egret.utils.command.CommandEvent")]
	
	[Event(name="standard_error_data", type="egret.utils.command.CommandEvent")]

	/**
	 * 命令行执行工具类，默认支持run , copy 和 del命令
	 * @author xzper
	 */
	public class CommandParser extends EventDispatcher
	{
		/**
		 * 运行程序命令
		 */
		public static const RUN:String = "run";
		
		/**
		 * 复制命令
		 */
		public static const COPY:String = "copy";
		
		/**
		 * 删除命令
		 */
		public static const DELETE:String = "del";
		
		public function CommandParser()
		{
		}
		
		private static var _commandMap:Object;
		
		private static function get commandMap():Object
		{
			if(!_commandMap)
				initialize();
			return _commandMap;
		}
		
		private static function initialize():void
		{
			_commandMap = {};
			_commandMap[RUN] = Run;
			_commandMap[COPY] = Copy;
			_commandMap[DELETE] = Delete;
		}
		
		/**
		 * 注册命令
		 * @param name 命令名称
		 * @param clazz 命令对应的ICommand类定义
		 */
		public static function registerCommand(name:String , clazz:Class):void
		{
			if(!_commandMap)
				initialize();
			_commandMap[name] = clazz;
		}
		
		/**
		 * 执行脚本
		 */
		public static function run(cmd:String):void
		{
			var fs:CommandParser = new CommandParser();
			fs.run(cmd);
		}
		
		private var lines:Array = [];
		
		private var _running:Boolean;
		/**
		 * 是否正在运行
		 */
		public function get running():Boolean
		{
			return _running;
		}
		
		/**
		 * 停止脚本的运行 , 调用此方法不会立即停止当前正在运行的指令。
		 */
		public function stop():void
		{
			if(running)
			{
				_running = false;
				lines.length = 0;
				this.dispatchEvent(new Event(Event.CANCEL));
			}
		}
		
		/**
		 * 运行要执行的命令
		 */
		public function run(cmd:String):void
		{
			if(_running)
				return;
			cmd = cmd.split("\r\n").join("\n");
			cmd = cmd.split("\r").join("\n");
			lines = cmd.split("\n");
			_running = true;
			excute(lines);
		}
		
		private var _currentCommand:ICommand;
		/**
		 * 当前执行的命令
		 */
		public function get currentCommand():ICommand
		{
			return _currentCommand;
		}
		
		/**
		 * 执行
		 */
		private function excute(lines:Array):void
		{
			if(lines.length==0)
			{
				_running = false;
				this.dispatchEvent(new Event(Event.COMPLETE));
				_currentCommand = null;
				return;
			}
			var line:String = lines.shift();
			if(!line)
			{
				excute(lines);
			}
			else
			{
				var args:Array = Argments.parse(line);
				var name:String = args[0];
				if(commandMap[name])
				{
					var clazz:Class = commandMap[name];
					var command:ICommand = new clazz() as ICommand;
					command.initialize(args);
					command.addEventListener(Event.COMPLETE , onComplete);
					command.addEventListener(CommandEvent.OUTPUT,onStandardOutput);
					command.addEventListener(CommandEvent.ERROR,onStandardOutput);
					
					_currentCommand = command;
					command.run();
				}
				else
				{
					excute(lines);
				}
			}
		}
		
		protected function onStandardOutput(event:CommandEvent):void
		{
			this.dispatchEvent(event.clone());
		}
		
		protected function onComplete(event:Event):void
		{
			excute(lines);
		}
	}
}