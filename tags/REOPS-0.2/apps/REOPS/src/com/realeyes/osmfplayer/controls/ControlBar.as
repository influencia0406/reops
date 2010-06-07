package com.realeyes.osmfplayer.controls
{
	import com.realeyes.osmfplayer.events.ControlBarEvent;
	import com.realeyes.osmfplayer.events.RollOutToleranceEvent;
	import com.realeyes.osmfplayer.events.ToggleButtonEvent;
	import com.realeyes.osmfplayer.util.RollOutTolerance;
	
	import flash.display.MovieClip;
	import flash.display.StageDisplayState;
	import flash.events.FullScreenEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	/**
	 * Displays controls for the associated player. 
	 * 
	 * @author	RealEyes Media
	 * @version	1.0
	 */
	public class ControlBar extends SkinElementBase
	{
		
		/////////////////////////////////////////////
		//  DECLARATIONS
		/////////////////////////////////////////////
		
		
		public var bg_mc:MovieClip;
		
		public var play_mc:ToggleButton;
		public var pause_mc:ToggleButton;
		public var playPause_mc:ToggleButton;
		public var volume_mc:ToggleButton;
		public var fullScreen_mc:ToggleButton;
		public var closedCaption_mc:ToggleButton;
		
		public var stop_mc:ToggleButton;
		public var volumeUp_mc:ToggleButton;
		public var volumeDown_mc:ToggleButton;
		
		public var bitrateUp_mc:ToggleButton;
		public var bitrateDown_mc:ToggleButton;
				
		public var progress_mc:ProgressBar;
		
		public var volumeSlider_mc:VolumeSlider;
		
		public var currentTime_txt:TextField;
		public var totalTime_txt:TextField;
		
		public var displayVolumeSliderBelow:Boolean = false;
		
		private var _currentState:String;
		
		public var draggable:Boolean = true;

		private var _volumeSliderRolloutTolerance:RollOutTolerance;
		private var _isLive:Boolean;
		private var _hasCaptions:Boolean;
		
		private var _currentTime:Number;
		private var _duration:Number;
		
		// Added to account for settings in the config using the <element> sub-nodes in <skin>
		public var autoHide:Boolean;
		
		/////////////////////////////////////////////
		//  CONSTRUCTOR
		/////////////////////////////////////////////
		
		public function ControlBar()
		{
			super();
			
			_volumeSliderRolloutTolerance = new RollOutTolerance( volumeSlider_mc, volume_mc );
			
			_initListeners();
			
			if( displayVolumeSliderBelow )
			{
				volumeSlider_mc.y += volumeSlider_mc.height + volume_mc.height;
				//volumeSlider_mc.displayBelow = true;
			}
		}
		
		
		/////////////////////////////////////////////
		//  INIT METHODS
		/////////////////////////////////////////////
		/**
		 * Creates listeners for each of the controls that are present.
		 * 
		 * @return	void
		 */
		private function _initListeners():void
		{
			
			if( play_mc )
			{
				play_mc.toggle = false;
				play_mc.addEventListener( ToggleButtonEvent.TOGGLE_BUTTON_CLICK, _onPlayClick );
			}
			
			if( pause_mc )
			{
				pause_mc.toggle = false;
				pause_mc.addEventListener( ToggleButtonEvent.TOGGLE_BUTTON_CLICK, _onPauseClick );
			}
			
			if( stop_mc )
			{
				stop_mc.toggle = false;
				stop_mc.addEventListener( ToggleButtonEvent.TOGGLE_BUTTON_CLICK, _onStopClick );
			}
			
			if( volumeUp_mc )
			{
				volumeUp_mc.toggle = false;
				volumeUp_mc.addEventListener( ToggleButtonEvent.TOGGLE_BUTTON_CLICK, _onVolumeUpClick );
			}
			
			if( volumeDown_mc )
			{
				volumeDown_mc.toggle = false;
				volumeDown_mc.addEventListener( ToggleButtonEvent.TOGGLE_BUTTON_CLICK, _onVolumeDownClick );
			}
			
			
			if(playPause_mc)
			{
				playPause_mc.addEventListener( ToggleButtonEvent.TOGGLE_BUTTON_CLICK, _onPlayPauseClick );
			}
			
			if(volume_mc)
			{
				volume_mc.addEventListener( ToggleButtonEvent.TOGGLE_BUTTON_CLICK, _onVolumeClick );
				volume_mc.addEventListener( MouseEvent.MOUSE_OVER, _onVolumeOver );
				volume_mc.addEventListener( MouseEvent.MOUSE_OUT, _onVolumeOut );
			}
			
			if(fullScreen_mc)
			{
				fullScreen_mc.addEventListener( ToggleButtonEvent.TOGGLE_BUTTON_CLICK, _onfullScreenClick );
			}
			
			if(closedCaption_mc)
			{
				closedCaption_mc.addEventListener( ToggleButtonEvent.TOGGLE_BUTTON_CLICK, _onClosedCaptionClick );
			}
			
			if(bitrateUp_mc)
			{
				bitrateUp_mc.toggle = false;
				bitrateUp_mc.addEventListener( ToggleButtonEvent.TOGGLE_BUTTON_CLICK, _onBitrateUpClick );
			}
			
			if(bitrateDown_mc)
			{
				bitrateDown_mc.toggle = false;
				bitrateDown_mc.addEventListener( ToggleButtonEvent.TOGGLE_BUTTON_CLICK, _onBitrateDownClick );
			}
			
			if(bg_mc)
			{
				bg_mc.addEventListener( MouseEvent.MOUSE_DOWN, _onBGDown );
				bg_mc.addEventListener( MouseEvent.MOUSE_UP, _onBGUp );
			}
			
			_volumeSliderRolloutTolerance.addEventListener( RollOutToleranceEvent.TOLERANCE_OUT, _onVolumeSliderTolleranceOut );
		}
		
		/////////////////////////////////////////////
		//  CONTROL/METHODS
		/////////////////////////////////////////////
		/**
		 * Takes a number of seconds and returns it in the format
		 * of M:SS.
		 * 
		 * @param	p_time	(Number) the time in seconds
		 * @return	String
		 */
		private function formatSecondsToString( p_time:Number ):String
		{
			var min:Number = Math.floor( p_time / 60 );
			var sec:Number = p_time % 60;
			
			return min + ":" + ( sec.toString().length < 2 ? "0" + sec : sec );
		}
		
		/**
		 * Sets the percentage of the current progress indicator to the given
		 * percentage of the progress bar
		 * 
		 * @param	p_value	(Number) percentage of the bar to set the progress indicator at
		 * @return	void
		 */
		public function setCurrentBarPercent( p_value:Number ):void
		{
			progress_mc.setCurrentBarPercent( p_value );
		}
		
		/**
		 * Sets the percentage of the loading indicator to the given
		 * percentage of the progress bar
		 * 
		 * @param	p_value	(Number) percentage of the bar to set the progress indicator at
		 * @return	void
		 */
		public function setLoadBarPercent( p_value:Number ):void
		{
			progress_mc.setLoadBarPercent( p_value );
		}
		
		/**
		 * Enables manual selection of a higher bitrate stream, if it exists
		 * 
		 * @return	void
		 */
		public function bitrateUpEnabled():void
		{
			if( bitrateUp_mc )
			{
				bitrateUp_mc.enabled = true;
			}
		}
		
		/**
		 * Enables manual selection of a lower bitrate stream, if it exists
		 * 
		 * @return	void
		 */
		public function bitrateDownEnabled():void
		{
			if( bitrateDown_mc )
			{
				bitrateDown_mc.enabled = true;
			}
		}
		
		/**
		 * Disables manual selection of a higher bitrate stream
		 * 
		 * @return	void
		 */
		public function bitrateUpDisabled():void
		{
			if( bitrateDown_mc )
			{
				bitrateUp_mc.enabled = false;
			}
		}
		
		
		/**
		 * Disables manual selection of a lower bitrate stream
		 * 
		 * @return	void
		 */
		public function bitrateDownDisabled():void
		{
			if( bitrateDown_mc )
			{
				bitrateDown_mc.enabled = false;
			}
		}
		
		
		
		/////////////////////////////////////////////
		//  GETTER/SETTERS
		/////////////////////////////////////////////
		/**
		 * height
		 * Height of the background or the containing clip
		 * @return	Number
		 */
		override public function get height():Number
		{
			if( bg_mc )
			{
				return bg_mc.height;
			}
				
			return super.height;
			
		}
		
		/**
		 * isLive
		 * Is the media playing live?
		 * @return	Boolean
		 */
		public function get isLive():Boolean
		{
			return _isLive;
		}
		
		public function set isLive( p_value:Boolean ):void
		{
			_isLive = p_value;
			
			if( progress_mc )
			{
				progress_mc.isLive = _isLive;
			}
		}
		
		/**
		 * currentTime
		 * The current time in seconds.
		 * @return	Number
		 */
		public function get currentTime():Number
		{
			return _currentTime;
		}
		
		public function set currentTime( p_value:Number ):void
		{
			_currentTime = p_value;
			currentTime_txt.text = formatSecondsToString( p_value );
		}
		
		/**
		 * duration
		 * The length of the media in seconds.
		 * @return	Number
		 */
		public function get duration():Number
		{
			return _duration;
		}
		
		public function set duration( p_value:Number ):void
		{
			_duration = p_value;
			totalTime_txt.text = formatSecondsToString( p_value );
		}
		
		/**
		 * currentState
		 * The current state. Options include: 'stopped', 'paused', and 'playing'
		 * @return	String
		 */
		public function get currentState():String
		{
			return _currentState;
		}
		
		public function set currentState( p_value:String ):void
		{
			_currentState = p_value;
			
			
			
			switch( _currentState )
			{
				case "stopped" :
				case "paused" :
				{
					
					if( playPause_mc && !playPause_mc.selected)
					{
						playPause_mc.selected = true;
					}
					
					break;
				}
				case "playing" :
				{
					
					if( playPause_mc && playPause_mc.selected)
					{
						playPause_mc.selected = false;
					}
					break;
				}
			}
			
		}
		
		
		/**
		 * hasCaptions	
		 * Should the control enable the closed caption controls if they exist
		 * @return	Boolean
		 */
		public function get hasCaptions():Boolean
		{
			return _hasCaptions;
		}
		
		public function set hasCaptions( p_value:Boolean ):void
		{
			_hasCaptions = p_value;
			
			if( closedCaption_mc )
			{
				closedCaption_mc.enabled = _hasCaptions;
			}
		}
		
		
		/////////////////////////////////////////////
		//  HANDLERS
		/////////////////////////////////////////////
		/**
		 * Dispatches ControlBarEvent.PLAY when Play button is clicked
		 * 
		 * @param	p_evt	(ToggleButtonEvent) click event
		 * @return	void
		 */
		private function _onPlayClick( p_evt:ToggleButtonEvent ):void
		{
			this.dispatchEvent( new ControlBarEvent( ControlBarEvent.PLAY ) );
		}
		
		/**
		 * Dispatches ControlBarEvent.PAUSE when Pause button is clicked
		 * 
		 * @param	p_evt	(ToggleButtonEvent) click event
		 * @return	void
		 */
		private function _onPauseClick( p_evt:ToggleButtonEvent ):void
		{
			this.dispatchEvent( new ControlBarEvent( ControlBarEvent.PAUSE ) );
		}
		
		/**
		 * Dispatches ControlBarEvent.PLAY or ControlBarEvent.PAUSE when 
		 * Pause/Play button is toggled
		 * 
		 * @param	p_evt	(ToggleButtonEvent) click event
		 * @return	void
		 */
		private function _onPlayPauseClick( p_evt:ToggleButtonEvent ):void
		{
			if( p_evt.selected)
			{
				//trace("disp - PAUSE");
				_onPauseClick( p_evt );
			}
			else
			{
				//trace("disp - PLAY");
				_onPlayClick( p_evt );
			}
		}
		
		/**
		 * Dispatches ControlBarEvent.MUTE or ControlBarEvent.UNMUTE when 
		 * the Volume button is clicked
		 * 
		 * @param	p_evt	(ToggleButtonEvent) click event
		 * @return	void
		 */
		private function _onVolumeClick( p_evt:ToggleButtonEvent ):void
		{
			if( p_evt.selected)
			{
				this.dispatchEvent( new ControlBarEvent( ControlBarEvent.MUTE ) );
			}
			else
			{
				this.dispatchEvent( new ControlBarEvent( ControlBarEvent.UNMUTE ) );
			}
		}
		
		
		/**
		 * Display the volume slider when rolled over
		 * 
		 * @param	p_evt	(MouseEvent) Mouse Over event
		 * @return	void
		 */
		private function _onVolumeOver( p_evt:MouseEvent ):void
		{
			volumeSlider_mc.visible = true;
		}
		
		
		/**
		 * Hide the volume slider when rolled over
		 * 
		 * @param	p_evt	(MouseEvent) Mouse Out event
		 * @return	void
		 */
		private function _onVolumeOut( p_evt:MouseEvent ):void
		{
			_volumeSliderRolloutTolerance.start();
		}
		
		
		
		/**
		 * Dispatches ControlBarEvent.FULLSCREEN or ControlBarEvent.FULLSCREEN_RETURN 
		 * when the fullscreen button is toggled
		 * 
		 * @param	p_evt	(ToggleButtonEvent) click event
		 * @return	void
		 */
		private function _onfullScreenClick( p_evt:ToggleButtonEvent ):void
		{
			if( p_evt.selected)
			{
				this.dispatchEvent( new ControlBarEvent( ControlBarEvent.FULLSCREEN ) );
				
				stage.addEventListener( FullScreenEvent.FULL_SCREEN, _onFullScreen );
			}
			else
			{
				this.dispatchEvent( new ControlBarEvent( ControlBarEvent.FULLSCREEN_RETURN ) );
			}
		}
		
		/**
		 * When the player returns to normal from fullscreen mode, make sure the fullscreen
		 * button gets updated
		 * 
		 * @param	p_evt	(FullScreenEvent)
		 * @return	void
		 */
		private function _onFullScreen( p_evt:FullScreenEvent ):void
		{
			if( stage.displayState == StageDisplayState.NORMAL && fullScreen_mc.selected )
			{
				fullScreen_mc.selected = false;
			}
		}
		
		/**
		 * Dispatches ControlBarEvent.SHOW_CLOSEDCAPTION or ControlBarEvent.HIDE_CLOSEDCAPTION 
		 * when the closed caption button is toggled
		 * 
		 * @param	p_evt	(ToggleButtonEvent) click event
		 * @return	void
		 */
		private function _onClosedCaptionClick( p_evt:ToggleButtonEvent ):void
		{
			if( p_evt.selected)
			{
				this.dispatchEvent( new ControlBarEvent( ControlBarEvent.SHOW_CLOSEDCAPTION ) );
			}
			else
			{
				this.dispatchEvent( new ControlBarEvent( ControlBarEvent.HIDE_CLOSEDCAPTION ) );
			}
		}
		
		/**
		 * For draggable control bars, starts the dragging when the
		 * BG is clicked on.
		 * 
		 * @param	p_evt	(MouseEvent) mouse down event
		 * @return	void
		 */
		private function _onBGDown( p_evt:MouseEvent ):void
		{
			if( draggable )
			{
				this.startDrag();
			}
		}
		
		/**
		 * For draggable control bars, ends the dragging when the
		 * BG is released.
		 * 
		 * @param	p_evt	(MouseEvent) mouse up event
		 * @return	void
		 */
		private function _onBGUp( p_evt:MouseEvent ):void
		{
			if( draggable )
			{
				this.stopDrag();				
			}
		}
		
		
		/**
		 * Dispatches ControlBarEvent.STOP when Stop button is clicked
		 * 
		 * @param	p_evt	(ToggleButtonEvent) click event
		 * @return	void
		 */
		private function _onStopClick( p_evt:ToggleButtonEvent ):void
		{
			this.dispatchEvent( new ControlBarEvent( ControlBarEvent.STOP ) );
		}

		/**
		 * Hide the volume slider when rolled out from.
		 * 
		 * @param	p_evt	(RollOutToleranceEvent)
		 * @return	void
		 */
		private function _onVolumeSliderTolleranceOut( p_evt:RollOutToleranceEvent ):void
		{
			volumeSlider_mc.visible = false;
		}
		
		/**
		 * Dispatches ControlBarEvent.VOLUME_UP when Volume Up button is clicked
		 * 
		 * @param	p_evt	(ToggleButtonEvent) click event
		 * @return	void
		 */
		private function _onVolumeUpClick( p_evt:ToggleButtonEvent ):void
		{
			this.dispatchEvent( new ControlBarEvent( ControlBarEvent.VOLUME_UP ) );
		}
		
		/**
		 * Dispatches ControlBarEvent.VOLUME_DOWN when Volume Down button is clicked
		 * 
		 * @param	p_evt	(ToggleButtonEvent) click event
		 * @return	void
		 */
		private function _onVolumeDownClick( p_evt:ToggleButtonEvent ):void
		{
			this.dispatchEvent( new ControlBarEvent( ControlBarEvent.VOLUME_DOWN ) );
		}
		
		/**
		 * Dispatches ControlBarEvent.BITRATE_UP when Bitrate Up button is clicked
		 * 
		 * @param	p_evt	(ToggleButtonEvent) click event
		 * @return	void
		 */
		private function _onBitrateUpClick( p_evt:ToggleButtonEvent ):void
		{
			this.dispatchEvent( new ControlBarEvent( ControlBarEvent.BITRATE_UP ) );
		}
		
		/**
		 * Dispatches ControlBarEvent.BITRATE_DOWN when Bitrate Down button is clicked
		 * 
		 * @param	p_evt	(ToggleButtonEvent) click event
		 * @return	void
		 */
		private function _onBitrateDownClick( p_evt:ToggleButtonEvent ):void
		{
			this.dispatchEvent( new ControlBarEvent( ControlBarEvent.BITRATE_DOWN ) );
		}
	
		
	}
}