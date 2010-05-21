
/**		
 * 
 *	DynamicSpriteExample
 *	
 *	@version 1.00 | May 21, 2010
 *	@author Justin Windle
 *  
 **/
 
package  
{
	import assets.example.Background;
	import flash.events.ProgressEvent;
	import flash.filters.GlowFilter;
	import assets.example.Layout;
	import assets.example.PushButton;

	import uk.co.soulwire.display.DynamicSprite;

	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;

	/**
	 * DynamicSpriteExample
	 */

	[SWF(backgroundColor="#111111", frameRate="31", width="800", height="550")]

	public class DynamicSpriteExample extends Sprite 
	{
		//	----------------------------------------------------------------
		//	CONSTANTS
		//	----------------------------------------------------------------
		
		private static const BASE : String = "";
		
		private static const LANGUAGES : Array = [
		
			new LanguageVO( "English",	"assets_en.swf" ),			new LanguageVO( "Chinese",	"assets_cn.swf" ),			new LanguageVO( "Japanese",	"assets_jp.swf" ),			new LanguageVO( "Greek",	"assets_gr.swf" ),			new LanguageVO( "Hindi",	"assets_in.swf" )
			
		];
		 
		//	----------------------------------------------------------------
		//	PRIVATE MEMBERS
		//	----------------------------------------------------------------
		
		private var _log : Array = [];
		private var _layout : Layout = new Layout();
		private var _assetLoader : Loader = new Loader();
		private var _buttonIndex : Dictionary = new Dictionary();
		
		// Example DynamicSprites
		private var _helloWorld : DynamicSprite;		private var _flagIcon : DynamicSprite;
		
		//	----------------------------------------------------------------
		//	CONSTRUCTOR
		//	----------------------------------------------------------------
		
		public function DynamicSpriteExample()
		{
			/**
			 * Create a DynamicSprite instance.
			 * You do not have to pass a class definition to the constructor, 
			 * you can set this or change it later or at runtime if desired.
			 */
			 
			_helloWorld = new DynamicSprite( "assets.example.HelloWorld" );			_flagIcon = new DynamicSprite( "assets.example.Flag" );
			
			// When a DynamicSprite's asset is updated, it will dispatch an INSTANCE_UPDATED event.
			_helloWorld.addEventListener(DynamicSprite.INSTANCE_UPDATED, onDynamicSpriteUpdated);			_flagIcon.addEventListener(DynamicSprite.INSTANCE_UPDATED, onDynamicSpriteUpdated);
			
			// Effects and transformations will persist when the asset is updated
			_helloWorld.filters = [ new GlowFilter(0xFFFFFF, 1.0, 8, 8, 0.5, 3) ];
			_helloWorld.scaleX = _helloWorld.scaleY = 1.5;
			
			_flagIcon.scaleX = _flagIcon.scaleY = 1.9;
			_flagIcon.x = 750;
			_flagIcon.y = 10;
			
			// Add it to the stage
			addChild(_helloWorld);			addChild(_flagIcon);
			
			// You can also listen global for when a library is added or updated...
			DynamicSprite.addEventListener(DynamicSprite.LIBRARY_UPDATE_START, onLibraryUpdateStart);
			// ...and for when all instances have been updated from it.			DynamicSprite.addEventListener(DynamicSprite.LIBRARY_UPDATE_COMPLETE, onLibraryUpdateComplete);
			
			// Create buttons
			
			for (var i : int = 0;i < LANGUAGES.length; i++)
			{
				var btn : PushButton = new PushButton();
				btn.addEventListener(MouseEvent.CLICK, onLanguageSelected);
				btn.label.text = LANGUAGES[i].name;
				btn.x = 10;
				btn.y = 180 + (i * 24);
				
				if(i == 0)
				{
					btn.alpha = 0.5;
					btn.mouseEnabled = false;
				}
				
				_buttonIndex[btn] = LANGUAGES[i];
				_layout.addChild(btn);
			}
			
			addChildAt(new Background(), 0);
			addChild(_layout);
			
			// Load the default assets
			
			loadAssets( LANGUAGES[0].path );
		}

		//	----------------------------------------------------------------
		//	PRIVATE METHODS
		//	----------------------------------------------------------------
		
		private function loadAssets(path : String) : void
		{
			log("Loading: " + path);
			
			_assetLoader = new Loader();
			_assetLoader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onAssetLoadProgress);
			_assetLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onAssetLoadComplete);
			_assetLoader.load(new URLRequest(BASE + path));
		}
		
		private function log(message : String) : void
		{
			if(_log.length >= 10)
			{
				_log.shift();
			}
			
			_log.push(message);
			_layout.console.text = '';
			
			for (var i : int = 0;i < _log.length; i++)
			{
				if(i > 0) _layout.console.appendText("\n");
				_layout.console.appendText(_log[i]);
			}
		}

		//	----------------------------------------------------------------
		//	EVENT HANDLERS
		//	----------------------------------------------------------------

		private function onLanguageSelected(event : MouseEvent) : void 
		{
			for (var btn : * in _buttonIndex) 
			{
				btn.alpha = 1.0;
				btn.mouseEnabled = true;
			}
			
			var button : PushButton = event.target as PushButton;
			var language : LanguageVO = _buttonIndex[button];
			
			log('----------');
			log("Language selected: " + language.name);
			
			loadAssets( language.path );
			
			button.alpha = 0.5;
			button.mouseEnabled = false;
		}
		
		private function onAssetLoadProgress(event : ProgressEvent) : void
		{
			log("Loading: " + int((event.bytesLoaded / event.bytesTotal) * 100) + "%");
			
			_layout.graphics.clear();
			_layout.graphics.beginFill(0xCCCCCC);
			_layout.graphics.drawRect(10, 374, 780 * (event.bytesLoaded / event.bytesTotal), 1);
			_layout.graphics.endFill();
		}

		private function onAssetLoadComplete(event : Event) : void 
		{
			_layout.graphics.clear();
			
			log("Load Complete: " + _assetLoader.contentLoaderInfo.url);
			_assetLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onAssetLoadComplete);
			
			/**
			 * Now we can global roll out this asset change to all DynamicSprite
			 * instances using the static DynamicSprite update method.
			 * 
			 * The first parameter is used to differentiate between multiple 
			 * libraries per language (if applicable)
			 */
			 
			DynamicSprite.update("example", _assetLoader.content);
		}

		private function onDynamicSpriteUpdated(event : Event) : void
		{
			var sprite : DynamicSprite = event.target as DynamicSprite;
			
			// A DynamicSprite's name by default is its class definition
			log(sprite.name + " >> updated: (width: " + sprite.width + ", height: " + sprite.height + ")");
			
			switch( sprite )
			{
				case _helloWorld :
				
					var bounds : Rectangle = sprite.getBounds(sprite);
			
					sprite.x = (stage.stageWidth * 0.5) - (bounds.width * 0.5);
					sprite.y = (stage.stageHeight * 0.5) - 100;
				
					break;				case _flagIcon : 
				
					sprite.x = stage.stageWidth - sprite.width - 10;
				
					break;
			}
			
		}
		
		private function onLibraryUpdateStart(event : Event) : void
		{
			log("Library update START");
		}
		
		private function onLibraryUpdateComplete(event : Event) : void
		{
			log("Library update COMPLETE");
		}
	}
}
