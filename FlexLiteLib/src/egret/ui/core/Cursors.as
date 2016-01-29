package egret.ui.core
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.ui.Mouse;
	import flash.ui.MouseCursorData;
	
	/**
	 * 鼠标样式设置工具类
	 * @author dom
	 */
	public class Cursors
	{
		/**
		 * 鼠标样式管理
		 */		
		public function Cursors()
		{
		}

		/**
		 * 还原鼠标样式为自动
		 */		
		public static const AUTO:String = "auto";
		/**
		 * 鼠标样式，调整大小，南-北方向
		 */		
		public static const DESKTOP_RESIZE_NS:String = "appResizeNS";
		/**
		 * 鼠标样式，调整大小，东-西方向
		 */
		public static const DESKTOP_RESIZE_EW:String = "appResizeEW";
		/**
		 * 鼠标样式，调整大小，东北-西南方向
		 */
		public static const DESKTOP_RESIZE_NESW:String = "appResizeNESW";
		/**
		 * 鼠标样式，调整大小，西北-东南方向
		 */
		public static const DESKTOP_RESIZE_NWSE:String = "appResizeNWSE";
		/**
		 * 鼠标样式，拾色器圆圈
		 */		
		public static const DESKTOP_CIRCLE:String = "appCircle";
		/**
		 * 鼠标样式，失效 
		 */		
		public static const DESKTOP_DISABLE:String = "disable";
		/**
		 * 鼠标样式，可拖拽
		 */		
		public static const DESKTOP_DRAG:String = "drag";
		
		[Embed(source="/egret/ui/core/cursors/ew.png")]
		private static var CURSOR_EW:Class;   
		[Embed(source="/egret/ui/core/cursors/ns.png")]
		private static var CURSOR_NS:Class;   
		[Embed(source="/egret/ui/core/cursors/nesw.png")]
		private static var CURSOR_NESW:Class;   
		[Embed(source="/egret/ui/core/cursors/nwse.png")]
		private static var CURSOR_NWSE:Class;  
		[Embed(source="/egret/ui/core/cursors/circle.png")]
		private static var CURSOR_CIRCLE:Class;  
		[Embed(source="/egret/ui/core/cursors/disable.png")]
		private static var CURSOR_DISABLE:Class;  
		[Embed(source="/egret/ui/core/cursors/drag.png")]
		private static var CURSOR_DRAG:Class;  
		/**
		 * 鼠标样式初始化完成标志
		 */		
		private static var cursorInitialized:Boolean = false;
		/**
		 * 初始化鼠标样式
		 */		
		public static function initCursors():void
		{
			if(cursorInitialized)
				return;
			var cursorList:Array = [CURSOR_NS,CURSOR_EW,CURSOR_NESW,CURSOR_NWSE,CURSOR_CIRCLE,CURSOR_DISABLE,CURSOR_DRAG];
			var cursorDatas:Array = [];
			for each(var  CURSOR:Class in cursorList)
			{
				var bitmap:Bitmap = new CURSOR();
				var cData:MouseCursorData = new MouseCursorData();
				cData.data = new <BitmapData>[bitmap.bitmapData];
				cursorDatas.push(cData);
			}
			cursorDatas[0].hotSpot = new Point(4.5,11.5);
			cursorDatas[1].hotSpot = new Point(11.5,4.5);
			cursorDatas[2].hotSpot = new Point(8.5,8.5);
			cursorDatas[3].hotSpot = new Point(8.5,8.5);
			cursorDatas[4].hotSpot = new Point(9,9);
			cursorDatas[5].hotSpot = new Point(10,10);
			cursorDatas[5].hotSpot = new Point(0,0);
			Mouse.registerCursor(DESKTOP_RESIZE_NS,cursorDatas[0]);
			Mouse.registerCursor(DESKTOP_RESIZE_EW,cursorDatas[1]);
			Mouse.registerCursor(DESKTOP_RESIZE_NESW,cursorDatas[2]);
			Mouse.registerCursor(DESKTOP_RESIZE_NWSE,cursorDatas[3]);
			Mouse.registerCursor(DESKTOP_CIRCLE,cursorDatas[4]);
			Mouse.registerCursor(DESKTOP_DISABLE,cursorDatas[5]);
			Mouse.registerCursor(DESKTOP_DRAG,cursorDatas[6]);
			cursorInitialized = true;
		}
		
	}
}