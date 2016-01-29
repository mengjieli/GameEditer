package egret.states
{
	import egret.effects.IEffect;

	/**
	 * Transition 类定义了一组在响应视图状态更改时播放的效果。
	 * 视图状态的定义定义了如何更改状态，
	 * 而过渡则定义了在状态更改过程中可视更改发生的顺序。 
	 *
	 *  <p>要定义过渡，可将应用程序的 transitions 属性设置为 Transition 对象的数组。 </p>
	 *
	 *  <p>可使用 Transition 类的 toState 和 fromState 属性来指定触发过渡的状态更改。
	 * 默认情况下，fromState 和 toState 属性均设置为“*”，表示将过渡应用到视图状态的任何更改。</p>
	 *
	 *  <p>可以使用 fromState 属性来明确指定要从中进行更改的视图状态，
	 * 使用 toState 属性来明确指定要更改到的视图状态。
	 * 如果状态更改和两个过渡匹配，则 toState 属性优先于 fromState 属性。
	 * 如果超过一个过渡匹配，将使用过渡数组中的第一个定义。 </p>
	 */
	public class Transition
	{
		public function Transition()
		{
		}
		
		/**
		 * 应用过渡时要播放的 IEffect 对象。通常，它是一个包含多个效果的复合效果对象（如 Parallel 或 Sequence 效果）。 
		 */
		public var effect:IEffect;
		
		/**
		 * 该字符串指定在应用过渡时要从中进行更改的视图状态。默认值为“*”，表示任何视图状态。 
		 * <p>可以将该属性设置为空字符串“”，它对应于基本视图状态。</p>
		 */
		public var fromState:String = "*";
		
		/**
		 *  该字符串指定在应用过渡时要更改到的视图状态。默认值为“*”，表示任何视图状态。 
		 *
		 *  <p>可以将该属性设置为空字符串“”，它对应于基本视图状态。</p>
		 */
		public var toState:String = "*";
		
		/**
		 * 设置为 true 以指定该过渡应用于正向和逆向视图状态更改。
		 * 因此，对于从视图状态 A 到视图状态 B 的更改以及从视图状态 B 到视图状态 A 的更改，使用该过渡。 
		 */
		public var autoReverse:Boolean = false;
		
		/**
		 * 该属性控制当前过渡中断时的行为方式。 InterruptionBehavior 类定义此属性的可能值。
		 * 默认值为end
		 */
		public var interruptionBehavior:String = InterruptionBehavior.END;
	}
}