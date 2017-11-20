package com.max.caverns.state {
	
	import com.max.caverns.*;
	
	import org.flixel.*;

	public class PlayStateScroll extends FlxState {
		
		[Embed(source="../../../../data/shadow.png")] private var ImgShadow:Class;
		[Embed(source="../../../../data/smallshadow.png")] private var ImgSmallShadow:Class;
		[Embed(source="../../../../data/largeshadow.png")] private var ImgLargeShadow:Class;
		[Embed(source = "../../../../data/cavernblock.png")] private var ImgCavernBlock:Class;
		[Embed(source = "../../../../data/rockblock.png")] private var ImgRockBlock:Class;	
		[Embed(source = "../../../../data/treasureblock.png")] private var ImgTreasureBlock:Class;
		[Embed(source = "../../../../data/gem.png")] private var ImgGemBlock:Class;		
		[Embed(source = "../../../../data/backgroundcavernblock.png")] private var ImgBackgroundCavernBlock:Class;
		[Embed(source = "../../../../data/waterblock.png")] private var ImgWaterBlock:Class;
		[Embed(source = "../../../../data/hitBlock.mp3")] private var SndHitBlock:Class;
		[Embed(source = "../../../../data/breakRock.mp3")] private var SndHitRock:Class;
		[Embed(source = "../../../../data/breakTreasure.mp3")] private var SndHitTreasure:Class;
		
		private var _player:Player;
		private var _background:FlxSprite;
		
		override public function create():void {
			
			_background = this.add(new FlxSprite(0,0,ImgWaterBlock)) as FlxSprite;
			
			_player = new Player(0, 0);
			this.add(_player);
			FlxG.follow(_player,1);
			FlxG.followAdjust(.2,.2);
			
		}

		override public function update():void {			
			super.update();
			
		}
		
	}
}
