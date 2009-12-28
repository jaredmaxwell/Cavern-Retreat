package com.max.caverns
{
	import com.adamatomic.flixel.*;

	public class Ninjarift extends FlxState
	{		
		[Embed(source = "../../../data/cursor.png")] private var ImgCursor:Class;
		[Embed(source = "../../../data/Official320x240.png")] private var ImgBackground:Class;
		
		private var _timer:Number;
		private var _fading:Boolean;

		public function Ninjarift()
		{
			super();
			_timer = 0;
			_fading = false;
			
			this.add(new FlxSprite(null, 0, 0, false, false, FlxG.width, FlxG.height, 0xffffff));
			this.add(new FlxSprite(ImgBackground));
			FlxG.setCursor(ImgCursor);
		}

		override public function update():void
		{			
			if (FlxG.kMouse)
			{
				FlxG.openURL("http://ninjarift.com");
			}
			
			super.update();
			if(!_fading)
			{
				_timer += FlxG.elapsed;
				if((_timer > 1) && ((_timer > 1) || FlxG.justPressed(FlxG.A) || FlxG.justPressed(FlxG.B)))
				{
					_fading = true;
					FlxG.fade(0xffffffff,1,onPlay);
				}
			}
		}
		
		private function onPlay():void 
		{ 
			FlxG.switchState(LudumDare); 
		}
	}
}