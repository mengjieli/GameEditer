package egret.states
{
	import egret.components.SkinnableComponent;
	import egret.core.IAsset;
	import egret.core.IContainer;
	import egret.core.IStateClient;
	import egret.core.IVisualElement;
	import egret.core.ns_egret;
	
	use namespace ns_egret;
	
	/**
	 * 添加显示元素
	 * @author dom
	 */	
	public class AddItems extends OverrideBase 
	{
		/**
		 * 添加父级容器的底层
		 */		
		public static const FIRST:String = "first";
		/**
		 * 添加在父级容器的顶层 
		 */		
		public static const LAST:String = "last";
		/**
		 * 添加在相对对象之前 
		 */		
		public static const BEFORE:String = "before";
		/**
		 * 添加在相对对象之后 
		 */		
		public static const AFTER:String = "after";
		
		/**
		 * 构造函数
		 */		
		public function AddItems()
		{
			super();
		}
		
		/**
		 * 要添加到的属性 
		 */		
		public var propertyName:String = "";
		
		/**
		 * 添加的位置 
		 */		
		public var position:String = AddItems.LAST;
		
		/**
		 * 相对的显示元素的实例名
		 */		
		public var relativeTo:String;
		
		/**
		 * 目标实例名
		 */		
		public var target:String;
		
		private static const INITIALIZE_FUNCTION:QName = new QName(ns_egret, "initialize")
		private static const ID_MAP:QName = new QName(ns_egret, "idMap");
		
		override public function initialize(parent:IStateClient):void
		{
			var idMap:Object;
			if(parent[ID_MAP])
				idMap = parent[ID_MAP];
			var targetElement:IVisualElement = (idMap?idMap[target]:parent[target]) as IVisualElement;
			if(!targetElement||targetElement is SkinnableComponent)
				return;
			//让UIAsset和UIMovieClip等素材组件立即开始初始化，防止延迟闪一下或首次点击失效的问题。
			if(targetElement is IAsset)
			{
				try
				{
					targetElement[INITIALIZE_FUNCTION]();
				}
				catch(e:Error)
				{
				}
			}
		}
		
		override public function apply(parent:IContainer):void
		{
			var idMap:Object = parent;
			if(idMap[ID_MAP])
				idMap = idMap[ID_MAP];
			var index:int;
			var relative:IVisualElement;
			try
			{
				relative = idMap[relativeTo] as IVisualElement;
			}
			catch(e:Error)
			{
			}
			var targetElement:IVisualElement = idMap[target] as IVisualElement;
			var dest:IContainer = propertyName?idMap[propertyName]:parent as IContainer;
			if(!targetElement||!dest)
				return;
			switch (position)
			{
				case FIRST:
					index = 0;
					break;
				case LAST:
					index = -1;
					break;
				case BEFORE:
					index = dest.getElementIndex(relative);
					break;
				case AFTER:
					index = dest.getElementIndex(relative) + 1;
					break;
			}    
			if (index == -1)
				index = dest.numElements;
			dest.addElementAt(targetElement,index);
		}
		
		override public function remove(parent:IContainer):void
		{
			var idMap:Object = parent;
			if(idMap[ID_MAP])
				idMap = idMap[ID_MAP];
			var dest:IContainer = propertyName==null||propertyName==""?
				parent:idMap[propertyName] as IContainer;
			var targetElement:IVisualElement = idMap[target] as IVisualElement;
			if(!targetElement||!dest)
				return;
			if(dest.getElementIndex(targetElement)!=-1)
			{
				dest.removeElement(targetElement);
			}
		}
	}
	
}
