package com.max.caverns.state
{
	import org.flixel.*;

	public class Ninjarift extends FlxState
	{		
		[Embed(source = "../../../data/cursor.png")] private var ImgCursor:Class;
		[Embed(source = "../../../data/Official320x240.png")] private var ImgBackground:Class;
		
		private var _timer:Number;
		private var _fading:Boolean;

		override public function create():void
		{
			_timer = 0;
			_fading = false;
			this.add(new FlxSprite(0, 0, ImgBackground));
		}

		override public function update():void
		{			
			if (FlxG.mouse.justPressed())
			{
				
				FlxU.openURL("http://ninjarift.com");
			}
			
			super.update();
			if(!_fading)
			{
				_timer += FlxG.elapsed;
				if((_timer > 1) && ((_timer > 1) || FlxG.keys.justPressed('A') || FlxG.keys.justPressed('B')))
				{
					_fading = true;
					FlxG.fade.start(0xffffffff,1,onPlay);
				}
			}
		}
		
		private function onPlay():void 
		{ 
			FlxG.state = new PlayStateScroll(); 
		}
	}
}