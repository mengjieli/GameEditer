package egret.components.menuClasses
{
	import avmplus.getQualifiedClassName;
	
	import egret.components.UIAsset;
	import egret.components.supportClasses.ItemRenderer;

	/** 
	 * MenuItemRenderer 类定义任何菜单控件中菜单项目的默认项呈示器。
	 * 默认情况下，项呈示器将绘制与每个菜单项、分隔符和图标相关联的文本。 
	 * @author xzper
	 */ 
	public class MenuItemRenderer extends ItemRenderer implements IMenuItemRenderer
	{
		public function MenuItemRenderer()
		{
			super();
		}
		
		/**
		 * [SkinPart]分隔符图标
		 */
		public var separatorIcon:UIAsset;
		
		/**
		 * [SkinPart]图标显示对象
		 */
		public var iconDisplay:UIAsset;
		/**
		 * [SkinPart]显示复选按钮的图标
		 */
		public var checkDisplay:UIAsset;
		
		/**
		 * [SkinPart]显示单选按钮的图标
		 */
		public var radioDisplay:UIAsset;
		
		/**
		 * [SkinPart]子节点显示图标
		 */
		public var disclosureDisplay:UIAsset;
		
		private var _iconSkinName:Object;
		/**
		 * @inheritDoc
		 */
		public function get iconSkinName():Object
		{
			return _iconSkinName;
		}
		public function set iconSkinName(value:Object):void
		{
			if(_iconSkinName==value)
				return;
			_iconSkinName = value;
			if(iconDisplay)
			{
				iconDisplay.source = _iconSkinName;
			}
		}
		
		private var _hasChildren:Boolean;
		/**
		 * @inheritDoc
		 */
		public function get hasChildren():Boolean
		{
			return _hasChildren;
		}

		public function set hasChildren(value:Boolean):void
		{
			if(_hasChildren==value)
				return;
			_hasChildren = value;
			invalidateProperties();
		}
		
		private var _type:String;
		/**
		 * @inheritDoc
		 */
		public function get type():String
		{
			return _type;
		}

		public function set type(value:String):void
		{
			if(_type==value)
				return;
			_type = value;
			this.mouseChildren = this.mouseEnabled = !(value == "separator");
			invalidateSkinState();
			invalidateProperties();
		}
		
		private var _isEnabled:Boolean = true;
		/**
		 * @inheritDoc
		 */
		public function get isEnabled():Boolean
		{
			return _isEnabled;
		}
		
		public function set isEnabled(value:Boolean):void
		{
			if(_isEnabled==value)
				return;
			_isEnabled = value;
			this.enabled = value;
		}
		
		private var _isToggled:Boolean = true;
		/**
		 * @inheritDoc
		 */
		public function get isToggled():Boolean
		{
			return _isToggled;
		}
		
		public function set isToggled(value:Boolean):void
		{
			if(_isToggled==value)
				return;
			_isToggled = value;
			invalidateProperties();
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName , instance);
			if(instance == iconDisplay)
			{
				iconDisplay.source = iconSkinName;
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function commitProperties():void
		{
			super.commitProperties();
			separatorIcon.visible = false;
			labelDisplay.visible = true;
			iconDisplay.visible = true;
			disclosureDisplay.visible =false;
			checkDisplay.visible = false;
			radioDisplay.visible = false;
			
			labelDisplay.includeInLayout = iconDisplay.includeInLayout = disclosureDisplay.includeInLayout = 
				checkDisplay.includeInLayout = radioDisplay.includeInLayout = true;

			if(type)
			{
				if(type =="separator")
				{
					labelDisplay.includeInLayout = iconDisplay.includeInLayout = disclosureDisplay.includeInLayout = 
						checkDisplay.includeInLayout = radioDisplay.includeInLayout = false;
					separatorIcon.visible = true;
					labelDisplay.visible = false;
					iconDisplay.visible = false;
				}
				else if(type == "radio" && isToggled)
				{
					radioDisplay.visible = true;
				}
				else if(type == "check" && isToggled)
				{
					checkDisplay.visible = true;
				}
			}
			else if(hasChildren)
			{
				disclosureDisplay.visible = true;
			}
		}
	}
}