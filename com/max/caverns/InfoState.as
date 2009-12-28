package com.max.caverns
{
	import com.adamatomic.flixel.*;
	import com.max.fro.*;

	public class InfoState extends FlxState
	{
		[Embed(source = "../../../data/infoLvl.tmx", mimeType = "application/octet-stream")] private var LvlXML:Class;
		[Embed(source = "../../../data/tiles_all.png")] private var ImgTiles:Class;
		[Embed(source = "../../../data/rockblock.png")] private var ImgRockBlock:Class;	
		[Embed(source = "../../../data/treasureblock.png")] private var ImgTreasureBlock:Class;
		[Embed(source = "../../../data/gem.png")] private var ImgGemBlock:Class;
		[Embed(source = "../../../data/waterblock.png")] private var ImgWaterBlock:Class;
		[Embed(source = "../../../data/hitBlock.mp3")] private var SndHitBlock:Class;
		[Embed(source = "../../../data/breakRock.mp3")] private var SndHitRock:Class;
		[Embed(source = "../../../data/breakTreasure.mp3")] private var SndHitTreasure:Class;
		[Embed(source="../../../data/smallshadow.png")] private var ImgSmallShadow:Class;
		
		private var _tilemap:TiledTilemap;
		private var _rockBlocks:FlxArray;
		private var _treasureBlocks:FlxArray;
		
		private var _goldText:OutlineText;
		private var _goldCounter:uint;
		
		private var _pickAxe:PickAxe;
		private var _player:Player;
		private var _shadow:FlxSprite;
		
		override public function InfoState():void
		{			
			_pickAxe = new PickAxe();
			_rockBlocks = new FlxArray();
			_treasureBlocks = new FlxArray();
			
			_goldText = new OutlineText(-20,-20,40,40,"+10",0xfff600);
			
			_tilemap = new TiledTilemap(XML(new LvlXML()), instantiateObjects, getTileGraphic);
			
			FlxG.follow(_player,2.5);
			FlxG.followAdjust(0.5,0.0);
			FlxG.followBounds(8,8,(_tilemap.width-1)*_tilemap.tileSize,(_tilemap.height-1)*_tilemap.tileSize);
			
			_shadow = new FlxSprite(ImgSmallShadow,0,0);
			_shadow.alpha = 1;
			this.add(_shadow);
			
			this.add(new FlxSprite(null,8,8,false,false,281,56,0xffffffff));
			this.add(new FlxSprite(null,9,9,false,false,279,54,0xff000000));
			this.add(new FlxText(10,10,FlxG.width,160,"X TO JUMP\nC TO SWING PICK AXE",0xffffff,null,16));
			this.add(new FlxText(10,52,FlxG.width,160,"HOLD AN ARROW KEY WHILE SWINGING TO DIRECT PICKAXE",0xffffff));
			
			this.add(new FlxSprite(null,FlxG.width-149,FlxG.height-99,false,false,157,41,0xffffffff));
			this.add(new FlxSprite(null,FlxG.width-148,FlxG.height-98,false,false,155,39,0xff000000));
			this.add(new FlxText(FlxG.width-135,FlxG.height-100,FlxG.width,260,"THIS IS GOLD\nTHIS ROCK IS HARD TO BREAK\nTHIS WILL DROWN YOU\nTHIS IS WORTH LOTS",0xffffff));
			
			this.add(new CavernBlock(FlxG.width-147,FlxG.height-97,8,8,ImgTreasureBlock));
			this.add(new CavernBlock(FlxG.width-147,FlxG.height-88,8,8,ImgRockBlock));
			var waterBlock:FlxSprite = this.add(new FlxSprite(ImgWaterBlock,FlxG.width-147,FlxG.height-79,true,true)) as FlxSprite;
			waterBlock.addAnimation("flow", [0, 1, 2], 10, true);
			waterBlock.play("flow");
			this.add(new CavernBlock(FlxG.width-147,FlxG.height-70,8,8,ImgGemBlock));
		}

		override public function update():void
		{
			_shadow.x = _player.x - 320;
			_shadow.y = _player.y - 240;
			
			if(_player.x > 320)
			{
				FlxG.fade(0xff000000,1,onFade);
			}
			if(_player.x < 0)
			{
				FlxG.fade(0xff000000,1,onFadeBack);
			}
			
			for (var i:uint = 0; i < _tilemap.tilemaps.length; i++)
			{
				_tilemap.tilemaps[i].collide(_pickAxe);	
				_tilemap.tilemaps[i].collide(_player);			
			}

			super.update();
			CavernBlock.overlapArray(_rockBlocks,_pickAxe,pickAxeHitBlock);
			CavernBlock.overlapArray(_treasureBlocks,_pickAxe,pickAxeHitBlock);
			FlxG.collideArray(_rockBlocks, _player);
			FlxG.collideArray(_treasureBlocks, _player);
			
			if (_goldCounter > 0)
			{
				_goldText.setVisible(true);
				_goldCounter = _goldCounter - .1;
				_goldText.yPos = _goldText.y - .5;
			}
			else
			{
				_goldText.setVisible(false);
			}
		}
		
		private var isPlayingHitSnd:Number = 0;
		
		private function pickAxeHitBlock(block:CavernBlock, pickAxe:PickAxe):void 
		{			
			block.hurt(5);
			if (block.dead)
			{
				FlxG.scores[0] = FlxG.scores[0] + 1;
				
				if (block.tileType == "[class InfoState_ImgTreasureBlock]")
				{					
					_goldText.xPos = _player.x;
					_goldText.yPos = _player.y;
					_goldText.setText("+10");
					_goldCounter = 60;
					FlxG.play(SndHitTreasure);
				} else if (block.tileType == "[class InfoState_ImgRockBlock]")
				{
					FlxG.play(SndHitRock);
				} else if (block.tileType == "[class InfoState_ImgGemBlock]")
				{
					_goldText.xPos = _player.x;
					_goldText.yPos = _player.y;
					_goldText.setText("+100");
					_goldCounter = 60;
					FlxG.play(SndHitTreasure);
				} else
				{
					FlxG.play(SndHitBlock,.5);
				}
				
			}
			else
			{
				if (isPlayingHitSnd < 0)
				{
					FlxG.play(SndHitBlock,.5);
					isPlayingHitSnd = .3;
				}
				else
				{
					isPlayingHitSnd -= FlxG.elapsed;
				}
			}
		}
		
		private function onFade():void
		{
			FlxG.switchState(PlayState);
		}
		
		private function onFadeBack():void
		{
			FlxG.switchState(MenuState);
		}
		
		public function getTileGraphic(sourceName:String):Class 
		{
			if (sourceName == "tiles_all.png")
			{
				return ImgTiles;
			}
			trace("tileset not found");
			return null;
		}
		
		private function instantiateObjects(mapData:Array, widthInTiles:uint, heightInTiles:uint):void 
		{
			var blockSize:uint = 8;
			
			for (var x:uint = 0; x < widthInTiles; x++)
			{
				for (var y:uint = 0; y < heightInTiles; y++)
				{					
					if (mapData[y][x] == 0) {
						_player = new Player(x * blockSize, y * blockSize, _pickAxe);
					} else if (mapData[y][x] == 1) {
						_treasureBlocks.add(this.add(new CavernBlock(x*blockSize,y*blockSize,blockSize,blockSize,ImgTreasureBlock,0,100)));
					} else if (mapData[y][x] == 2) {
						_treasureBlocks.add(this.add(new CavernBlock(x*blockSize,y*blockSize,blockSize,blockSize,ImgRockBlock,0,800)));						
					} else if (mapData[y][x] == 3) {
						_treasureBlocks.add(this.add(new CavernBlock(x*blockSize,y*blockSize,blockSize,blockSize,ImgGemBlock,0,200)));							
					}
				}
			}
			
			this.add(_player);
			this.add(_pickAxe);
			_goldText.addChildren();
			this.add(_goldText);
		}
	}
}
