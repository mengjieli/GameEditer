package egret.components
{
	import flash.display.DisplayObject;
	import flash.events.EventDispatcher;
	
	import egret.components.supportClasses.SkinBasicLayout;
	import egret.core.IContainer;
	import egret.core.ISkin;
	import egret.core.IStateClient;
	import egret.core.IVisualElement;
	import egret.core.IVisualElementContainer;
	import egret.core.UIGlobals;
	import egret.core.ns_egret;
	import egret.effects.CompositeEffect;
	import egret.effects.IEffect;
	import egret.events.EffectEvent;
	import egret.events.ElementExistenceEvent;
	import egret.events.StateChangeEvent;
	import egret.states.InterruptionBehavior;
	import egret.states.State;
	import egret.states.Transition;
	
	use namespace ns_egret;
	
	/**
	 * 元素添加事件
	 */	
	[Event(name="elementAdd", type="egret.events.ElementExistenceEvent")]
	/**
	 * 元素移除事件 
	 */	
	[Event(name="elementRemove", type="egret.events.ElementExistenceEvent")]
	
	/**
	 * 当前视图状态已经改变 
	 */	
	[Event(name="currentStateChange", type="egret.events.StateChangeEvent")]
	/**
	 * 当前视图状态即将改变 
	 */	
	[Event(name="currentStateChanging", type="egret.events.StateChangeEvent")]
	
	[EXML(show="false")]
	
	[DefaultProperty(name="elementsContent",array="true")]
	
	/**
	 * 含有视图状态功能的皮肤基类。注意：为了减少嵌套层级，此皮肤没有继承显示对象，若需要显示对象版本皮肤，请使用Skin。
	 * @see egret.components.supportClasses.Skin
	 * @author dom
	 */
	public class Skin extends EventDispatcher 
		implements IStateClient, ISkin, IContainer
	{
		
		public static const DEFAULT_MAX_WIDTH:Number = 10000;
		public static const DEFAULT_MAX_HEIGHT:Number = 10000;
		
		/**
		 * 构造函数
		 */		
		public function Skin()
		{
			super();
			this.skinLayout = new SkinBasicLayout();
			this.skinLayout.target = this;
		}
		
		
		private var _minWidth:Number = 0;
		/**
		 * @inheritDoc
		 */
		public function get minWidth():Number
		{
			if(UIGlobals.getForEgret(this))
			{
				return _minWidth;
			}else
			{
				if (!isNaN(explicitMinWidth))
					return explicitMinWidth;
				return measuredMinWidth;
			}
		}
		public function set minWidth(value:Number):void
		{
			if(UIGlobals.getForEgret(this))
			{
				_minWidth = value;
			}else
			{
				if (explicitMinWidth == value)
					return;
				explicitMinWidth = value;
			}
		}
		
		private var _maxWidth:Number = 10000;
		/**
		 * @inheritDoc
		 */
		public function get maxWidth():Number
		{
			if(UIGlobals.getForEgret(this))
			{
				return _maxWidth;
			}else
			{
				return !isNaN(explicitMaxWidth) ?
					explicitMaxWidth :
					DEFAULT_MAX_WIDTH;
			}
		}
		public function set maxWidth(value:Number):void
		{
			if(UIGlobals.getForEgret(this))
			{
				_maxWidth = value;
			}else
			{
				if (explicitMaxWidth == value)
					return;
				explicitMaxWidth = value;
			}
		}
		
		private var _minHeight:Number = 0;
		/**
		 * @inheritDoc
		 */
		public function get minHeight():Number
		{
			if(UIGlobals.getForEgret(this))
			{
				return _minHeight;
			}else
			{
				if (!isNaN(explicitMinHeight))
					return explicitMinHeight;
				return measuredMinHeight;
			}
		}
		public function set minHeight(value:Number):void
		{
			if(UIGlobals.getForEgret(this))
			{
				_minHeight = value;
			}else
			{
				if (explicitMinHeight == value)
					return;
				explicitMinHeight = value;
			}
		}
		
		private var _maxHeight:Number = 10000;
		/**
		 * @inheritDoc
		 */
		public function get maxHeight():Number
		{
			if(UIGlobals.getForEgret(this))
			{
				return _maxHeight;
			}else
			{
				return !isNaN(explicitMaxHeight) ?
					explicitMaxHeight :
					DEFAULT_MAX_HEIGHT;
			}
		}
		public function set maxHeight(value:Number):void
		{
			if(UIGlobals.getForEgret(this))
			{
				_maxHeight = value;
			}else
			{
				if (explicitMaxHeight == value)
					return;
				explicitMaxHeight = value;
			}
		}
		
		/**
		 * Exml预览时生成的id列表
		 */		
		ns_egret var idMap:Object;
		
		public var _hasWidthSet:Boolean = false;
		public var _width:Number = NaN;
		/**
		 * 组件宽度,默认值为NaN,设置为NaN将使用组件的measure()方法自动计算尺寸
		 */
		public function get width():Number
		{
			return this._width;
		}
		public function set width(value:Number):void
		{
			if(this._width==value)
				return;
			this._width = value;
			this._hasWidthSet = !isNaN(value);
		}
		
		public var _hasHeightSet:Boolean = false;
		
		public var _height:Number = NaN;
		/**
		 * 组件高度,默认值为NaN,设置为NaN将使用组件的measure()方法自动计算尺寸
		 */
		public function get height():Number
		{
			return this._height;
		}
		public function set height(value:Number):void
		{
			if (this._height == value)
				return;
			this._height = value;
			this._hasHeightSet = !isNaN(value);
		}
		
		/**
		 * 组件的默认宽度（以像素为单位）。此值由 measure() 方法设置。
		 */
		public var measuredWidth:Number = 0;
		
		/**
		 * 组件的默认高度（以像素为单位）。此值由 measure() 方法设置。
		 */
		public var measuredHeight:Number = 0;
		
		public function get preferredWidth():Number
		{
			return this._hasWidthSet ? this._width:this.measuredWidth;
		}
		
		public function get preferredHeight():Number
		{
			return this._hasHeightSet ? this._height:this.measuredHeight;
		}
		
		private var initialized:Boolean = false;
		/**
		 * 创建子项,子类覆盖此方法以完成组件子项的初始化操作，
		 * 请务必调用super.createChildren()以完成父类组件的初始化
		 */
		protected function createChildren():void{
			
		}
		
		private var _hostComponent:SkinnableComponent;
		/**
		 * @inheritDoc
		 */
		public function get hostComponent():SkinnableComponent
		{
			return _hostComponent;
		}
		/**
		 * @inheritDoc
		 */
		public function set hostComponent(value:SkinnableComponent):void
		{
			if(_hostComponent==value)
				return;
			
			var i:int;
			if(_hostComponent)
			{
				for(i = _elementsContent.length - 1; i >= 0; i--)
				{
					elementRemoved(_elementsContent[i], i);
				}
			}
			
			_hostComponent = value;
			
			if(!initialized){
				initialized = true;
				createChildren();
			}
			
			if(_hostComponent)
			{			
				var n:int = _elementsContent.length;
				for (i = 0; i < n; i++)
				{   
					elementAdded(_elementsContent[i], i);
				}
				
				initializeStates();
				
				if(currentStateChanged)
				{
					commitCurrentState();
				}
			}
		}
		
		private var _elementsContent:Array = [];
		/**
		 * 返回子元素列表
		 */		
		ns_egret function getElementsContent():Array
		{
			return _elementsContent;
		}
		
		/**
		 * 设置容器子对象数组 。数组包含要添加到容器的子项列表，之前的已存在于容器中的子项列表被全部移除后添加列表里的每一项到容器。
		 * 设置该属性时会对您输入的数组进行一次浅复制操作，所以您之后对该数组的操作不会影响到添加到容器的子项列表数量。
		 */		
		public function set elementsContent(value:Array):void
		{
			if(value==null)
				value = [];
			if(value==_elementsContent)
				return;
			if(_hostComponent)
			{
				var i:int;
				for (i = _elementsContent.length - 1; i >= 0; i--)
				{
					elementRemoved(_elementsContent[i], i);
				}
				
				_elementsContent = value.concat();
				
				var n:int = _elementsContent.length;
				for (i = 0; i < n; i++)
				{   
					var elt:IVisualElement = _elementsContent[i];
					
					if(elt.parent is IVisualElementContainer)
						IVisualElementContainer(elt.parent).removeElement(elt);
					else if(elt.owner is IContainer)
						IContainer(elt.owner).removeElement(elt);
					elementAdded(elt, i);
				}
			}
			else
			{
				_elementsContent = value.concat();
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function get numElements():int
		{
			return _elementsContent.length;
		}
		
		/**
		 * @inheritDoc
		 */
		public function getElementAt(index:int):IVisualElement
		{
			checkForRangeError(index);
			return _elementsContent[index];
		}
		
		private function checkForRangeError(index:int, addingElement:Boolean = false):void
		{
			var maxIndex:int = _elementsContent.length - 1;
			
			if (addingElement)
				maxIndex++;
			
			if (index < 0 || index > maxIndex)
				throw new RangeError("索引:\""+index+"\"超出可视元素索引范围");
		}
		/**
		 * @inheritDoc
		 */
		public function addElement(element:IVisualElement):IVisualElement
		{
			var index:int = numElements;
			
			if (element.owner == this)
				index = numElements-1;
			
			return addElementAt(element, index);
		}
		/**
		 * @inheritDoc
		 */
		public function addElementAt(element:IVisualElement, index:int):IVisualElement
		{
			checkForRangeError(index, true);
			
			var host:Object = element.owner; 
			if (host == this)
			{
				setElementIndex(element, index);
				return element;
			}
			else if(host is IContainer)
			{
				IContainer(host).removeElement(element);
			}
			
			_elementsContent.splice(index, 0, element);
			
			if(_hostComponent)
				elementAdded(element, index);
			else
				element.ownerChanged(this);
			
			return element;
		}
		/**
		 * @inheritDoc
		 */
		public function removeElement(element:IVisualElement):IVisualElement
		{
			return removeElementAt(getElementIndex(element));
		}
		/**
		 * @inheritDoc
		 */
		public function removeElementAt(index:int):IVisualElement
		{
			checkForRangeError(index);
			
			var element:IVisualElement = _elementsContent[index];
			
			if(_hostComponent)
				elementRemoved(element, index);
			else
				element.ownerChanged(null);
			
			_elementsContent.splice(index, 1);
			
			return element;
		}
		
		/**
		 * @inheritDoc
		 */
		public function getElementIndex(element:IVisualElement):int
		{
			return _elementsContent.indexOf(element);
		}
		/**
		 * @inheritDoc
		 */
		public function setElementIndex(element:IVisualElement, index:int):void
		{
			checkForRangeError(index);
			
			var oldIndex:int = getElementIndex(element);
			if (oldIndex==-1||oldIndex == index)
				return;
			
			if(_hostComponent)
				elementRemoved(element, oldIndex, false);
			
			_elementsContent.splice(oldIndex, 1);
			_elementsContent.splice(index, 0, element);
			
			if(_hostComponent)
				elementAdded(element, index, false);
		}
		
		private var addToDisplayListAt:QName = new QName(ns_egret,"addToDisplayListAt");
		private var removeFromDisplayList:QName = new QName(ns_egret,"removeFromDisplayList");
		/**
		 * 添加一个显示元素到容器
		 */		
		ns_egret function elementAdded(element:IVisualElement, index:int, notifyListeners:Boolean = true):void
		{
			element.ownerChanged(this);
			if(element is DisplayObject)
				_hostComponent[addToDisplayListAt](DisplayObject(element), index);
			
			if (notifyListeners)
			{
				if (hasEventListener(ElementExistenceEvent.ELEMENT_ADD))
					dispatchEvent(new ElementExistenceEvent(
						ElementExistenceEvent.ELEMENT_ADD, false, false, element, index));
			}
			
			_hostComponent.invalidateSize();
			_hostComponent.invalidateDisplayList();
		}
		/**
		 * 从容器移除一个显示元素
		 */		
		ns_egret function elementRemoved(element:IVisualElement, index:int, notifyListeners:Boolean = true):void
		{
			if (notifyListeners)
			{        
				if (hasEventListener(ElementExistenceEvent.ELEMENT_REMOVE))
					dispatchEvent(new ElementExistenceEvent(
						ElementExistenceEvent.ELEMENT_REMOVE, false, false, element, index));
			}
			
			var childDO:DisplayObject = element as DisplayObject; 
			if (childDO && childDO.parent == _hostComponent)
			{
				_hostComponent[removeFromDisplayList](element);
			}
			
			element.ownerChanged(null);
			_hostComponent.invalidateSize();
			_hostComponent.invalidateDisplayList();
		}
		
		private var skinLayout:SkinBasicLayout;
		/**
		 * 测量组件尺寸
		 */
		public function measure():void
		{
			this.skinLayout.measure();
			if(this.measuredWidth<this.minWidth)
			{
				this.measuredWidth = this.minWidth;
			}
			if(this.measuredWidth>this.maxWidth)
			{
				this.measuredWidth = this.maxWidth;
			}
			if(this.measuredHeight<this.minHeight)
			{
				this.measuredHeight = this.minHeight;
			}
			if(this.measuredHeight>this.maxHeight)
			{
				this.measuredHeight = this.maxHeight
			}
		}
		
		/**
		 * 更新显示列表
		 */
		public function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			this.skinLayout.updateDisplayList(unscaledWidth,unscaledHeight);
		}
		
		//========================state相关函数===============start=========================
		
		private var _states:Array = [];
		/**
		 * @inheritDoc
		 */
		public function get states():Array
		{
			return _states;
		}
		
		public function set states(value:Array):void
		{
			if(!value)
				value = [];
			if(value[0] is String)
			{
				var length:int = value.length;
				for(var i:int=0;i<length;i++)
				{
					var state:State = new State();
					state.name = value[i];
					value[i] = state;
				}
			}
			_states = value;
			currentStateChanged = true;
			requestedCurrentState = _currentState;
			if(!hasState(requestedCurrentState))
			{
				requestedCurrentState = getDefaultState();
			}
		}
		
		/**
		 * 当前的过渡效果
		 */
		private var _currentTransition:Transition;
		
		private var _transitions:Array;
		
		/**
		 *  一个 Transition 对象 Array，其中的每个 Transition 对象都定义一组效果，
		 * 用于在视图状态发生更改时播放。
		 */
		public function get transitions():Array
		{
			return _transitions;
		}
		
		public function set transitions(value:Array):void
		{
			_transitions = value;
		}
		
		/**
		 * 当前视图状态发生改变的标志
		 */
		private var currentStateChanged:Boolean;
		
		/**
		 * 播放过渡效果的标志
		 */
		private var playStateTransition:Boolean = true;
		private var transitionFromState:String;
		private var transitionToState:String;
		
		private var _currentState:String;
		/**
		 * 存储还未验证的视图状态 
		 */		
		private var requestedCurrentState:String;
		/**
		/**
		 * @inheritDoc
		 */
		public function get currentState():String
		{
			if(currentStateChanged)
				return requestedCurrentState;
			return _currentState?_currentState:getDefaultState();
		}
		
		public function set currentState(value:String):void
		{
			if(!value)
				value = getDefaultState();
			if (value != currentState &&value&&currentState)
			{
				requestedCurrentState = value;
				currentStateChanged = true;
				if (_hostComponent)
				{
					commitCurrentState();
				}
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function hasState(stateName:String):Boolean
		{
			return (getState(stateName) != null); 
		}
		
		/**
		 * 返回默认状态
		 */		
		private function getDefaultState():String
		{
			if(_states&&_states.length>0)
			{
				return _states[0].name;
			}
			return null;
		}
		/**
		 * 应用当前的视图状态,子类复写此方法来刷新视图状态
		 */
		protected function commitCurrentState():void
		{
			if(!currentStateChanged)
				return;
			currentStateChanged = false;
			var destination:State = getState(requestedCurrentState);
			if(!destination)
			{
				requestedCurrentState = getDefaultState();
			}
			
			var nextTransition:Transition;
			if(playStateTransition)
			{
				nextTransition = getTransition(_currentState, requestedCurrentState);
			}
			
			var prevTransitionFraction:Number;
			var prevTransitionEffect:IEffect;
			
			if (_currentTransition)
			{
				_currentTransition.effect.removeEventListener(EffectEvent.EFFECT_END, transition_effectEndHandler);
				
				if (nextTransition && _currentTransition.interruptionBehavior == InterruptionBehavior.STOP)
				{
					prevTransitionEffect = _currentTransition.effect;
					prevTransitionEffect.stop();
				}
				else
				{
					if (_currentTransition.autoReverse &&
						transitionFromState == requestedCurrentState &&
						transitionToState == _currentState)
					{
						if (_currentTransition.effect.duration == 0)
							prevTransitionFraction = 0;
						else
							prevTransitionFraction = 
								_currentTransition.effect.playheadTime /
								getTotalDuration(_currentTransition.effect);
					}
					_currentTransition.effect.end();
				}
				_currentTransition = null;
			}
			
			var event:StateChangeEvent;
			var oldState:String = _currentState ? _currentState : "";
			if (hasEventListener(StateChangeEvent.CURRENT_STATE_CHANGING)) 
			{
				event = new StateChangeEvent(StateChangeEvent.CURRENT_STATE_CHANGING);
				event.oldState = oldState;
				event.newState = requestedCurrentState ? requestedCurrentState : "";
				dispatchEvent(event);
			}
			
			removeState(_currentState);
			_currentState = requestedCurrentState;
			
			if (_currentState) 
			{
				applyState(_currentState);
			}
			
			if (hasEventListener(StateChangeEvent.CURRENT_STATE_CHANGE))
			{
				event = new StateChangeEvent(StateChangeEvent.CURRENT_STATE_CHANGE);
				event.oldState = oldState;
				event.newState = _currentState ? _currentState : "";
				dispatchEvent(event);
			}
			
			if (nextTransition)
			{
				var reverseTransition:Boolean =  
					nextTransition && nextTransition.autoReverse &&
					(nextTransition.toState == oldState ||
						nextTransition.fromState == _currentState);
				UIGlobals.layoutManager.validateNow();
				_currentTransition = nextTransition;
				transitionFromState = oldState;
				transitionToState = _currentState;
				
				nextTransition.effect.addEventListener(EffectEvent.EFFECT_END, transition_effectEndHandler);
				nextTransition.effect.play(null, reverseTransition);
				if (!isNaN(prevTransitionFraction) && nextTransition.effect.duration != 0)
				{
					nextTransition.effect.playheadTime = (1 - prevTransitionFraction) * getTotalDuration(nextTransition.effect);
				}
			}
			else
			{
				if (hasEventListener(StateChangeEvent.STATE_CHANGE_COMPLETE))
					dispatchEvent(new StateChangeEvent(StateChangeEvent.STATE_CHANGE_COMPLETE));
			}
		}
		
		private function transition_effectEndHandler(event:EffectEvent):void
		{
			_currentTransition = null;
			if (hasEventListener(StateChangeEvent.STATE_CHANGE_COMPLETE))
				dispatchEvent(new StateChangeEvent(StateChangeEvent.STATE_CHANGE_COMPLETE));
		}
		
		/**
		 * 通过名称返回视图状态
		 */		
		private function getState(stateName:String):State
		{
			if (!stateName)
				return null;
			
			var length:int = _states.length;
			for (var i:int = 0; i < length; i++)
			{
				var state:State = _states[i];
				if (state.name == stateName)
					return state;
			}
			return null;
		}
		
		/**
		 * 移除指定的视图状态以及所依赖的所有父级状态，除了与新状态的共同状态外
		 */		
		private function removeState(stateName:String):void
		{
			var state:State = getState(stateName);
			
			if (state)
			{
				state.dispatchExitState();
				
				var overrides:Array = state.overrides;
				
				for (var i:int = overrides.length-1; i>=0; i--)
					overrides[i].remove(this);
			}
		}
		
		/**
		 * 应用新状态
		 */
		private function applyState(stateName:String):void
		{
			var state:State = getState(stateName);
			
			if (state)
			{
				var overrides:Array = state.overrides;
				var length:int = overrides.length;
				for (var i:int = 0; i < length; i++)
					overrides[i].apply(this);
				
				state.dispatchEnterState();
			}
		}
		
		private var stateInitialized:Boolean = false;
		/**
		 * 初始化所有视图状态
		 */
		private function initializeStates():void
		{
			if(stateInitialized)
				return;
			stateInitialized = true;
			for (var i:int = 0; i < _states.length; i++)
			{
				var state:State = _states[i] as State;
				state.initialize(this);
			}
		}
		
		/**
		 *  获取两个状态之间的过渡
		 */
		private function getTransition(oldState:String, newState:String):Transition
		{
			var result:Transition = null;
			var priority:int = 0;
			if (!transitions)
				return null;
			
			if (!oldState)
				oldState = "";
			
			if (!newState)
				newState = "";
			
			for (var i:int = 0; i < transitions.length; i++)
			{
				var t:Transition = transitions[i];
				
				if (t.fromState == "*" && t.toState == "*" && priority < 1)
				{
					result = t;
					priority = 1;
				}
				else if (t.toState == oldState && t.fromState == "*" && t.autoReverse && priority < 2)
				{
					result = t;
					priority = 2;
				}
				else if (t.toState == "*" && t.fromState == newState && t.autoReverse && priority < 3)
				{
					result = t;
					priority = 3;
				}
				else if (t.toState == oldState && t.fromState == newState && t.autoReverse && priority < 4)
				{
					result = t;
					priority = 4;
				}
				else if (t.fromState == oldState && t.toState == "*" && priority < 5)
				{
					result = t;
					priority = 5;
				}
				else if (t.fromState == "*" && t.toState == newState && priority < 6)
				{
					result = t;
					priority = 6;
				}
				else if (t.fromState == oldState && t.toState == newState && priority < 7)
				{
					result = t;
					priority = 7;
					break;
				}
			}
			
			if (result && !result.effect)
				result = null;
			return result;
		}
		
		/**
		 * 效果的总持续时间
		 */
		private function getTotalDuration(effect:IEffect):Number
		{
			var duration:Number = 0;
			var effectObj:Object = Object(effect);
			if (effect is CompositeEffect)
				duration = effectObj.compositeDuration;
			else
				duration = effect.duration;
			var repeatDelay:int = ("repeatDelay" in effect) ?
				effectObj.repeatDelay : 0;
			var repeatCount:int = ("repeatCount" in effect) ?
				effectObj.repeatCount : 0;
			var startDelay:int = ("startDelay" in effect) ?
				effectObj.startDelay : 0;
			
			duration = duration * repeatCount +
				(repeatDelay * (repeatCount - 1)) +
				startDelay;
			return duration;
		}
		
		ns_egret var _explicitMinWidth:Number;
		public function get explicitMinWidth():Number
		{
			return _explicitMinWidth;
		}
		public function set explicitMinWidth(value:Number):void
		{
			if (_explicitMinWidth == value)
				return;
			_explicitMinWidth = value;
		}
		
		ns_egret var _explicitMinHeight:Number;
		public function get explicitMinHeight():Number
		{
			return _explicitMinHeight;
		}
		public function set explicitMinHeight(value:Number):void
		{
			if (_explicitMinHeight == value)
				return;
			_explicitMinHeight = value;
		}
		
		ns_egret var _explicitMaxWidth:Number;
		public function get explicitMaxWidth():Number
		{
			return _explicitMaxWidth;
		}
		public function set explicitMaxWidth(value:Number):void
		{
			if (_explicitMaxWidth == value)
				return;
			
			_explicitMaxWidth = value;
		}
		
		ns_egret var _explicitMaxHeight:Number;
		public function get explicitMaxHeight():Number
		{
			return _explicitMaxHeight;
		}
		public function set explicitMaxHeight(value:Number):void
		{
			if (_explicitMaxHeight == value)
				return;
			
			_explicitMaxHeight = value;
		}
		
		private var _measuredMinWidth:Number = 0;
		/**
		 * 组件的默认最小宽度（以像素为单位）。此值由 measure() 方法设置。
		 */		
		public function get measuredMinWidth():Number
		{
			return _measuredMinWidth;
		}
		public function set measuredMinWidth(value:Number):void
		{
			_measuredMinWidth = value;
		}
		
		private var _measuredMinHeight:Number = 0;
		/**
		 * 组件的默认最小高度（以像素为单位）。此值由 measure() 方法设置。
		 */	
		public function get measuredMinHeight():Number
		{
			return _measuredMinHeight;
		}
		public function set measuredMinHeight(value:Number):void
		{
			_measuredMinHeight = value;
		}
	}
}