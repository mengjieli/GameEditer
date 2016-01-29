package egret.ui.core.FTEText.history
{
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import egret.ui.core.FTEText.core.IFTEText;
	import egret.ui.events.FTETextEvent;
	
	/**
	 * 历史管理行为(将备忘录中负责人和发起人简化之后合并在了这里)
	 * @author featherJ
	 * 
	 */	
	public class HistoryBehavior
	{
		private var _textArea:IFTEText;
		public function HistoryBehavior()
		{
			
		}
		public function init(textArea:IFTEText):void
		{
			_textArea = textArea;
			_textArea.addEventListener(FTETextEvent.FTE_TEXT_CHANGED,textChangeHandler);
		}
		
		protected function textChangeHandler(event:FTETextEvent):void
		{
			if(!event.createHistory) return;
			if(event.beforeStart == event.beforeEnd && event.afterStart == event.afterEnd && event.beforeStr == "" && event.afterStr == "")
			{
				return;
			}
			var memento:Memento = new Memento();
			memento.beforeStartIndex = event.beforeStart;
			memento.beforeEndIndex = event.beforeEnd;
			memento.beforeStr = event.beforeStr;
			memento.afterStartIndex = event.afterStart;
			memento.afterEndIndex = event.afterEnd;
			memento.afterStr = event.afterStr;
			_newMementoList.push(memento);
			
			if(memento.beforeStartIndex != memento.beforeEndIndex)
			{
				createHistory();
			}else if(memento.afterStr.length == 1 && 
				(memento.afterStr == " " || memento.afterStr.charCodeAt(0) == 9 || memento.afterStr == "\r" || memento.afterStr == "\n"))
			{
				createHistory();
			}else if(memento.afterStr.length>1)
			{
				createHistory();
			}
		}
		
		private var createIndex:int = -1;
		private function createHistory(direct:Boolean = false):void
		{
			if(direct)
			{
				if(createIndex != -1)
					clearTimeout(createIndex);
				createHistoryHandler();
			}else
			{
				if(createIndex != -1)
					clearTimeout(createIndex);
				createIndex = setTimeout(createHistoryHandler,200);
			}
		}
		
		
		private var _newMementoList:Array = [];
		//将最近操作的动作列表，尽可能合并，然后将合并的动作分别存入记录里
		private function createHistoryHandler():void
		{
			var mementos:Vector.<Memento> = new Vector.<Memento>();
			if(_newMementoList.length>0)
			{
				if(_currentIndex < _mementoList.length)
				{
					_mementoList.length = _currentIndex;
				}
				
				var newMenento:Memento;
				for(var i:int =0;i<_newMementoList.length;i++)
				{
					var memento:Memento = _newMementoList[i];
					if(i == 0 && _newMementoList.length == 1)
					{
						newMenento = new Memento();
						newMenento.beforeStartIndex = memento.beforeStartIndex;
						newMenento.beforeEndIndex = memento.beforeEndIndex;
						newMenento.beforeStr = memento.beforeStr;
						newMenento.afterStartIndex = memento.afterStartIndex;
						newMenento.afterEndIndex = memento.afterEndIndex;
						newMenento.afterStr = memento.afterStr;
						mementos.push(newMenento);
					}else if(i == 0)
					{
						newMenento = new Memento();
						newMenento.beforeStartIndex = memento.beforeStartIndex;
						newMenento.beforeEndIndex = memento.beforeEndIndex;
						newMenento.beforeStr = memento.beforeStr;
						newMenento.afterStartIndex = memento.afterStartIndex;
						newMenento.afterEndIndex = memento.afterEndIndex;
						newMenento.afterStr = memento.afterStr;
					}else if(i< _newMementoList.length-1)
					{
						var pMemento:Memento = _newMementoList[i-1];
						if(memento.afterStr.length == 1 && memento.beforeStartIndex == memento.beforeEndIndex && memento.beforeEndIndex  == pMemento.afterEndIndex)
						{
							newMenento.afterEndIndex++;
							newMenento.afterStr += memento.afterStr;
						}else
						{
							mementos.push(newMenento);
							newMenento = new Memento();
							newMenento.beforeStartIndex = memento.beforeStartIndex;
							newMenento.beforeEndIndex = memento.beforeEndIndex;
							newMenento.beforeStr = memento.beforeStr;
							newMenento.afterStartIndex = memento.afterStartIndex;
							newMenento.afterEndIndex = memento.afterEndIndex;
							newMenento.afterStr = memento.afterStr;
						}
					}else if(i == _newMementoList.length-1)
					{
						pMemento = _newMementoList[i-1];
						if(memento.afterStr.length == 1 && memento.beforeStartIndex == memento.beforeEndIndex && memento.beforeEndIndex  == pMemento.afterEndIndex)
						{
							newMenento.afterEndIndex++;
							newMenento.afterStr += memento.afterStr;
							mementos.push(newMenento);
						}else
						{
							mementos.push(newMenento);
							newMenento = new Memento();
							newMenento.beforeStartIndex = memento.beforeStartIndex;
							newMenento.beforeEndIndex = memento.beforeEndIndex;
							newMenento.beforeStr = memento.beforeStr;
							newMenento.afterStartIndex = memento.afterStartIndex;
							newMenento.afterEndIndex = memento.afterEndIndex;
							newMenento.afterStr = memento.afterStr;
							mementos.push(newMenento);
						}
					}
				}
				_mementoList.push(mementos);
				_currentIndex = _mementoList.length;
			}
			_newMementoList = [];
		}
		
		private var _currentIndex:int = 0;
		private var _mementoList:Vector.<Vector.<Memento>> = new Vector.<Vector.<Memento>>();
		private var selectTimeoutIndex:int = -1;
		/**
		 * 撤销 
		 * 
		 */		
		public function undo():void
		{
			createHistory(true)
			if(canUndo())
			{
				_currentIndex--;
				var mementos:Vector.<Memento> = _mementoList[_currentIndex];
				for(var i:int = mementos.length-1;i>=0;i--)
				{
					_textArea.replaceText(mementos[i].afterStartIndex,mementos[i].afterEndIndex,mementos[i].beforeStr,false,false);
				}
			}
		}
		/**
		 * 恢复 
		 * 
		 */		
		public function redo():void
		{
			createHistory(true)
			if(canRedo())
			{
				var mementos:Vector.<Memento> = _mementoList[_currentIndex];
				for(var i:int = 0;i<mementos.length;i++)
				{
					_textArea.replaceText(mementos[i].beforeStartIndex,mementos[i].beforeEndIndex,mementos[i].afterStr,false,false);
				}
				_currentIndex++;
			}
		}
		/**
		 * 是否能撤销 
		 * @return 
		 * 
		 */		
		public function canUndo():Boolean
		{
			return _currentIndex>0
		}
		/**
		 * 是否能恢复 
		 * @return 
		 * 
		 */		
		public function canRedo():Boolean
		{
			return _currentIndex<_mementoList.length;
		}
		
		/**
		 * 清空历史记录 
		 */		
		public function clean():void
		{
			_currentIndex = 0;
			_mementoList.length = 0;
			_newMementoList = [];
		}
	}
}