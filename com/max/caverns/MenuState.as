package com.max.caverns
{
	import com.adamatomic.flixel.*;
	import com.max.fro.*;

	public class MenuState extends FlxState
	{		
		[Embed(source = "../../../data/cursor.png")] private var ImgCursor:Class;
		[Embed(source = "../../../data/cloud.png")] private var ImgCloud:Class;
		[Embed(source = "../../../data/bigCloud.png")] private var ImgBigCloud:Class;
		[Embed(source = "../../../data/menuLvl.tmx", mimeType = "application/octet-stream")] private var LvlXML:Class;
		[Embed(source = "../../../data/tiles_all.png")] private var ImgTiles:Class;
		[Embed(source = "../../../data/music.mp3")] private var SndMusic:Class;
		
		private var _tilemap:TiledTilemap;
		private var _pickAxe:PickAxe;
		private var _player:Player;
		
		private var _b:FlxButton;
		private var _t1:FlxText;
		private var _ok:Boolean;
		private var _ok2:Boolean;
		
		override public function MenuState():void
		{
			PlayState.canDoubleJump = false;
			PlayState.canHover = false;
			PlayState.pickAxeLvl = 0;
			PlayState.shadowSize = 0;
			
			PlayState._downCount = 0;
			PlayState._leftCount = 0;
			PlayState._rightCount = 0;
			PlayState._upCount = 0;
			
			FlxG.scores[0] = 0;
			FlxG.scores[1] = 0;
			FlxG.score = 0;
			FlxG.scores[2] = 0;		
			
			FlxG.setMusic(SndMusic,.4);
			_pickAxe = new PickAxe();
			
			for (var i:int = 0; i < 10; i++)
			{
				this.add(new ScrollingSprite(ImgBigCloud, 320 + Math.random()*400, Math.random()*100+10, false, false));
			}
			
			_tilemap = new TiledTilemap(XML(new LvlXML()), instantiateObjects, getTileGraphic);
			
			FlxG.follow(_player,2.5);
			FlxG.followAdjust(0.5,0.0);
			FlxG.followBounds(8,8,(_tilemap.width-1)*_tilemap.tileSize,(_tilemap.height-1)*_tilemap.tileSize);
				
			_t1 = this.add(new FlxText(FlxG.width,FlxG.height/3,300,80,"Cavern Retreat",0xbbbbbb,null,32)) as FlxText;
			
			_ok = false;
			_ok2 = false;
			
			FlxG.setCursor(ImgCursor);
		}

		override public function update():void
		{
			if(!FlxG.kong) (FlxG.kong = parent.addChild(new FlxKong()) as FlxKong).init();
			
			//Slides the text ontot he screen
			var t1m:uint = 8;
			if(_t1.x > t1m)
			{
				_t1.x -= FlxG.elapsed*FlxG.width;
				if(_t1.x < t1m) _t1.x = t1m;
			}
			
			//Check to see if the text is in position
			if(!_ok && (_t1.x == t1m))
			{
				//explosion
				_ok = true;
				FlxG.flash(0xff000000,0.5);
				FlxG.quake(0.035,0.5);
				_t1.setColor(0xffffff);
				_t1.angle = Math.random()*30-20;
				
				this.add(new FlxText(t1m+16,FlxG.height/3+58,110,20,"by Jared Maxwell",0xffffff,null,8,"center"));
				
				//play button
				this.add(new FlxSprite(null,t1m,FlxG.height/3+136,false,false,108,21,0xffffffff));
				this.add(new FlxSprite(null,t1m+1,FlxG.height/3+137,false,false,106,19,0xff000000));
				this.add(new FlxText(t1m,FlxG.height/3+139,110,20,"WALK RIGHT  TO PLAY",0xffffff,null,8,"center"));
				_b = this.add(new FlxButton(t1m+2,FlxG.height/3+138,new FlxSprite(null,0,0,false,false,104,15,0xffffffff),onButton,new FlxSprite(null,0,0,false,false,104,15,0xff000000),new FlxText(25,1,100,10,"CLICK HERE",0x000000),new FlxText(25,1,100,10,"CLICK HERE",0xffffff))) as FlxButton;
			}
			
			if(_ok && !_ok2 && _player.x > 320)
			{
				_ok2 = true;
				FlxG.flash(0xff937011,0.5);
				FlxG.fade(0xff000000,1,onFade);
			}
			
			for (var i:uint = 0; i < _tilemap.tilemaps.length; i++)
			{
				_tilemap.tilemaps[i].collide(_pickAxe);	
				_tilemap.tilemaps[i].collide(_player);			
			}

			super.update();
		}
		
		private function onButton():void
		{
			_b.visible = false;
			_b.active = false;
		}
		
		private function onFade():void
		{
			FlxG.switchState(InfoState);
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
					}
				}
			}
			
			this.add(_player);
			this.add(_pickAxe);
			
			for (var i:int = 0; i < 10; i++)
			{
				this.add(new ScrollingSprite(ImgCloud, 320 + Math.random()*100, Math.random()*100+10, false, false));
			}
		}
	}
}
