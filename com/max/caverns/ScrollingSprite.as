package com.max.caverns
{
	import com.adamatomic.flixel.*;

	public class ScrollingSprite extends FlxSprite
	{
		protected var speed:int;
		
		public function ScrollingSprite(graphic:Class, x:int,y:int, animated:Boolean, reverse:Boolean)
		{
			super(graphic, x, y, animated, reverse);
			speed = Math.random()*15+10;
		}
		
		override public function update():void 
		{
			super.update();
			
			x = x - FlxG.elapsed*speed;
			
			if (x + width < 0)
			{
				x = 320 + Math.random()*400;
				y = Math.random()*150+1;
			}
		}
		
	}

}