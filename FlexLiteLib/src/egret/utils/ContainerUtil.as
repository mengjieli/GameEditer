package egret.utils
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	
	/**
	 * 容器工具
	 * @author 雷羽佳
	 */
	public class ContainerUtil
	{
		public function ContainerUtil()
		{
			
		}
		
		/**
		 * 检查一个显示对象是否在某个显示对象容器里。高级版，只要显示对象的节点的根节点中有一个是指定的显示对象容器则版顶级过都为真。 
		 * @param parent
		 * @param child
		 * @return 
		 * 
		 */		
		public static function containsPro(parent:DisplayObjectContainer,child:DisplayObject):Boolean
		{
			//递归函数
			var checkNode:Function = function($parent:DisplayObjectContainer,$child:DisplayObject):Boolean
			{
				var tmpResult:Boolean = false;
				if($parent == $child)
				{
					tmpResult = true;
				}else
				{
					for(var i:int = 0;i<$parent.numChildren;i++)
					{
						if($parent.getChildAt(i) == $child)
						{
							tmpResult = true;
							break;
						}else if($parent.getChildAt(i) is DisplayObjectContainer)
						{
							tmpResult = checkNode(DisplayObjectContainer($parent.getChildAt(i)),$child);
							if(tmpResult == true)
							{
								break;
							}
						}
					}
				}
				return tmpResult;
			}
			
			return checkNode(parent,child)
		}
	}
}