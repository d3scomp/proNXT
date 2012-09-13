function mdderslib_track_map(block)
setup(block);
%end mdderslib_trackmap

%% Function: setup ===================================================
%% Abstract:
%%   Set up the basic characteristics of the S-function block such as:
%%   - Input ports
%%   - Output ports
%%   - Dialog parameters
%%   - Options
%%
%%   Required         : Yes
%%   C-Mex counterpart: mdlInitializeSizes
%%
function setup(block)

% Register number of ports
block.NumInputPorts  = 3;
block.NumOutputPorts = 0;

% Setup port properties to be inherited or dynamic
block.SetPreCompInpPortInfoToDynamic;

% Override input port properties
block.InputPort(1).Dimensions  = 1;
block.InputPort(1).DatatypeID  = 0;  % double
block.InputPort(1).Complexity  = 'Real';
block.InputPort(1).DirectFeedthrough = false;

block.InputPort(2).Dimensions  = 1;
block.InputPort(2).DatatypeID  = 0;  % double
block.InputPort(2).Complexity  = 'Real';
block.InputPort(2).DirectFeedthrough = false;

block.InputPort(3).Dimensions  = 1;
block.InputPort(3).DatatypeID  = 0;  % double
block.InputPort(3).Complexity  = 'Real';
block.InputPort(3).DirectFeedthrough = false;

% Register parameters
block.NumDialogPrms     = 2;
block.DialogPrmsTunable = {'Nontunable', 'Nontunable'};

% Register sample times
%  [-1, 0]             : Inherited sample time
block.SampleTimes = [0.1 0];

% Specify the block simStateCompliance. The allowed values are:
%    'UnknownSimState', < The default setting; warn and assume DefaultSimState
%    'DefaultSimState', < Same sim state as a built-in block
%    'HasNoSimState',   < No sim state
%    'CustomSimState',  < Has GetSimState and SetSimState methods
%    'DisallowSimState' < Error out when saving or restoring the model sim state
block.SimStateCompliance = 'HasNoSimState';

%% -----------------------------------------------------------------
%% The MATLAB S-function uses an internal registry for all
%% block methods. You should register all relevant methods
%% (optional and required) as illustrated below. You may choose
%% any suitable name for the methods and implement these methods
%% as local functions within the same file. See comments
%% provided for each function for more information.
%% -----------------------------------------------------------------

block.RegBlockMethod('PostPropagationSetup',    @DoPostPropSetup);
block.RegBlockMethod('Start', @Start);
block.RegBlockMethod('Outputs', @Outputs);     % Required
block.RegBlockMethod('Update', @Update);
block.RegBlockMethod('Terminate', @Terminate); % Required
block.RegBlockMethod('CheckParameters', @CheckParam);

%end setup

function CheckParam(s)

% Check that upper limit is greater than lower limit
%error('The upper limit must be greater than the lower limit.');


%%
%% PostPropagationSetup:
%%   Functionality    : Setup work areas and state variables. Can
%%                      also register run-time methods here
%%   Required         : No
%%   C-Mex counterpart: mdlSetWorkWidths
%%
function DoPostPropSetup(block)

block.NumDworks = 5;
  
block.Dwork(1).Name            = 'FigureHandle';
block.Dwork(1).Dimensions      = 1;
block.Dwork(1).DatatypeID      = 0;      % double
block.Dwork(1).Complexity      = 'Real'; % real
block.Dwork(1).UsedAsDiscState = false;

block.Dwork(2).Name            = 'VehicleHandle';
block.Dwork(2).Dimensions      = 1;
block.Dwork(2).DatatypeID      = 0;      % double
block.Dwork(2).Complexity      = 'Real'; % real
block.Dwork(2).UsedAsDiscState = false;

block.Dwork(3).Name            = 'LineHandle';
block.Dwork(3).Dimensions      = 1;
block.Dwork(3).DatatypeID      = 0;      % double
block.Dwork(3).Complexity      = 'Real'; % real
block.Dwork(3).UsedAsDiscState = false;

block.Dwork(4).Name            = 'LastXY';
block.Dwork(4).Dimensions      = 2;
block.Dwork(4).DatatypeID      = 0;      % double
block.Dwork(4).Complexity      = 'Real'; % real
block.Dwork(4).UsedAsDiscState = false;

block.Dwork(5).Name            = 'TrackingPosM';
block.Dwork(5).Dimensions      = 2;
block.Dwork(5).DatatypeID      = 0;      % double
block.Dwork(5).Complexity      = 'Real'; % real
block.Dwork(5).UsedAsDiscState = false;

