package com.max.caverns
{
	import com.adamatomic.flixel.*;
	import com.max.fro.*;
	
	import flash.geom.Point;

	public class PlayState extends FlxState
	{
		
		[Embed(source="../../../data/shadow.png")] private var ImgShadow:Class;
		[Embed(source="../../../data/smallshadow.png")] private var ImgSmallShadow:Class;
		[Embed(source="../../../data/largeshadow.png")] private var ImgLargeShadow:Class;
		[Embed(source = "../../../data/cavernblock.png")] private var ImgCavernBlock:Class;
		[Embed(source = "../../../data/rockblock.png")] private var ImgRockBlock:Class;	
		[Embed(source = "../../../data/treasureblock.png")] private var ImgTreasureBlock:Class;
		[Embed(source = "../../../data/gem.png")] private var ImgGemBlock:Class;		
		[Embed(source = "../../../data/backgroundcavernblock.png")] private var ImgBackgroundCavernBlock:Class;
		[Embed(source = "../../../data/waterblock.png")] private var ImgWaterBlock:Class;
		[Embed(source = "../../../data/hitBlock.mp3")] private var SndHitBlock:Class;
		[Embed(source = "../../../data/breakRock.mp3")] private var SndHitRock:Class;
		[Embed(source = "../../../data/breakTreasure.mp3")] private var SndHitTreasure:Class;
		
		
		private const WIDTH_IN_TILES:uint = 40;
		private const HEIGHT_IN_TILES:uint = 28;
		private const X_OFFSET_OF_GRID:uint = 0;
		private const Y_OFFSET_OF_GRID:uint = 16;
		
		// Upgradable stuff
		public static var shadowSize:uint = 0;
		public static var canDoubleJump:Boolean = false;
		public static var canHover:Boolean = false;
		public static var pickAxeLvl:uint = 0;
		
		
		//Win Conditions
		public static var _leftCount:uint;
		public static var _rightCount:uint;
		public static var _upCount:uint;
		public static var _downCount:uint;
		
		private var _background:FlxBlock;
		
		private var _blocks:FlxArray;
		private var _rockBlocks:FlxArray;
		private var _treasureBlocks:FlxArray;
		private var _waterBlocks:FlxArray;
		private var _gemBlock:CavernBlock;
		
		private var _pickAxe:PickAxe;
		private var _player:Player;
		private var _shadow:FlxSprite;
		
		private var _goldText:OutlineText;
		private var _goldCounter:uint;
		
		private var _scoreText:FlxText;
				
		private var _counterTilWaterImpacts:Number;
		private var _waterCounter:Number;
		private var _floodingCounter:Number;
		
		private var _counterText:FlxText;
		private var _counterShadow:FlxText;
		private var _currentStage:String;
		
		private var _currentlyMissingBlocks:Array;
		
		function PlayState():void
		{
			super();
			
			_currentlyMissingBlocks = new Array();
			
			_currentStage = " seconds until tidal wave hits the cavern!"
			_waterCounter = -1;
			_floodingCounter = -1;
			_counterTilWaterImpacts = 10;
			_counterText = new FlxText(10, 10, FlxG.width, 20, _counterTilWaterImpacts.toString() + _currentStage, 0xffffff);
			_counterShadow = new FlxText(10+1, 10+1, FlxG.width, 20, _counterTilWaterImpacts.toString() + _currentStage, 0x000000);
			_pickAxe = new PickAxe();
			_goldText = new OutlineText(-20,-20,40,40,"+10",0xfff600);
			_scoreText = new FlxText(FlxG.width-30,10,30,20,FlxG.score.toString(),0xffffff);
			
			_background = new FlxBlock( -8, -8, 336, 256, ImgBackgroundCavernBlock);
			this.add(_background);
			
			var i:uint = 0;
			
			_blocks = new FlxArray();	
			_rockBlocks = new FlxArray();
			_treasureBlocks = new FlxArray();
			_waterBlocks = new FlxArray();
			for (i = 0; i < WIDTH_IN_TILES * HEIGHT_IN_TILES; i++)
			{
				this.add(_blocks.add(new CavernBlock(-20, -20, 8, 8, ImgCavernBlock)) as FlxCore);
				this.add(_treasureBlocks.add(new CavernBlock( -20, -20, 8, 8, ImgTreasureBlock, 0, 100)) as FlxCore);
				this.add(_rockBlocks.add(new CavernBlock( -20, -20, 8, 8, ImgRockBlock, 0, 800)) as FlxCore);
				
				var waterBlock:FlxSprite = new FlxSprite(ImgWaterBlock,-20, -20,true,true)
				waterBlock.kill();
				waterBlock.addAnimation("flow", [0, 1, 2], 10, true);
				this.add(_waterBlocks.add(waterBlock) as FlxCore);
			}
			
			if (PlayState.shadowSize == 0)
			{
				_shadow = new FlxSprite(ImgSmallShadow,0,0);
			} else if (PlayState.shadowSize == 1)
			{
				_shadow = new FlxSprite(ImgShadow,0,0);				
			} else if (PlayState.shadowSize == 2)
			{
				_shadow = new FlxSprite(ImgLargeShadow,0,0);
			}
			_shadow.alpha = 1;
			
			instantiateObjects(WIDTH_IN_TILES, HEIGHT_IN_TILES);
			
			FlxG.follow(_player,2.5);
			FlxG.followAdjust(0.5,0.0);
			FlxG.followBounds(8,8,40*8,30*8);
			
			FlxG.flash(0xff131c1b);
		}		
		
		private function instantiateObjects(widthInTiles:uint, heightInTiles:uint):void 
		{
			var curBlock:uint = 0;
			var blockSize:uint = 8;
			var emptyBlock:Point = new Point();
			var gemBlock:Point = new Point();
			var missingBlocks:Array = new Array();
			var addPlayer:Boolean = false;
			
			if (_player == null)//First level
			{
				FlxG.level = 1;
				FlxG.levels[FlxG.level] = new CavernLevel(FlxG.level);
				//trace("first level");
				emptyBlock = new Point(1, 27);
				gemBlock = new Point(Math.ceil(Math.random()*39)+1,28); //This should make them brake the block while its below them and they will fall through. kinda showing them that its good to dig off screen.
				addPlayer = true;
			}
			else//Next Level
			{		
				var tempX:uint = (_player.x - X_OFFSET_OF_GRID) / blockSize;
				var tempY:uint = (_player.y - Y_OFFSET_OF_GRID) / blockSize;
				trace("Player exit: " + _player.x + ", " + _player.y);
				trace("Exit coord: " + tempX + ", " + tempY);
				
				_player.x = -20;
				_player.y = -20;
				
				var cameFromDirection:String;
				var prevLevel:CavernLevel = FlxG.levels[FlxG.level];
				var level:CavernLevel = null;
				
				if (tempX > 39)
				{
					tempX = 1;
					cameFromDirection = "left";
					if (prevLevel.RightLevel != null)
					{
						level = prevLevel.RightLevel;
						level.LeftLevel = FlxG.levels[FlxG.level];
					}
					else
					{
						_rightCount++;
					}
				}
				else if (tempX < 1)
				{
					tempX = 40;
					cameFromDirection = "right";
					if (prevLevel.LeftLevel != null)
					{
						level = prevLevel.LeftLevel;
						level.RightLevel = FlxG.levels[FlxG.level];
					}
					else
					{
						_leftCount++;
					}
				}
				
				if (tempY > 29)
				{
					tempY = 1;
					cameFromDirection = "top";
					if (prevLevel.BottomLevel != null)
					{
						level = prevLevel.BottomLevel;
						level.TopLevel = FlxG.levels[FlxG.level];
					}
					else
					{
						_downCount++;
					}
				}
				else if (tempY < 1)
				{
					tempY = 27;
					cameFromDirection = "bottom";
					if (prevLevel.TopLevel != null)
					{
						level = prevLevel.TopLevel;
						level.BottomLevel = FlxG.levels[FlxG.level];
					}
					else
					{
						_upCount++;
					}
				}
				
				if (level == null)
				{
					//trace("new level");
					FlxG.level++;
					level = new CavernLevel(FlxG.level, FlxG.levels[FlxG.level - 1], cameFromDirection);
					FlxG.levels[FlxG.level] = level;
				}
				else
				{
					//trace("old level");
					FlxG.level = level.LevelNum;
					missingBlocks = level.MissingBlocks;
				}
				
				//trace("level " + FlxG.level);
				trace("Entry coord: " + tempX + ", " + tempY);
				
				emptyBlock = new Point(tempX, tempY);
				gemBlock = new Point(Math.ceil(Math.random()*39)+1,Math.ceil(Math.random()*27)+1);
			}
			
			for (var x:uint = 1; x < widthInTiles+1; x++)
			{
				for (var y:uint = 1; y < heightInTiles+1; y++)
				{			
					if (x == emptyBlock.x && y == emptyBlock.y)
					{
						//trace(x + " " + y);
						if (_player == null)
							_player = new Player(emptyBlock.x * blockSize + X_OFFSET_OF_GRID, emptyBlock.y * blockSize + Y_OFFSET_OF_GRID, _pickAxe);
						else
						{
							_player.x = emptyBlock.x * blockSize + X_OFFSET_OF_GRID;
							_player.y = emptyBlock.y * blockSize + Y_OFFSET_OF_GRID;
							trace("new player: " + _player.x + ", " + _player.y);
						}
						_blocks[curBlock].x = x * blockSize + X_OFFSET_OF_GRID;
						_blocks[curBlock].y = y * blockSize + Y_OFFSET_OF_GRID;
						_blocks[curBlock].kill();
						_rockBlocks[curBlock].x = x * blockSize + X_OFFSET_OF_GRID;
						_rockBlocks[curBlock].y = y * blockSize + Y_OFFSET_OF_GRID;
						_rockBlocks[curBlock].kill();
						_treasureBlocks[curBlock].x = x * blockSize + X_OFFSET_OF_GRID;
						_treasureBlocks[curBlock].y = y * blockSize + Y_OFFSET_OF_GRID;
						_treasureBlocks[curBlock].kill();
						curBlock++;
						
						if (_floodingCounter != -1)
						{
							_currentlyMissingBlocks.reverse();
							_currentlyMissingBlocks.push(new Point(emptyBlock.x*blockSize + X_OFFSET_OF_GRID, emptyBlock.y*blockSize + Y_OFFSET_OF_GRID));
							_currentlyMissingBlocks.reverse();
						}
						else
						{
							_currentlyMissingBlocks.push(new Point(emptyBlock.x*blockSize + X_OFFSET_OF_GRID, emptyBlock.y*blockSize + Y_OFFSET_OF_GRID));
						}
					}
					else if (x == gemBlock.x && y == gemBlock.y)
					{
						if (_gemBlock == null)
						{
							_gemBlock = new CavernBlock(x * blockSize + X_OFFSET_OF_GRID, y * blockSize + Y_OFFSET_OF_GRID,8,8, ImgGemBlock,0,200);
						}
						else
						{
							_gemBlock.exists = true;
							_gemBlock.dead = false;
							_gemBlock.x = x * blockSize + X_OFFSET_OF_GRID;
							_gemBlock.y = y * blockSize + Y_OFFSET_OF_GRID;
						}
						
						_blocks[curBlock].x = x * blockSize + X_OFFSET_OF_GRID;
						_blocks[curBlock].y = y * blockSize + Y_OFFSET_OF_GRID;
						_blocks[curBlock].kill();
						_rockBlocks[curBlock].x = x * blockSize + X_OFFSET_OF_GRID;
						_rockBlocks[curBlock].y = y * blockSize + Y_OFFSET_OF_GRID;
						_rockBlocks[curBlock].kill();
						_treasureBlocks[curBlock].x = x * blockSize + X_OFFSET_OF_GRID;
						_treasureBlocks[curBlock].y = y * blockSize + Y_OFFSET_OF_GRID;
						_treasureBlocks[curBlock].kill();
						curBlock++;
					}
					else {
						var blockExists:Boolean = true;
						for (var i:uint = 0; i < missingBlocks.length; i++)
						{
							if (missingBlocks[i] == curBlock)
							{
								blockExists = false;
							}
						}
						
						var currentBlock:CavernBlock;
						var rndNum:Number = Math.random();
						if (rndNum > .3)
						{
							currentBlock = _blocks[curBlock];
							_rockBlocks[curBlock].kill();
							_treasureBlocks[curBlock].kill();
						} else if (rndNum > .1)
						{
							currentBlock = _rockBlocks[curBlock];
							_blocks[curBlock].kill();
							_treasureBlocks[curBlock].kill();
						} else if (rndNum > 0)
						{
							currentBlock = _treasureBlocks[curBlock];
							_rockBlocks[curBlock].kill();
							_blocks[curBlock].kill();
						}
						
						currentBlock.x = x * blockSize + X_OFFSET_OF_GRID;
						currentBlock.y = y * blockSize + Y_OFFSET_OF_GRID;
						if (!blockExists)
						{
							currentBlock.kill();
							if (_waterCounter != -1)
							{
								_waterBlocks[curBlock].x = x * blockSize + X_OFFSET_OF_GRID;
								_waterBlocks[curBlock].y = y * blockSize + Y_OFFSET_OF_GRID;
								_waterBlocks[curBlock].dead = false;
								_waterBlocks[curBlock].exists = true;
							}
						}
						curBlock++;
					}
				}
			}
			
			//Don't want to add to the game more then once.
			if (addPlayer)
			{
				this.add(_gemBlock);
				this.add(_player);
				this.add(_pickAxe);
				_goldText.addChildren();
				this.add(_goldText);
				this.add(_shadow);
				
				//HUD
				this.add(new FlxBlock(8,8,320,16,ImgBackgroundCavernBlock));
				this.add(new FlxSprite(null,8,8,false,false,320,1,0x88ffffff));
				this.add(new FlxSprite(null,8,23,false,false,320,1,0x88ffffff));
				this.add(new FlxSprite(null,8,8,false,false,1,16,0x88ffffff));
				this.add(new FlxSprite(null,327,8,false,false,1,16,0x88ffffff));
				this.add(_counterShadow);
				this.add(_counterText);
				this.add(_scoreText);
			}
		}

		override public function update():void
		{			
			super.update();
			CavernBlock.overlapArray(_blocks,_pickAxe,pickAxeHitBlock);	
			CavernBlock.overlapArray(_rockBlocks,_pickAxe,pickAxeHitBlock);
			CavernBlock.overlapArray(_treasureBlocks,_pickAxe,pickAxeHitBlock);
			if (!_gemBlock.dead && _gemBlock.overlaps(_pickAxe))
			{
				pickAxeHitBlock(_gemBlock,_pickAxe);
			}
			if (!_gemBlock.dead) _gemBlock.collide(_player);
			FlxG.collideArray(_blocks, _player);
			FlxG.collideArray(_rockBlocks, _player);
			FlxG.collideArray(_treasureBlocks, _player);
			FlxG.overlapArray(_waterBlocks, _player, playerIsInWater);
			
			_shadow.x = _player.x - 320;
			_shadow.y = _player.y - 240;
			
			if (!_player.visible)
			{
				//Show Game Over Screen
				FlxG.switchState(GameOverState);
			}
			
			var i:uint = 0;
			
			if (_waterCounter == -1)
			{
				_counterTilWaterImpacts -= FlxG.elapsed;
				if (_counterTilWaterImpacts < 0)
				{
					_counterTilWaterImpacts = 0;
					
					//The Wave just hit the cavern
					var totalMissingBlocks:uint = 0;
					for (i = 0; i < FlxG.level; i++)
					{
						if (FlxG.levels[i] != null && FlxG.levels[i].MissingBlocks != null)
						{							
							var missingBlocks:Array = FlxG.levels[i].MissingBlocks;
							var tempArray:Array = new Array();
							var tempIndex:uint = 0;
							
							//trace(missingBlocks.length);

							missingBlocks.sort();
							tempArray[0] = missingBlocks[0];
							tempIndex++;

							for(var j:uint = 1; j < missingBlocks.length; j++) {
								if(missingBlocks[j] != missingBlocks[j-1]) {
									tempArray[tempIndex] = missingBlocks[j];
									tempIndex++;
								}
							}

							missingBlocks = tempArray;
							
							//trace(missingBlocks.length);
							
							totalMissingBlocks += missingBlocks.length/2;
						}
					}
					
					FlxG.flash(0xff000011,0.5);
					FlxG.quake(0.035,0.5);
					_currentStage = " seconds until water catches up to your current level!";
					_waterCounter = totalMissingBlocks;
				}
				_counterText.setText(int(_counterTilWaterImpacts).toString() + _currentStage);
				_counterShadow.setText(int(_counterTilWaterImpacts).toString() + _currentStage);
				if (_counterTilWaterImpacts < 5)
				{
					_counterText.setColor(0xFF0000);
				}
			}
			else if (_floodingCounter == -1)
			{
				_waterCounter -= FlxG.elapsed;
				if (_waterCounter < 0)
				{
					_waterCounter = 0;
					
					//The Water has caught up to your level!
					_currentlyMissingBlocks.reverse();
					_floodingCounter = 1;
				}
				_counterText.setText(int(_waterCounter).toString() + _currentStage);
				_counterShadow.setText(int(_waterCounter).toString() + _currentStage);
				if (_waterCounter < 5)
				{
					_counterText.setColor(0xFF0000);
				}
				else
				{
					_counterText.setColor(0xffffff);
				}
			}
			else
			{
				_floodingCounter -= FlxG.elapsed;
				if (_floodingCounter < 0)
				{
					var tempPoint:Point = _currentlyMissingBlocks.pop();
					
					if (tempPoint != null)
					{
						for (i = 0; i < _waterBlocks.length; i++)
						{
							if (_waterBlocks[i].dead)
							{
								_waterBlocks[i].x = tempPoint.x;
								_waterBlocks[i].y = tempPoint.y;
								_waterBlocks[i].exists = true;
								_waterBlocks[i].dead = false;
								_waterBlocks[i].play("flow");
								break;
							}
						}
					}
					
					_floodingCounter = .5;
				}
				_counterText.setText("The water has caught up to you! Run!");
				_counterShadow.setText("The water has caught up to you! Run!");
			}
			
			if (_player.x > 321 || _player.x < 7 || _player.y > 256 || _player.y < Y_OFFSET_OF_GRID)
			{	
				_pickAxe.dead = true;
				_pickAxe.finished = true;
							
				//Save previous layout of blocks
				var tempLvl:Array = new Array();
				
				for (i = 0; i < _blocks.length; i++)
				{
					var deadBlockCnt:uint = 0;
					if (_blocks[i].dead)
					{
						_blocks[i].exists = true;
						_blocks[i].dead = false;
						deadBlockCnt++;
					}
					if (_rockBlocks[i].dead)
					{
						_rockBlocks[i].exists = true;
						_rockBlocks[i].dead = false;
						deadBlockCnt++;
					}
					if (_treasureBlocks[i].dead)
					{
						_treasureBlocks[i].exists = true;
						_treasureBlocks[i].dead = false;
						deadBlockCnt++;
					}
					
					if (deadBlockCnt == 3)
					{
						tempLvl.push(i);
					}
				}
				
				FlxG.levels[FlxG.level].MissingBlocks = tempLvl;
				
				tempArray = new Array();
				tempIndex = 0;

				_currentlyMissingBlocks.sort();
				tempArray[0] = _currentlyMissingBlocks[0];
				tempIndex++;

				for(i = 1; i < _currentlyMissingBlocks.length; i++) 
				{
					if(_currentlyMissingBlocks[i].x != _currentlyMissingBlocks[i-1].x && _currentlyMissingBlocks[i].y != _currentlyMissingBlocks[i-1].y) 
					{
						tempArray[tempIndex] = _currentlyMissingBlocks[i];
						tempIndex++;
					}
				}

				_currentlyMissingBlocks = tempArray;
				
				if (_waterCounter != -1)
				{
					_waterCounter += _currentlyMissingBlocks.length/2;
					_floodingCounter = -1;
				}
				
				_currentlyMissingBlocks = new Array();
				
				for (i = 0; i < _waterBlocks.length; i++)
				{
					if (!_waterBlocks[i].dead)
					{
						_waterBlocks[i].kill();
					}
				}
				
				var totalScreens:uint = _upCount + _downCount + _rightCount + _leftCount;
				
				if (totalScreens >= 10)
				{
					var directionX:Number = _rightCount - _leftCount;
					var directionY:Number = _upCount - _downCount;
					
					trace(directionX);
					trace(directionY);
						
					if (Math.abs(directionX) > Math.abs(directionY))
					{
						if (directionX < 0)
						{
							FlxG.switchState(WinLeftState);
						}
						else
						{
							FlxG.switchState(WinRightState);							
						}
					}
					else
					{
						if (directionY > 0)
						{
							FlxG.switchState(WinUpState);
						}
						else
						{
							FlxG.switchState(WinDownState);							
						}
					}
				}
				else if (totalScreens == 6) // go upgrade shop
				{
					FlxG.switchState(UpgradeState);
				}
				else if (totalScreens == 3) // go upgrade shop
				{
					FlxG.switchState(UpgradeState);					
				}
				
				instantiateObjects(WIDTH_IN_TILES, HEIGHT_IN_TILES);
			}
			
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
			
			_scoreText.setText(FlxG.score.toString());
		}
		
		private var isPlayingHitSnd:Number = 0;
		
		private function pickAxeHitBlock(block:CavernBlock, pickAxe:PickAxe):void 
		{			
			block.hurt(5*(PlayState.pickAxeLvl+1));
			if (block.dead)
			{
				FlxG.scores[0] = FlxG.scores[0] + 1;
				
				if (block.tileType == "[class PlayState_ImgTreasureBlock]")
				{
					FlxG.score += 10;
					
					_goldText.setText("+10");
					_goldText.xPos = _player.x;
					_goldText.yPos = _player.y;
					_goldCounter = 60;
					FlxG.play(SndHitTreasure);
				} else if (block.tileType == "[class PlayState_ImgRockBlock]")
				{
					FlxG.play(SndHitRock);
				} else if (block.tileType == "[class PlayState_ImgGemBlock]")
				{
					FlxG.score += 100;
					
					_goldText.setText("+100");
					_goldText.xPos = _player.x;
					_goldText.yPos = _player.y;
					_goldCounter = 60;
					FlxG.play(SndHitTreasure);
				}
				{
					FlxG.play(SndHitBlock,.5);
				}
				
				if (_floodingCounter != -1)
				{
					_currentlyMissingBlocks.reverse();
					_currentlyMissingBlocks.push(new Point(block.x, block.y));
					_currentlyMissingBlocks.reverse();
				}
				else
				{
					_currentlyMissingBlocks.push(new Point(block.x, block.y));
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
		
		private function playerIsInWater(water:FlxSprite, player:Player):void 
		{
			player.isDrowning()
		}
	}
}
