package flower.display
{
	/**
	 * 显示对象标志位
	 */
	public class DisplayObjectFlag
	{
		/**尺寸已经失效**/
		public static const SIZE:int = 1;
		
		/**本地文字内容失效**/
		public static const NATIVE_TEXT:int = 2;
		
		/**容器类，子对象顺序失效**/
		public static const DISPLAYOBJECT_CONTAINER_INDEX:int = 3;
		
		/**Component 位置失效**/
		public static const COMPONENT_POSITION:int = 10;
	}
}