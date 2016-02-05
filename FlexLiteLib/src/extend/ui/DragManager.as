package extend.ui
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Point;

	public class DragManager extends EventDispatcher
	{
		public function DragManager()
		{
		}
		
		public static const START_DRAG:String = "start_drag";
		
		private static var ist:DragManager;
		public static function getInstance():DragManager {
			if(!ist) {
				ist = new DragManager();
			}
			return ist;
		}
		
		private static var _initFlag:Boolean = false;
		private static var _type:String;
		private static var _dragData:*;
		private static var _dragImage:DisplayObject;
		private static var _isDraging:Boolean;
		private static var stage:Stage;
		private static var dragBg:Sprite;
		
		public static function get isDraging():Boolean {
			return _isDraging;
		}
		
		public static function get dragData():* {
			return _dragData;
		}
		
		public static function get type():String {
			return _type;
		}
		
		public static function startDrag(type:String,dragDisplay:DisplayObject,dragData:*,dragImage:DisplayObject,offX:int=0,offY:int=0,alpha:Number=0.5):void {
			var stage:Stage = dragDisplay.stage;
			if(!stage) {
				stage = ExtendGlobal.stage;
			}
			if(!_initFlag) {
				init(stage);
			}
			DragManager._type = type;
			DragManager.stage = stage;
			DragManager._dragData = dragData;
			DragManager._dragImage = dragImage;
			if(dragImage) {
				_isDraging = true;
				stage.addChild(dragBg);
				dragBg.addChild(dragImage);
				dragBg.startDrag();
				var point:Point = new Point(stage.mouseX,stage.mouseY);
//				if(dragDisplay.stage) {
//					point = dragDisplay.local3DToGlobal(new Vector3D());
//				}
				dragImage.x = point.x + offX;
				dragImage.y = point.y + offY;
				dragImage.alpha = alpha;
			}
			DragManager.getInstance().dispatchEvent(new Event(DragManager.START_DRAG));
		}
		
		private static function dragEnd():void {
			_isDraging = false;
			if(_dragImage && _dragImage.parent) {
				_dragImage.parent.removeChild(_dragImage);
			}
			if(dragBg.parent) {
				dragBg.parent.removeChild(dragBg);
			}
			dragBg.stopDrag();
		}
		
		private static function init(stage:Stage):void {
			stage.addEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
			stage.addEventListener(MouseEvent.MOUSE_UP,onMouseMove);
			dragBg = new Sprite();
			dragBg.mouseEnabled = false;
			dragBg.mouseChildren = false;
		}
		
		private static function onMouseMove(e:MouseEvent):void {
			if(_isDraging) {
				if(e.buttonDown) {
				} else {
					dragEnd();
				}
			}
		}
		
	}
}