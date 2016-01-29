package egret.components.menuClasses
{
	import egret.collections.ICollection;
	import egret.collections.ObjectCollection;
	import egret.collections.XMLCollection;

	/** 
	 * 默认的Menu 或 MenuBar 控件的 dataDescriptor
	 * @author xzper
	 */ 
	public class DefaultMenuDataDescriptor implements IMenuDataDescriptor
	{
		public function DefaultMenuDataDescriptor()
		{
		}
		
		private var childrenKey:String = "children";
		/**
		 * @inheritDoc
		 */
		public function getChildren(node:Object):ICollection
		{
			if(node is XML)
			{
				return new XMLCollection(XML(node));
			}
			else if(node.hasOwnProperty(childrenKey))
			{
				var collection:ObjectCollection = new ObjectCollection(childrenKey);
				collection.source = node;
				return collection;
			}
			return null;
		}
		
		/**
		 * @inheritDoc
		 */
		public function hasChildren(node:Object):Boolean
		{
			if(!node)
				return false;
			if(node is XML)
			{
				return XML(node).children().length()>0;
			}
			else if(node is Object)
			{
				if(node.hasOwnProperty(childrenKey))
					return node[childrenKey].length>0;
			}
			return false;
		}
		
		/**
		 * @inheritDoc
		 */
		public function getType(node:Object):String
		{
			if (node is XML)
			{
				return String(node.@type);
			}
			else if (node is Object)
			{
				try
				{
					return String(node.type);
				}
				catch(e:Error)
				{
				}
			}
			return "";
		}
		
		/**
		 * @inheritDoc
		 */
		public function isEnabled(node:Object):Boolean
		{
			var enabled:*;
			if (node is XML)
			{
				enabled = node.@enabled;
				if (enabled[0] == false)
					return false;
			}
			else if (node is Object)
			{
				try
				{
					return !("false" == String(node.enabled))
				}
				catch(e:Error)
				{
				}
			}
			return true;
		}
		
		/**
		 * @inheritDoc
		 */
		public function setEnabled(node:Object, value:Boolean):void
		{
			if (node is XML)
			{
				node.@enabled = value;
			}
			else if (node is Object)
			{
				try
				{
					node.enabled = value;
				}
				catch(e:Error)
				{
				}
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function isToggled(node:Object):Boolean
		{
			if (node is XML)
			{
				var toggled:* = node.@toggled;
				if (toggled[0] == true)
					return true;
			}
			else if (node is Object)
			{
				try
				{
					return Boolean(node.toggled);
				}
				catch(e:Error)
				{
				}
			}
			return false;
		}
		
		/**
		 * @inheritDoc
		 */
		public function setToggled(node:Object, value:Boolean):void
		{
			if (node is XML)
			{
				node.@toggled = value;
			}
			else if (node is Object)
			{
				try
				{
					node.toggled = value;
				}
				catch(e:Error)
				{
				}
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function getGroupName(node:Object):String
		{
			if (node is XML)
			{
				return node.@groupName;
			}
			else if (node is Object)
			{
				try
				{
					return node.groupName;
				}
				catch(e:Error)
				{
				}
			}
			return "";
		}
	}
}