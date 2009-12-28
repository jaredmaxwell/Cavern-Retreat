package com.max.caverns
{
	import com.adamatomic.flixel.*;

	public class GameOverState extends FlxState
	{		
		private var _timer:Number;
		private var _fading:Boolean;

		public function GameOverState()
		{
			super();
			_timer = 0;
			_fading = false;
			FlxG.flash(0xffff0000);
			this.add(new FlxText(0,FlxG.height/2-35,FlxG.width,FlxG.height,"GAME OVER\n\nYOU COULDN'T ESCAPE THE WAVE\n\nGOLD: " + FlxG.score,0xffffff,null,16,"center"));
		
			if(FlxG.kong)
			{
				FlxG.kong.API.stats.submitArray ( [	{name:"Total Gold", value:FlxG.score},
													{name:"Highest Gold", value:FlxG.score},
													{name:"Drownings", value:1},
													{name:"Blocks Dug", value:FlxG.scores[0]} ] );
			}
		}

		override public function update():void
		{
			super.update();
			if(!_fading)
			{
				_timer += FlxG.elapsed;
				if((_timer > 1) && ((_timer > 10) || FlxG.justPressed(FlxG.A) || FlxG.justPressed(FlxG.B)))
				{
					_fading = true;
					FlxG.fade(0xff000000,2,onPlay);
				}
			}
		}
		
		private function onPlay():void 
		{ 
			FlxG.switchState(MenuState); 
		}
	}
}