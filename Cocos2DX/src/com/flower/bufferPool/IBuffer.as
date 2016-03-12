package com.flower.bufferPool
{
	public interface IBuffer
	{
		function initBuffer(...args):void;
		function cycleBuffer():void;
	}
}