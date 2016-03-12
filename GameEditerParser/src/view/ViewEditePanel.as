package view
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	import egret.components.Group;
	import egret.components.UIAsset;
	import egret.core.BitmapFillMode;
	
	import extend.ui.DragManager;
	
	import main.events.EventMgr;
	
	import view.component.ComponentBase;
	import view.component.Panel;
	import view.component.data.ComponentData;
	import view.component.data.GroupData;
	import view.component.data.ImageData;
	import view.events.EditeComponentEvent;

	/**
	 * TODO
	 * 编辑界面相关
	 * 1. 自动对齐功能，可以设置自动对齐的像素大小
	 * 2. 在父对象内有居中对齐吸附
	 * 3. 点击某个对象之后就再拖动元素并释放时元素有相交区域就可以放入该元素之中，并且在拖动时有智能提示哪个是 parent (有个透明的 parent 字样的底框标明，并且父对象有描边效果)
	 * 4. 在拖动时下方有提示在面板上的位置，和在父类对象中的位置，以及父对象的名称
	 */
	public class ViewEditePanel extends Group
	{
		private var dragBg:UIAsset;
		private var backGround:UIAsset;
		private var container:Group;
		private var viewPanel:Panel;
		private var viewData:ViewData;
		private var selectComponent:ComponentData;
		private var editedComponent:ComponentData;
		
		public function ViewEditePanel()
		{
			backGround = new UIAsset();
			backGround.source = "assets/bg/viewBg.png";
			backGround.fillMode = BitmapFillMode.SCALE;
			backGround.percentWidth = 100;
			backGround.percentHeight = 100;
			this.addElement(backGround);
			
			dragBg = new UIAsset();
			dragBg.source = "assets/bg/dragBg.png";
			dragBg.scale9Grid = new Rectangle(1,1,8,8);
			this.addElement(dragBg);
			dragBg.percentWidth = 100;
			dragBg.percentHeight = 100;
			dragBg.visible = false;
			
			var mask:UIAsset = new UIAsset();
			mask.source = "assets/bg/viewBg.png";
			mask.fillMode = BitmapFillMode.SCALE;
			mask.percentWidth = 100;
			mask.percentHeight = 100;
			this.addElement(mask);
			
			container = new Group();
			this.addElement(container);
			container.mask = mask;
			var cross:UIAsset = new UIAsset("assets/cross.png");
			container.addElement(cross);
			cross.x = -5;
			cross.y = -5;
//			container.x = 100;
//			container.y = 100;
			
//			this.addEventListener(UIEvent.CREATION_COMPLETE,onCreateComplete);
			
			this.addEventListener(MouseEvent.MOUSE_DOWN,onMouseEvent);
			this.addEventListener(MouseEvent.MOUSE_OVER,onMouseEvent);
			this.addEventListener(MouseEvent.MOUSE_OUT,onMouseEvent);
			this.addEventListener(MouseEvent.MOUSE_MOVE,onMouseEvent);
			this.addEventListener(MouseEvent.MOUSE_UP,onMouseEvent);
			DragManager.getInstance().addEventListener(DragManager.START_DRAG,onMouseEvent);
			EventMgr.ist.addEventListener(EditeComponentEvent.EDITE_COMPOENET,this.onEditerComponent);
		}
		
//		private function onCreateComplete(e:UIEvent):void {
//			container.x = this.width/2;
//			container.y = this.height/2;
//		}
		
		public function showView(viewData:ViewData):void {
			this.viewData = viewData;
			viewPanel = new Panel(viewData.panel);
			this.container.addElement(viewPanel);
			selectComponent = this.viewData.panel;
			selectComponent.selected = true;
			editerComponent(this.viewData.panel);
		}
		
		/**是否在拖动新的组件**/
		private var dragNew:Boolean = false;
		/**是否在拖动已有的的组件**/
		private var dragFlag:Boolean = false;
		private var dragComponent:ComponentData;
		private var dragStartX:int;
		private var dragStartY:int;
		private var dragMouseX:int;
		private var dragMouseY:int;
		private var dragContainer:Boolean = false;
		private var dragMove:Boolean;
		private var setDragComponentSelected:Boolean;
		private function onMouseEvent(e:Event):void {
			switch(e.type) {
				case DragManager.START_DRAG:
					if(dragNew == false && DragManager.isDraging && DragManager.type == "Component" && this.mouseX >= 0 && this.mouseX < this.width && this.mouseY >= 0 && this.mouseY < this.height) {
						dragBg.visible = true;
						dragNew = true;
					}
					//拖动的是图片资源
					if(DragManager.isDraging && DragManager.type == "image") {
						dragBg.visible = true;
						dragNew = true;
					}
					break;
				case MouseEvent.MOUSE_DOWN:
					var targetComponent:ComponentBase;
					var target:* = e.target;
					while(target) {
						if(target is ComponentBase) {
							targetComponent = target as ComponentBase;
							if(targetComponent.data.editerFlag == true) {
								break;
							}
							targetComponent = null;
						}
						target = target.parent;
					}
					
					if(!targetComponent) {
						dragContainer = true;
						dragMove = false;
						this.container.startDrag();
					} else {
						this.dragFlag = true;
						this.dragComponent = targetComponent.data;
						setDragComponentSelected = false;
						if(dragComponent.inediter == false) {
							dragComponent.inediter = true;
							setDragComponentSelected = true;
							this.editedComponent.inediter = false;
							EventMgr.ist.dispatchEvent(new EditeComponentEvent(EditeComponentEvent.SHOW_COMPONENT_ATTRIBUTE,dragComponent));
						}
						this.dragStartX = this.dragComponent.x;
						this.dragStartY = this.dragComponent.y;
						this.dragMouseX = this.container.mouseX;
						this.dragMouseY = this.container.mouseY;
						this.dragMove = false;
					}
					break;
				case MouseEvent.MOUSE_OVER:
					if(dragNew == false && DragManager.isDraging && DragManager.type == "Component") {
						dragBg.visible = true;
						dragNew = true;
					}
					//拖动的是图片资源
					if(DragManager.isDraging && DragManager.type == "image") {
						dragBg.visible = true;
						dragNew = true;
					}
				case MouseEvent.MOUSE_MOVE:
					if(dragFlag) {
						if(dragMove == true || Math.abs(this.container.mouseX - this.dragMouseX) > 30 || Math.abs(this.container.mouseY - this.dragMouseY)) {
							this.dragComponent.x = this.container.mouseX + this.dragStartX - this.dragMouseX;
							this.dragComponent.y = this.container.mouseY + this.dragStartY - this.dragMouseY;
							dragMove = true;
						}
					} else {
						dragMove = true;
					}
					break;
				case MouseEvent.MOUSE_OUT:
					if(dragNew) {
						dragBg.visible = false;
						dragNew = false;
					}
					break;
				case MouseEvent.MOUSE_UP:
					if(dragNew) {
						dragBg.visible = false;
						dragNew = false;
						var componentData:ComponentData;
						if(DragManager.type == "Component") { //拖动的是组件
							componentData = DragManager.dragData;
						} else if(DragManager.type == "image") {
							var image:ImageData = new ImageData();
							image.url = DragManager.dragData.url;
							componentData = image;
						}
						this.acceptComponent(componentData,DragManager.offX,DragManager.offY);
					}
					if(dragFlag) {
						dragFlag = false;
						if(setDragComponentSelected) {
							dragComponent.inediter = false;
							setDragComponentSelected = false;
							this.editedComponent.inediter = true;
							EventMgr.ist.dispatchEvent(new EditeComponentEvent(EditeComponentEvent.SHOW_COMPONENT_ATTRIBUTE,this.editedComponent));
						}
						if(dragMove == false) {
							if(dragComponent is GroupData) {
								if(selectComponent) {
									selectComponent.selected = false;
									selectComponent = null;
								}
								this.selectComponent = dragComponent;
								this.selectComponent.selected = true;
							}
							editerComponent(dragComponent);
						}
					}
					if(dragContainer) {
						this.container.stopDrag();
						dragContainer = false;
						if(dragMove == false) {
							if(selectComponent) {
								selectComponent.selected = false;
								selectComponent = null;
							}
							this.selectComponent = this.viewData.panel;
							this.selectComponent.selected = true;
							editerComponent(this.viewData.panel);
						}
					}
					break;
			}
		}
		
		/**
		 * 接受外部拖拽的新组件
		 */
		private function acceptComponent(data:ComponentData,offX:Number=0,offY:Number=0):void {
			data.selected = false;
			data.x = this.container.mouseX + offX;
			data.y = this.container.mouseY + offY;
			if(this.selectComponent is GroupData) {
				var group:GroupData = this.selectComponent as GroupData;
				while(group != this.viewData.panel) {
					data.x -= group.x;
					data.y -= group.y;
					group = group.parent;
				}
				(this.selectComponent as GroupData).addChild(data);
			} else {
				this.viewData.panel.addChild(data);
			}
			editerComponent(data);
		}
		
		/**
		 * 编辑某个组件，属性界面会显示界面相关的内容
		 */
		private function editerComponent(data:ComponentData):void {
			EventMgr.ist.dispatchEvent(new EditeComponentEvent(EditeComponentEvent.EDITE_COMPOENET,data));
		}
		
		private function onEditerComponent(e:EditeComponentEvent):void {
			if(editedComponent) {
				editedComponent.inediter = false;
			}
			this.editedComponent = e.component;
			this.editedComponent.inediter = true;
		}
	}
}