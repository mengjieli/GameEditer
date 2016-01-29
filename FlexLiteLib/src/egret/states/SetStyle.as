package egret.states
{
	import egret.core.IContainer;
	import egret.core.IStyleClient;
	import egret.core.ns_egret;
	
	/**
	 * 设置属性
	 * @author dom
	 */	
	public class SetStyle extends OverrideBase
	{
		/**
		 * 构造函数
		 */		
		public function SetStyle()
		{
			super();
		}
		
		/**
		 * 要修改的属性名
		 */		
		public var name:String;
		
		/**
		 * 目标实例名
		 */		
		public var target:String;
		
		/**
		 * 属性值 
		 */		
		public var value:*;
		
		/**
		 * 旧的属性值 
		 */		
		private var oldValue:Object;
		
		private static const ID_MAP:QName = new QName(ns_egret, "idMap");
		
		override public function apply(parent:IContainer):void
		{   
			var idMap:Object = parent;
			if(idMap[ID_MAP])
				idMap = idMap[ID_MAP];
			var obj:Object = target==null||target==""?parent:idMap[target];
			if(obj==null||!(obj is IStyleClient))
				return;
			oldValue = IStyleClient(obj).getStyle(name);
			setStyleValue(obj as IStyleClient, name, value, oldValue);
		}
		
		override public function remove(parent:IContainer):void
		{   
			var idMap:Object = parent;
			if(idMap[ID_MAP])
				idMap = idMap[ID_MAP];
			var obj:Object = target==null||target==""?parent:idMap[target];
			if(obj==null||!(obj is IStyleClient))
				return;
			setStyleValue(obj as IStyleClient, name, oldValue, oldValue);
			oldValue = null;
		}
		
		/**
		 * 设置属性值
		 */		
		private function setStyleValue(obj:IStyleClient, name:String, value:*,
										  valueForType:Object):void
		{
			if (value === undefined)
				obj.clearStyle(name);
			if (value === null)
				obj.setStyle(name,value);
			else if (valueForType is Number)
				obj.setStyle(name,Number(value));
			else if (valueForType is Boolean)
				obj.setStyle(name,toBoolean(value));
			else
				obj.setStyle(name,value);
		}
		/**
		 * 转成Boolean值
		 */		
		private function toBoolean(value:Object):Boolean
		{
			if (value is String)
				return value.toLowerCase() == "true";
			
			return value != false;
		}
	}
	
}
