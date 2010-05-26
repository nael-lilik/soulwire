
/**		
 * 
 *	Main
 *	
 *	@version 1.00 | May 26, 2010
 *	@author Justin Windle
 *  
 **/
 
package  
{
	import flash.utils.ByteArray;
	import com.bit101.components.Label;
	import com.bit101.components.ProgressBar;
	import geom.Polygon;

	import com.bit101.components.HUISlider;
	import com.bit101.components.PushButton;
	import com.pfp.events.JPEGAsyncCompleteEvent;
	import com.pfp.utils.JPEGAsyncVectorEncoder;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.net.FileReference;

	/**
	 * Main
	 */

	[SWF(backgroundColor="#F2F2F2", frameRate="31", width="900", height="650")]

	public class Main extends Sprite 
	{
		//	----------------------------------------------------------------
		//	CONSTANTS
		//	----------------------------------------------------------------
		
		private static const UI_HEIGHT : int = 40;
		 
		//	----------------------------------------------------------------
		//	PRIVATE MEMBERS
		//	----------------------------------------------------------------

		private var _imageData : ByteArray;
		private var _subdivision : Subdivision;
		private var _overlay : Sprite = new Sprite();
		
		private var _useLongestSlider : HUISlider = new HUISlider();
		private var _useRandomSlider : HUISlider = new HUISlider();
		private var _subdivideSlider : HUISlider = new HUISlider();		private var _minAvSideSlider : HUISlider = new HUISlider();
		private var _downloadButton : PushButton = new PushButton();
		private var _saveButton : PushButton = new PushButton();
		private var _progress : ProgressBar = new ProgressBar();		private var _saving : Label = new Label();
		
		private var _encoder : JPEGAsyncVectorEncoder = new JPEGAsyncVectorEncoder(100);

		//	----------------------------------------------------------------
		//	CONSTRUCTOR
		//	----------------------------------------------------------------

		public function Main()
		{
			Polygon.LINE_COLOUR = 0x111111;
			Polygon.FILL_COLOUR = 0xF5F5F5;
			
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}

		//	----------------------------------------------------------------
		//	PRIVATE METHODS
		//	----------------------------------------------------------------

		private function initialise() : void
		{
			_subdivision = new Subdivision(stage.stageWidth, stage.stageHeight - UI_HEIGHT);
			_subdivision.addEventListener(MouseEvent.CLICK, onSubdivisionClicked);
			_subdivision.addEventListener(Event.COMPLETE, onSubdivisionComplete);
			addChild(_subdivision);
			
			configureListeners();
			buildInterface();
			start();
		}
		
		private function buildInterface() : void
		{
			var xp : int = 10;			var yp : int = stage.stageHeight - UI_HEIGHT + 10;
			
			_useLongestSlider.label = "Regularity:".toUpperCase();
			_useLongestSlider.labelPrecision = 2;			_useLongestSlider.minimum = 0.0;
			_useLongestSlider.maximum = 1.0;			_useLongestSlider.value = 1.0;
			_useLongestSlider.tick = 0.01;			_useLongestSlider.x = xp;			_useLongestSlider.y = yp;
			
			xp += 190;
			
			_useRandomSlider.label = "Random:".toUpperCase();
			_useRandomSlider.labelPrecision = 2;			_useRandomSlider.minimum = 0.0;
			_useRandomSlider.maximum = 0.0;			_useRandomSlider.value = 0.1;			_useRandomSlider.tick = 0.01;			_useRandomSlider.x = xp;			_useRandomSlider.y = yp;
			
			xp += 190;
			
			_subdivideSlider.label = "Density:".toUpperCase();			_subdivideSlider.labelPrecision = 2;			_subdivideSlider.minimum = 0.7;			_subdivideSlider.maximum = 1.0;			_subdivideSlider.value = 0.95;			_subdivideSlider.tick = 0.01;			_subdivideSlider.x = xp;			_subdivideSlider.y = yp;
			
			xp += 190;
			
			_minAvSideSlider.label = "Min Size:".toUpperCase();
			_minAvSideSlider.labelPrecision = 1;			_minAvSideSlider.minimum = 2.0;
			_minAvSideSlider.maximum = 20.0;
			_minAvSideSlider.value = 2.0;
			_minAvSideSlider.tick = 1.0;
			_minAvSideSlider.x = xp;
			_minAvSideSlider.y = yp;
			
			_saveButton.label = "Save JPG".toUpperCase();
			_saveButton.x = stage.stageWidth - _saveButton.width - 10;;
			_saveButton.y = yp;
			
			_subdivision.useLongestSideChance = _useLongestSlider.value;			_subdivision.useRandomPointsChance = _useRandomSlider.value;			_subdivision.subdividePolygonChance = _subdivideSlider.value;			_subdivision.minAverageSideLength = _minAvSideSlider.value;
			
			addChild(_useLongestSlider);			addChild(_useRandomSlider);			addChild(_subdivideSlider);			addChild(_minAvSideSlider);			addChild(_saveButton);
			
			graphics.beginFill(0x111111);
			graphics.drawRect(0, yp - 10, stage.stageWidth, UI_HEIGHT);
			graphics.endFill();
		}
	
		private function configureListeners() : void
		{
			_useLongestSlider.addEventListener(Event.CHANGE, onSliderChanged);			_useRandomSlider.addEventListener(Event.CHANGE, onSliderChanged);			_subdivideSlider.addEventListener(Event.CHANGE, onSliderChanged);			_minAvSideSlider.addEventListener(Event.CHANGE, onSliderChanged);
			_saveButton.addEventListener(MouseEvent.CLICK, onSaveClicked);
		}

		private function start() : void
		{
			_subdivision.reset();
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}

		private function stop() : void
		{
			removeEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		private function save() : void
		{
			stop();
			
			var sw : int = stage.stageWidth;
			var sh : int = stage.stageHeight;
			
			_progress.x = (sw * 0.5) - (_progress.width * 0.5);			_progress.y = (sh * 0.5) - (_progress.height * 0.5);
			_overlay.addChild(_progress);
			
			_saving.x = _progress.x;
			_saving.y = _progress.y - 20;
			_saving.text = "Encoding...".toUpperCase();;
			_overlay.addChild(_saving);
			
			_overlay.graphics.clear();
			_overlay.graphics.beginFill(0x000000, 0.9);
			_overlay.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			_overlay.graphics.endFill();
			addChild(_overlay);
			
			_downloadButton.x = _progress.x;
			_downloadButton.y = _progress.y - 10;
			_downloadButton.label = "Download".toUpperCase();
			
			_encoder.PixelsPerIteration = 2048;
			_encoder.addEventListener(JPEGAsyncCompleteEvent.JPEGASYNC_COMPLETE, onJPEGEncodeComplete);
			_encoder.addEventListener(ProgressEvent.PROGRESS, onJPEGEncoderProgress);
			_encoder.encode(_subdivision.canvas);
		}

		//	----------------------------------------------------------------
		//	EVENT HANDLERS
		//	----------------------------------------------------------------

		private function onAddedToStage(event : Event) : void
		{
			initialise();
		}

		private function onEnterFrame(event : Event) : void
		{
			_subdivision.step(100);
		}
		
		private function onSliderChanged(event : Event) : void
		{
			switch(event.target)
			{
				case _useLongestSlider :
				
					_subdivision.useLongestSideChance = _useLongestSlider.value;
				
					break;
					
				case _useRandomSlider :
				
					_subdivision.useRandomPointsChance = _useRandomSlider.value;
					
					break;
					
				case _subdivideSlider :
				
					_subdivision.subdividePolygonChance = _subdivideSlider.value;
				
					break;
					
				case _minAvSideSlider :
				
					_subdivision.minAverageSideLength = _minAvSideSlider.value;
				
					break;
			}
		}
		
		private function onJPEGEncoderProgress(event : ProgressEvent) : void
		{
			var prog : Number = event.bytesLoaded / event.bytesTotal;
			_saving.text = ("Encoding: " + Math.round(prog * 100) + "%").toUpperCase();;
			_progress.value = prog;
		}

		private function onJPEGEncodeComplete(event : JPEGAsyncCompleteEvent) : void
		{
			_overlay.removeChild(_saving);
			_overlay.removeChild(_progress);
			_overlay.addChild(_downloadButton);
			
			_encoder.removeEventListener(JPEGAsyncCompleteEvent.JPEGASYNC_COMPLETE, onJPEGEncodeComplete);			_encoder.removeEventListener(ProgressEvent.PROGRESS, onJPEGEncoderProgress);
			
			_downloadButton.addEventListener(MouseEvent.CLICK, onDownloadClicked);
			_imageData = event.ImageData;
		}

		private function onDownloadClicked(event : MouseEvent) : void 
		{
			removeChild(_overlay);
			_overlay.removeChild(_downloadButton);
			_downloadButton.removeEventListener(MouseEvent.CLICK, onDownloadClicked);
			new FileReference().save(_imageData, "subdivision_" + new Date().time + ".jpeg");
		}

		private function onSaveClicked(event : MouseEvent) : void
		{
			save();
		}

		private function onSubdivisionComplete(event : Event) : void
		{
			stop();
		}

		private function onSubdivisionClicked(event : MouseEvent) : void 
		{
			start();
		}
	}
}
