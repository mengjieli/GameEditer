package egret.components.menuClasses
{
	import flash.events.MouseEvent;
	
	import avmplus.getQualifiedClassName;
	
	import egret.components.Label;
	import egret.components.SkinnableContainer;
	import egret.components.UIAsset;

	/** 
	 * MenuBarItem 类定义 MenuBar 控件顶级菜单栏的默认项呈示器。
	 * 默认情况下，项呈示器将绘制与顶级菜单栏中每个项目相关联的文本和可选图标。 
	 * @author 雷羽佳
	 */ 
	public class MenuBarItemRenderer extends SkinnableContainer implements IMenuBarItemRenderer
	{
		private var _state:String = "up"
		private var _data:Object;
		public function MenuBarItemRenderer()
		{
			super();
			mouseChildren = false;
			this.addEventListener(MouseEvent.MOUSE_DOWN,mouesDownHandler);
			this.addEventListener(MouseEvent.ROLL_OVER,rollOverHandler);
			this.addEventListener(MouseEvent.ROLL_OUT,rollOutHandler);
		}
		
		protected function rollOutHandler(event:MouseEvent):void
		{
			if(!_menuDown)
				_state = "up";
			validateSkinState();
		}
		
		protected function mouesDownHandler(event:MouseEvent):void
		{
			_state = "down";
			validateSkinState();
		}
		
		protected function rollOverHandler(event:MouseEvent):void
		{
			if(!_menuDown)
				_state = "over";
			validateSkinState();
		}
		
		private var _menuDown:Boolean = false;
		/**
		 * 菜单按下状态
		 */		
		public function get menuDown():Boolean
		{
			return _menuDown;
		}
		
		public function set menuDown(value:Boolean):void
		{
			_menuDown = value;
			if(_menuDown == false)
			{
				_state = "up";
				invalidateSkinState();
			}
		}
		
		public var iconDisplay:UIAsset;
		public var labelDisplay:Label;
		
		/**
		 * @inheritDoc
		 */
		public function get data():Object
		{
			return _data;
		}
		
		public function set data(value:Object):void
		{
			_data = value;
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName,instance);
			if(icon && instance == iconDisplay)
			{
				iconDisplay.source = icon;
			}
			if(label && instance == labelDisplay)
			{
				labelDisplay.text = label;
			}
		}
		
		private var _icon:Object;
		/**
		 * @inheritDoc
		 */
		public function get icon():Object
		{
			return _icon;
		}
		
		public function set icon(value:Object):void
		{
			_icon = value;
			if(iconDisplay)
			{
				iconDisplay.source = value;
			}
		}
		
		private var _label:String;
		/**
		 * @inheritDoc
		 */
		public function get label():String
		{
			return _label;
		}
		
		public function set label(value:String):void
		{
			_label = value;
			if(labelDisplay)
			{
				labelDisplay.text = value;
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function getCurrentSkinState():String
		{
			return _state;
		}
		
		/**
		 * @inheritDoc
		 */
		public function itemDown():void
		{
			_state = "down";
			validateSkinState();
		}
		
		/**
		 * @inheritDoc
		 */
		public function itemUp():void
		{
			_state = "up";
			validateSkinState();
		}
	}
}