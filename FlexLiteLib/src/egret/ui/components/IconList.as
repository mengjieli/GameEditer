package egret.ui.components
{
	import flash.utils.getQualifiedClassName;
	
	import egret.components.IItemRenderer;
	import egret.components.List;
	
	
	/**
	 * 含有图标字段的列表组件
	 * @author dom
	 */
	public class IconList extends List
	{
		/**
		 * 构造函数
		 */		
		public function IconList()
		{
			super();
		}
		
		override protected function createChildren():void
		{
			if(!itemRenderer)
				itemRenderer = IconItemRenderer;
			super.createChildren();
		}
		
		private var iconFieldOrFunctionChanged:Boolean; 
		
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
			iconFieldOrFunctionChanged = true;
			invalidateProperties();
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
			iconFieldOrFunctionChanged = true;
			invalidateProperties(); 
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			if (iconFieldOrFunctionChanged)
			{
				if (dataGroup)
				{
					var itemIndex:int;
					
					if (layout && layout.useVirtualLayout)
					{
						for each (itemIndex in dataGroup.getElementIndicesInView())
						{
							updateRendererIconProperty(itemIndex);
						}
					}
					else
					{
						var n:int = dataGroup.numElements;
						for (itemIndex = 0; itemIndex < n; itemIndex++)
						{
							updateRendererIconProperty(itemIndex);
						}
					}
				}
				iconFieldOrFunctionChanged = false; 
			}
		}
		
		private function updateRendererIconProperty(itemIndex:int):void
		{
			var renderer:IconItemRenderer = dataGroup.getElementAt(itemIndex) as IconItemRenderer; 
			if (renderer)
			{
				renderer.icon = itemToIcon(renderer.data); 
			}
			
			
		}
		
		override public function updateRenderer(renderer:IItemRenderer, itemIndex:int, data:Object):IItemRenderer
		{
			if(renderer is IconItemRenderer)
			{
				IconItemRenderer(renderer).icon = itemToIcon(data);
			}
			return super.updateRenderer(renderer,itemIndex,data);
		}
		
		/**
		 * 从数据源里获取图标
		 */		
		public function itemToIcon(item:Object):Object
		{
			if (_iconFunction != null)
				return _iconFunction(item);
			
			if (item is String)
				return String(item);
			if(item[iconField])
				return item[iconField];
			else
				return null;
		}
	}
}