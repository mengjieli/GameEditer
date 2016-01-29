package egret.utils
{
	import flash.display.Screen;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	/**
	 * 显示器工具 
	 * @author 雷羽佳
	 * 
	 */	
	public class ScreensUtil
	{
		public function ScreensUtil()
		{
			
		}
		
		/**
		 * 检测某一点是否在屏幕尺寸内，如果有多个显示器，只要该点在任意一个显示器尺寸内返回的均为true 
		 * 
		 */		
		public static function checkPointInScreens(pos:Point):Boolean
		{
			var result:Boolean = false;
			try//之所以要加try，是因为显示器在虚拟机之外，有可能在循环还没结束的时候拔掉了一个显示器，导致报错
			{
				for(var i:int = 0;i<Screen.screens.length;i++)
				{
					var screenBounds:Rectangle = Screen.screens[i].visibleBounds;
					if(pos.x >= screenBounds.x && pos.x <= screenBounds.x + screenBounds.width &&
						pos.y >= screenBounds.y && pos.y <= screenBounds.y + screenBounds.height)
					{
						result = true;
						break;
					}
				}
			} 
			catch(error:Error) 
			{
				
			}
			return result;
		}
		
		/**
		 * 检测某矩形是否在屏幕尺寸内，如果有多个显示器，只要该点在任意一个显示器尺寸内返回的均为true  
		 * @param rect
		 * @return 
		 * 
		 */		
		public static function checkRectInScreens(rect:Rectangle):Boolean
		{
			var result:Boolean = false;
			try//之所以要加try，是因为显示器在虚拟机之外，有可能在循环还没结束的时候拔掉了一个显示器，导致报错
			{
				for(var i:int = 0;i<Screen.screens.length;i++)
				{
					var screenBounds:Rectangle = Screen.screens[i].visibleBounds;
					if(rect.x >= screenBounds.x && rect.x+rect.width <= screenBounds.x + screenBounds.width &&
						rect.y >= screenBounds.y && rect.y+rect.height <= screenBounds.y + screenBounds.height)
					{
						result = true;
						break;
					}
				}
			} 
			catch(error:Error) 
			{
				
			}
			return result;
		}
		
		/**
		 * 基于目标矩形中的一个基本矩形来修复该目标矩形在屏幕中的位置
		 * @param target
		 * @param base
		 * @return 
		 * 
		 */		
		public static function fixRectInScreens(target:Rectangle,base:Rectangle):Rectangle
		{
			var globalBaseRect:Rectangle = new Rectangle(base.x,base.y,base.width,base.height);
			globalBaseRect.x += target.x;
			globalBaseRect.y += target.y;
			if(!checkRectInScreens(globalBaseRect))
			{
				//像左调整
				if(globalBaseRect.x > Screen.mainScreen.visibleBounds.x +  Screen.mainScreen.visibleBounds.width)
				{
					target.x = Screen.mainScreen.visibleBounds.x+Screen.mainScreen.visibleBounds.width-globalBaseRect.width;
				}
				//向上调整
				if(globalBaseRect.y > Screen.mainScreen.visibleBounds.y +  Screen.mainScreen.visibleBounds.height)
				{
					target.y = Screen.mainScreen.visibleBounds.y +  Screen.mainScreen.visibleBounds.height-globalBaseRect.height;
				}
				//向右调整
				if(globalBaseRect.x+globalBaseRect.width < Screen.mainScreen.visibleBounds.x)
				{
					target.x = 0;
				}
				//向下调整
				if(globalBaseRect.y+globalBaseRect.height < Screen.mainScreen.visibleBounds.y)
				{
					target.y = 0;
				}
			}
			return target
		}
		
		/**
		 * 基于目标矩形中的一个基本矩形来修复该目标矩形在屏幕中的位置
		 * @param target
		 * @param base
		 * @return 
		 * 
		 */		
		public static function fixRectInScreensWithTargetScreen(target:Rectangle,base:Rectangle,screen:Screen):Rectangle
		{
			var globalBaseRect:Rectangle = new Rectangle(base.x,base.y,base.width,base.height);
			globalBaseRect.x += target.x;
			globalBaseRect.y += target.y;
			if(!checkRectInScreens(globalBaseRect))
			{
				//像左调整
				if(globalBaseRect.x+globalBaseRect.width > screen.visibleBounds.x +  screen.visibleBounds.width)
				{
					target.x = screen.visibleBounds.x+screen.visibleBounds.width-globalBaseRect.width;
				}
				//向上调整
				if(globalBaseRect.y+globalBaseRect.height > screen.visibleBounds.y +  screen.visibleBounds.height)
				{
					target.y = screen.visibleBounds.y +  screen.visibleBounds.height-globalBaseRect.height;
				}
				//向右调整
				if(globalBaseRect.x < screen.visibleBounds.x)
				{
					target.x = screen.visibleBounds.x;
				}
				//向下调整
				if(globalBaseRect.y < screen.visibleBounds.y)
				{
					target.y = screen.visibleBounds.y;
				}
			}
			return target
		}
		
		public static function getScreenByGlobalPos(pos:Point):Screen
		{
			var result:Screen;
			try//之所以要加try，是因为显示器在虚拟机之外，有可能在循环还没结束的时候拔掉了一个显示器，导致报错
			{
				for(var i:int = 0;i<Screen.screens.length;i++)
				{
					
					var screenBounds:Rectangle = Screen.screens[i].visibleBounds;
					if(pos.x >= screenBounds.x && pos.x <= screenBounds.x + screenBounds.width &&
						pos.y >= screenBounds.y && pos.y <= screenBounds.y + screenBounds.height)
					{
						result = Screen.screens[i];
						break;
					}
				}
			} 
			catch(error:Error) 
			{
				
			}
			return result;
		}
		
		public static function getScreenByCloseGlobalPos(pos:Point):Screen
		{
			var result:Screen;
			try//之所以要加try，是因为显示器在虚拟机之外，有可能在循环还没结束的时候拔掉了一个显示器，导致报错
			{
				var minDist:Number = NaN;
				for(var i:int = 0;i<Screen.screens.length;i++)
				{
					var screenBounds:Rectangle = Screen.screens[i].visibleBounds;
					var dist:Number = getDist(pos.x,pos.y,screenBounds.x,screenBounds.y);
					if(isNaN(minDist))
					{
						minDist = dist;
						result = Screen.screens[i];
					}
					
					if(dist < minDist)
					{
						minDist = dist;
						result = Screen.screens[i];	
					}
						
					dist = getDist(pos.x,pos.y,screenBounds.x+screenBounds.width,screenBounds.y);
					if(dist < minDist)
					{
						minDist = dist;
						result = Screen.screens[i];	
					}
					
					dist = getDist(pos.x,pos.y,screenBounds.x,screenBounds.y+screenBounds.height);
					if(dist < minDist)
					{
						minDist = dist;
						result = Screen.screens[i];	
					}
					
					dist = getDist(pos.x,pos.y,screenBounds.x+screenBounds.width,screenBounds.y+screenBounds.height);
					if(dist < minDist)
					{
						minDist = dist;
						result = Screen.screens[i];	
					}
				}
			} 
			catch(error:Error) 
			{
				
			}
			return result;
		}
		
		private static function getDist(x1:Number,y1:Number,x2:Number,y2:Number):Number
		{
			return Math.sqrt((x1-x2)*(x1-x2)+(y1-y2)*(y1-y2)) 
		}
	}
}