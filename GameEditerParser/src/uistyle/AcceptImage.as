package uistyle
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import egret.components.UIAsset;
	import egret.core.BitmapFillMode;
	
	import extend.ui.DragManager;
	import extend.ui.ImageLoader;
	
	import main.data.ToolData;
	import main.menu.NativeMenuExtend;
	import main.menu.NativeMenuItemExtend;

	public class AcceptImage extends ImageLoader
	{
		private var backGround:UIAsset;
		private var dragShow:ImageLoader;
		private var _acceptImageURL:String;
		
		public function AcceptImage()
		{
			this.addEventListener(MouseEvent.MOUSE_OVER,onDrag);
			this.addEventListener(MouseEvent.MOUSE_OUT,onDrag);
			this.addEventListener(MouseEvent.MOUSE_UP,onDrag);
			DragManager.getInstance().addEventListener(DragManager.START_DRAG,onDrag);
			
			var menuList:Array = [new NativeMenuItemExtend("设置为空","",false,null,this.setNone)];
			this.contextMenu = new NativeMenuExtend(menuList);
		}
		
		private function setNone():void {
			this.source = "";
			acceptImage(null);
			dragShow.visible = false;
		}
		
		private var inDrag:Boolean = false;
		private function onDrag(e:Event):void {
			switch(e.type) {
				case DragManager.START_DRAG:
					if(inDrag == false && DragManager.isDraging && DragManager.type == "image" && this.mouseX >= 0 && this.mouseX < this.showMaxWidth && this.mouseY >= 0 && this.mouseY < this.showMaxHeight) {
						var dragData:* = DragManager.dragData;
						dragShow.visible = true;
						backGround.alpha = 0;
						dragShow.source = ToolData.getInstance().project.getResURL(dragData.url);
						inDrag = true;
					}
					break;
				case MouseEvent.MOUSE_OVER:
					if(DragManager.isDraging && DragManager.type == "image") {
						var dragData:* = DragManager.dragData;
						dragShow.visible = true;
						backGround.alpha = 0;
						dragShow.source = ToolData.getInstance().project.getResURL(dragData.url);
						inDrag = true;
					}
					break;
				case MouseEvent.MOUSE_OUT:
					if(inDrag) {
						flushBackground();
						dragShow.visible = false;
						inDrag = false;
					}
					break;
				case MouseEvent.MOUSE_UP:
					if(inDrag) {
						flushBackground();
						dragShow.visible = false;
						_acceptImageURL = DragManager.dragData.url;
						this.source = ToolData.getInstance().project.getResURL(DragManager.dragData.url);
						inDrag = false;
						this.acceptImage(DragManager.dragData);
					}
					break;
			}
		}
		
		public function acceptImage(d:*):void {
			this.dispatchEvent(new Event(Event.CHANGE));
		}
		
		public function get acceptImageURL():String {
			return _acceptImageURL;
		}
		
		override protected function createChildren():void {
			super.createChildren();
			
			backGround = new UIAsset();
			backGround.source = "assets/bg/canvasBg.png";
			backGround.fillMode = BitmapFillMode.REPEAT;
			this.addElement(backGround);
			
			dragShow = new ImageLoader();
			this.addElement(dragShow);
		}
		
		override public function set showMaxWidth(value:Number):void {
			super.showMaxWidth = value;
			dragShow.showMaxWidth = value;
			flushBackground();
		}
		
		override public function set showMaxHeight(value:Number):void {
			super.showMaxHeight = value;
			dragShow.showMaxHeight = value;
			flushBackground();
		}
		
		override public function set source(val:String):void {
			super.source = val;
			flushBackground();
		}
		
		private function flushBackground():void {
			if(this.url == "") {
				backGround.alpha = 1;
			} else {
				backGround.alpha = 0;
			}
			backGround.width = this.showMaxWidth;
			backGround.height = this.showMaxHeight;
		}
	}
}