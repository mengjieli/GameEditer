package egret.components.supportClasses
{
	
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	
	import egret.collections.ICollection;
	import egret.components.List;
	import egret.core.ns_egret;
	import egret.events.CollectionEvent;
	import egret.events.UIEvent;
	
	use namespace ns_egret;
	
	/**
	 * 下拉框打开事件
	 * @eventType egret.events.UIEvent.OPEN
	 */	
	[Event(name="open",type="egret.events.UIEvent")]
	/**
	 * 下来框关闭事件
	 */	
	[Event(name="close",type="egret.events.UIEvent")]
	
	[EXML(show="false")]
	
	[SkinState("normal")]
	[SkinState("open")]
	[SkinState("disabled")]
	
	/**
	 * 下拉列表控件基类
	 * @author dom
	 */	
	public class DropDownListBase extends List
	{
		/**
		 * 构造函数
		 */		
		public function DropDownListBase()
		{
			super();
			captureItemRenderer = false;
			dropDownController = new DropDownController();
		}
		
		/**
		 * [SkinPart]下拉区域显示对象
		 */		
		public var dropDown:DisplayObject;
		/**
		 * [SkinPart]下拉触发按钮
		 */		
		public var openButton:ButtonBase;
		
		
		ns_egret static var PAGE_SIZE:int = 5;
		
		/**
		 * 文本改变标志
		 */		
		private var labelChanged:Boolean = false;
		
		/**
		 * @inheritDoc
		 */
		override public function set dataProvider(value:ICollection):void
		{   
			if (dataProvider === value)
				return;
			
			super.dataProvider = value;
			labelChanged = true;
			invalidateProperties();
		}
		/**
		 * @inheritDoc
		 */
		override public function set labelField(value:String):void
		{
			if (labelField == value)
				return;
			
			super.labelField = value;
			labelChanged = true;
			invalidateProperties();
		}
		/**
		 * @inheritDoc
		 */
		override public function set labelFunction(value:Function):void
		{
			if (labelFunction == value)
				return;
			
			super.labelFunction = value;
			labelChanged = true;
			invalidateProperties();
		}
		
		private var _dropDownController:DropDownController; 
		/**
		 * 下拉控制器
		 */		
		protected function get dropDownController():DropDownController
		{
			return _dropDownController;
		}
		
		protected function set dropDownController(value:DropDownController):void
		{
			if (_dropDownController == value)
				return;
			
			_dropDownController = value;
			
			_dropDownController.addEventListener(UIEvent.OPEN, dropDownController_openHandler);
			_dropDownController.addEventListener(UIEvent.CLOSE, dropDownController_closeHandler);
			
			if (openButton)
				_dropDownController.openButton = openButton;
			if (dropDown)
				_dropDownController.dropDown = dropDown;    
		}
		/**
		 * 下拉列表是否已经已打开
		 */		
		public function get isDropDownOpen():Boolean
		{
			if (dropDownController)
				return dropDownController.isOpen;
			else
				return false;
		}
		
		private var _userProposedSelectedIndex:Number = NO_SELECTION;
				
		ns_egret function set userProposedSelectedIndex(value:Number):void
		{
			_userProposedSelectedIndex = value;
		}
		
		ns_egret function get userProposedSelectedIndex():Number
		{
			return _userProposedSelectedIndex;
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function commitProperties():void
		{
			super.commitProperties();
			
			if (labelChanged)
			{
				labelChanged = false;
				updateLabelDisplay();
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
			
			if (instance == openButton)
			{
				if (dropDownController)
					dropDownController.openButton = openButton;
			}
			else if (instance == dropDown && dropDownController)
			{
				dropDownController.dropDown = dropDown;
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function partRemoved(partName:String, instance:Object):void
		{
			if (dropDownController)
			{
				if (instance == openButton)
					dropDownController.openButton = null;
				
				if (instance == dropDown)
					dropDownController.dropDown = null;
			}
			
			super.partRemoved(partName, instance);
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function getCurrentSkinState():String
		{
			return !enabled ? "disabled" : isDropDownOpen ? "open" : "normal";
		}   
		
		/**
		 * @inheritDoc
		 */
		override protected function commitSelection(dispatchChangedEvents:Boolean = true):Boolean
		{
			var retVal:Boolean = super.commitSelection(dispatchChangedEvents);
			updateLabelDisplay();
			return retVal; 
		}
		
		/**
		 * @inheritDoc
		 */
		override ns_egret function isItemIndexSelected(index:int):Boolean
		{
			return userProposedSelectedIndex == index;
		}
		/**
		 * 打开下拉列表并抛出UIEvent.OPEN事件。
		 */		
		public function openDropDown():void
		{
			dropDownController.openDropDown();
		}
		/**
		 * 关闭下拉列表并抛出UIEvent.CLOSE事件。
		 */		
		public function closeDropDown(commit:Boolean):void
		{
			dropDownController.closeDropDown(commit);
		}
		/**
		 * 更新选中项的提示文本
		 */		
		ns_egret function updateLabelDisplay(displayItem:* = undefined):void
		{
			
		}
		/**
		 * 改变高亮的选中项
		 */		
		ns_egret function changeHighlightedSelection(newIndex:int, scrollToTop:Boolean = false):void
		{
			itemSelected(userProposedSelectedIndex, false);
			userProposedSelectedIndex = newIndex;
			itemSelected(userProposedSelectedIndex, true);
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function dataProvider_collectionChangeHandler(event:CollectionEvent):void
		{       
			super.dataProvider_collectionChangeHandler(event);
			
			labelChanged = true;
			invalidateProperties();
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function item_mouseUpHandler(event:MouseEvent):void
		{
			super.item_mouseUpHandler(event);
			
			userProposedSelectedIndex = selectedIndex;
			closeDropDown(true);
		}
			
		override protected function item_mouseMoveHandler(event:MouseEvent):void
		{
			event.currentTarget.removeEventListener(MouseEvent.MOUSE_MOVE,item_mouseMoveHandler);
		}
//		/**
//		 * @inheritDoc
//		 */
//		override protected function item_mouseDownHandler(event:MouseEvent):void
//		{
//			super.item_mouseDownHandler(event);
//			
//			var itemRenderer:IItemRenderer = event.currentTarget as IItemRenderer;
//			dispatchListEvent(event,ListEvent.ITEM_CLICK,itemRenderer);
//			
//			userProposedSelectedIndex = selectedIndex;
//			closeDropDown(true);
//		}
		/**
		 * 控制器抛出打开列表事件
		 */		
		ns_egret function dropDownController_openHandler(event:UIEvent):void
		{
			addEventListener(UIEvent.UPDATE_COMPLETE, open_updateCompleteHandler);
			itemSelected(userProposedSelectedIndex, false);
			userProposedSelectedIndex = selectedIndex;
			changeHighlightedSelection(userProposedSelectedIndex);
			invalidateSkinState();  
		}
		/**
		 * 打开列表后组件一次失效验证全部完成
		 */		
		ns_egret function open_updateCompleteHandler(event:UIEvent):void
		{   
			removeEventListener(UIEvent.UPDATE_COMPLETE, open_updateCompleteHandler);
			
			dispatchEvent(new UIEvent(UIEvent.OPEN));
		}
		/**
		 * 控制器抛出关闭列表事件
		 */		
		protected function dropDownController_closeHandler(event:UIEvent):void
		{
			addEventListener(UIEvent.UPDATE_COMPLETE, close_updateCompleteHandler);
			invalidateSkinState();
			
			if (!event.isDefaultPrevented())
			{
				setSelectedIndex(userProposedSelectedIndex, true);  
			}
			else
			{
				changeHighlightedSelection(selectedIndex);
			}
		}
		/**
		 * 关闭列表后组件一次失效验证全部完成
		 */		
		private function close_updateCompleteHandler(event:UIEvent):void
		{   
			removeEventListener(UIEvent.UPDATE_COMPLETE, close_updateCompleteHandler);
			
			dispatchEvent(new UIEvent(UIEvent.CLOSE));
		}
	}
	
}
