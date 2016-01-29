package egret.ui.components
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	
	import egret.collections.ArrayCollection;
	import egret.components.PopUpAnchor;
	import egret.utils.ContainerUtil;
	
	/**
	 * 具有下拉菜单的文本输入框
	 * @author 雷羽佳
	 */
	public class DropDownTextInput extends TextInput
	{
		public function DropDownTextInput()
		{
			super();
			this.addEventListener(Event.ADDED_TO_STAGE,addedToStageHandler);	
			this.addEventListener(Event.REMOVED_FROM_STAGE,removeFromStageHandler);
		}
		
		private var _stage:Stage;
		protected function removeFromStageHandler(event:Event):void
		{
			_stage.removeEventListener(Event.REMOVED_FROM_STAGE,removeFromStageHandler);
			_stage.removeEventListener(MouseEvent.CLICK,clickHandler);
			_stage = null;
		}		
		
		protected function addedToStageHandler(event:Event):void
		{
			this.stage.removeEventListener(Event.ADDED_TO_STAGE,addedToStageHandler);
			_stage = stage;
			_stage.addEventListener(MouseEvent.CLICK,clickHandler);
		}		

		
		public var popUp:PopUpAnchor;
		public var iconList:IconList;
		
		private var _labelField:String = "label";
		/**
		 * 数据提供程序项目中作为标签显示的字段名称。
		 */
		public function get labelField():String
		{
			return _labelField;
		}
		
		public function set labelField(value:String):void
		{
			if(_labelField==value)
				return;
			_labelField = value;
			if(iconList)
				iconList.labelField = _labelField;
		}
		
		private var _labelFunction:Function;
		/**
		 * 用户提供的函数，在每个项目上运行以确定其标签。labelFunction 属性覆盖 labelField 属性。 
		 */
		public function get labelFunction():Function
		{
			return _labelFunction;
		}
		
		public function set labelFunction(value:Function):void
		{
			if(_labelFunction==value)
				return;
			_labelFunction = value;
			if(iconList)
				iconList.labelFunction = _labelFunction;
		}
		
		private var _iconField:String = "icon";
		/**
		 * 数据提供程序项目中作为图标显示的字段名称。
		 */		
		public function get iconField():String
		{
			return _iconField;
		}
		public function set iconField(value:String):void
		{
			if (value == _iconField)
				return 
			_iconField = value;
			if(iconList)
				iconList.iconField = _iconField;
		}
		
		private var _iconFunction:Function; 
		/**
		 * 用户提供的函数，在每个项目上运行以确定其图标数据源。
		 */		
		public function get iconFunction():Function
		{
			return _iconFunction;
		}
		public function set iconFunction(value:Function):void
		{
			if (value == _iconFunction)
				return 
			_iconFunction = value;
			if(iconList)
				iconList.iconFunction = _iconFunction;
		}
		/**
		 * 从下拉菜单选取结果后的字符串格式化函数,示例：resultLabelFunction(item:Object):String
		 */		
		public var resultLabelFunction:Function;
		
		private var _filterFunction:Function;
		/**
		 * 过滤函数,示例：filterFunc(item:Object,key:String):Boolean;
		 */
		public function get filterFunction():Function
		{
			return _filterFunction;
		}
		
		public function set filterFunction(value:Function):void
		{
			if(_filterFunction==value)
				return;
			_filterFunction = value;
			refreshFilter();
		}
		
		private var _filterField:String = "name";
		/**
		 * 数据提供程序项目中作为过滤字符的字段名称。
		 */
		public function get filterField():String
		{
			return _filterField;
		}
		
		public function set filterField(value:String):void
		{
			if(_filterField==value)
				return;
			_filterField = value;
			refreshFilter();
		}
		
		/**
		 * 刷新过滤函数
		 */		
		private function refreshFilter():void
		{
			var filterFunc:Function = _filterFunction==null?doFilter:_filterFunction;
			var list:Array = [];
			var key:String = textDisplay.text;
			if(key)
			{
				key = key.toLowerCase();
				for each(var item:Object in dataProvider)
				{
					if(filterFunc(item,key))
						list.push(item);
				}
			}
			listDp.source = list;
			if(list.length>0)
				popUp.displayPopUp = true;
			else
				popUp.displayPopUp = false;
		}
		
		private function doFilter(item:Object,key:String):Boolean
		{
			var str:String = getFilterStr(item);
			str = str.toLowerCase();
			return str.indexOf(key)==0;
		}
		
		/**
		 * 默认的过滤函数
		 */
		private function getFilterStr(item:Object):String
		{
			if (item is String)
				return String(item);
			
			if (item is XML)
			{
				try
				{
					if (item[_filterField].length() != 0)
						item = item[_filterField];
				}
				catch(e:Error)
				{
				}
			}
			else if (item is Object)
			{
				try
				{
					if (item[_filterField] != null)
						item = item[_filterField];
				}
				catch(e:Error)
				{
				}
			}
			
			if (item is String)
				return String(item);
			
			try
			{
				if (item !== null)
					return item.toString();
			}
			catch(e:Error)
			{
			}
			
			return "";
		}
		
		/**
		 * 筛选数据源
		 */		
		public var dataProvider:Array = [];
		/**
		 * 列表数据源
		 */		
		private var listDp:ArrayCollection = new ArrayCollection();
		
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName,instance);
			if(instance==iconList)
			{
				iconList.dataProvider = listDp;
				iconList.iconField = _iconField;
				iconList.iconFunction = _iconFunction;
				iconList.labelField = _labelField;
				iconList.labelFunction = _labelFunction;
				iconList.doubleClickEnabled = true;
				iconList.addEventListener(MouseEvent.DOUBLE_CLICK,onListDoubleClick);
			}
			else if(instance==textDisplay)
			{
				textDisplay.addEventListener(Event.CHANGE,onTextChange);
				textDisplay.addEventListener(KeyboardEvent.KEY_DOWN,onKeyDown);
			}
		}
		
		private function onListDoubleClick(event:MouseEvent):void
		{
			setSelectedItem();
		}
		
		private function onKeyDown(event:KeyboardEvent):void
		{
			if(event.keyCode==Keyboard.ENTER&&popUp.displayPopUp)
			{
				event.preventDefault();
				event.stopImmediatePropagation();
				setSelectedItem();
			}
		}
		
		
		private function setSelectedItem():void
		{
			popUp.displayPopUp = false;
			if(resultLabelFunction==null)
				textDisplay.text = iconList.itemToLabel(iconList.selectedItem);
			else
				textDisplay.text = resultLabelFunction(iconList.selectedItem);
			textDisplay.setSelection(textDisplay.text.length,textDisplay.text.length);
		}
		
		private function onTextChange(event:Event):void
		{
			refreshFilter();
		}
		
		private var isFocus:Boolean = false;
		override protected function focusInHandler(event:FocusEvent):void
		{
			super.focusInHandler(event);
			refreshFilter();
			isFocus = true;
		}
		
		override protected function focusOutHandler(event:FocusEvent):void
		{
			super.focusOutHandler(event);
			isFocus = false;
		}
		
		protected function clickHandler(event:MouseEvent):void
		{
			if(
				!ContainerUtil.containsPro(popUp.popUp as DisplayObjectContainer,event.target as DisplayObject) &&
				!ContainerUtil.containsPro(this as DisplayObjectContainer,event.target as DisplayObject) && isFocus == false)
			{
				popUp.displayPopUp = false;
			}
		}
	}
}