%end DoPostPropSetup


%%
%% Start:
%%   Functionality    : Called once at start of model execution. If you
%%                      have states that should be initialized once, this 
%%                      is the place to do it.
%%   Required         : No
%%   C-MEX counterpart: mdlStart
%%
function Start(block)

trackingPosM = [0.09 0];
trackSamplesPerM = block.DialogPrm(2).Data;
tmpTrackCData = block.DialogPrm(1).Data;
for i = 1:3; trackCData(:,:,i) = (tmpTrackCData(:,:,i) / max(max(tmpTrackCData(:,:,i))))'; end


trackXSize = size(trackCData, 2) / trackSamplesPerM;
trackYSize = size(trackCData, 1) / trackSamplesPerM;

[vehCData, vehCMap, vehAData] = imread('mdderslib_track_vehicle.png');
vehSamplesPerM = 1000;

vehXSize = size(vehCData, 2) / vehSamplesPerM;
vehYSize = size(vehCData, 1) / vehSamplesPerM;

userData = get_param(block.BlockHandle, 'UserData');
if ~isempty(userData) && ishandle(userData(1)) && ishandle(userData(2)) && ishandle(userData(3))
  hFig = userData(1);
  hTr = userData(2);
  
  hLine = userData(3);
  delete(get(hLine, 'Children'));
else
  hFig = figure('Name', 'Follower simulation', 'NumberTitle', 'off');
  hAx = axes('Parent', hFig, 'XLim', [0 trackXSize], 'YLim', [0 trackYSize], 'DataAspectRatio', [1 1 1]);
  hTrack = surface('Parent', hAx, 'XData', [0 trackXSize], 'YData', [0 trackYSize], 'ZData', [0 0; 0 0], 'EdgeColor', 'none', 'FaceColor', 'texturemap', 'CData', trackCData);
  hTr = hgtransform('Parent', hAx);
  hRect = surface('Parent', hTr, 'XData', [-(vehXSize/2) vehXSize/2], 'YData', [vehYSize/2 -(vehYSize/2)], 'ZData', [0 0; 0 0], 'EdgeColor', 'none', 'FaceColor', 'texturemap', 'FaceAlpha', 'texturemap', 'CData', vehCData, 'AlphaData', vehAData);
  hLine = hggroup('Parent', hAx);
  
  set_param(block.BlockHandle, 'UserData', [hFig, hTr, hLine]);
end

block.Dwork(1).Data = hFig;
block.Dwork(2).Data = hTr;
block.Dwork(3).Data = hLine;
block.Dwork(4).Data = [NaN NaN];
block.Dwork(5).Data = trackingPosM;
%end Start

%%
%% Outputs:
%%   Functionality    : Called to generate block outputs in
%%                      simulation step
%%   Required         : Yes
%%   C-MEX counterpart: mdlOutputs
%%
function Outputs(block)
%end Outputs

%%
%% Update:
%%   Functionality    : Called to update discrete states
%%                      during simulation step
%%   Required         : No
%%   C-MEX counterpart: mdlUpdate
%%
function Update(block)

angle = block.InputPort(1).Data;
x = block.InputPort(2).Data;
y = block.InputPort(3).Data;

trackingPosM = block.Dwork(5).Data;
[trackingPosMTheta, trackingPosMRho] = cart2pol(trackingPosM(1), trackingPosM(2));
[trackingX, trackingY] = pol2cart(trackingPosMTheta + angle, trackingPosMRho);

trackingX = x + trackingX;
trackingY = y + trackingY;

hTr = block.Dwork(2).Data;
hLine = block.Dwork(3).Data;

if ishandle(hTr)
    trT = makehgtform('translate', [x y 0.01]);
    trR = makehgtform('zrotate', angle);
    set(hTr, 'Matrix', trT * trR);

    lastTrackingX = block.Dwork(4).Data(1);
    lastTrackingY = block.Dwork(4).Data(2);

    if ~(isnan(lastTrackingX) && isnan(lastTrackingY))
        line([lastTrackingX trackingX], [lastTrackingY trackingY], [0 0], 'Color', 'g', 'Parent', hLine);
    end

    drawnow;
end

block.Dwork(4).Data = [trackingX trackingY];
%end Update

%%
%% Terminate:
%%   Functionality    : Called at the end of simulation for cleanup
%%   Required         : Yes
%%   C-MEX counterpart: mdlTerminate
%%
function Terminate(block)

%end Terminate

