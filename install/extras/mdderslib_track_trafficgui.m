function mdderslib_track_trafficgui(block)
setup(block);
%end

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
block.NumInputPorts  = 4;
block.NumOutputPorts = 2;

% Override input port properties

% BT packet
block.InputPort(1).Dimensions  = 32;
block.InputPort(1).DatatypeID  = 3;  % uint8
block.InputPort(1).SamplingMode = 'Sample';
block.InputPort(1).Complexity  = 'Real';
block.InputPort(1).DirectFeedthrough = false;

% Real X-Pos
block.InputPort(2).Dimensions  = 1;
block.InputPort(2).DatatypeID  = 0;  % double
block.InputPort(2).SamplingMode = 'Sample';
block.InputPort(2).Complexity  = 'Real';
block.InputPort(2).DirectFeedthrough = false;

% Real Y-YPos
block.InputPort(3).Dimensions  = 1;
block.InputPort(3).DatatypeID  = 0;  % double
block.InputPort(3).SamplingMode = 'Sample';
block.InputPort(3).Complexity  = 'Real';
block.InputPort(3).DirectFeedthrough = false;

% Real Angle
block.InputPort(4).Dimensions  = 1;
block.InputPort(4).DatatypeID  = 0;  % double
block.InputPort(4).SamplingMode = 'Sample';
block.InputPort(4).Complexity  = 'Real';
block.InputPort(4).DirectFeedthrough = false;


% BT packet
block.OutputPort(1).Dimensions  = 32;
block.OutputPort(1).DatatypeID  = 3;  % uint8
block.OutputPort(1).SamplingMode  = 'Sample';
block.OutputPort(1).Complexity  = 'Real';

% Other robots positions (posX, posY, angle)
block.OutputPort(2).Dimensions  = [block.DialogPrm(3).Data, 3];
block.OutputPort(2).DatatypeID  = 0;  % double
block.OutputPort(2).SamplingMode  = 'Sample';
block.OutputPort(2).Complexity  = 'Real';


% Register parameters (addr, name, otherRobotsNo)
block.NumDialogPrms     = 3;
block.DialogPrmsTunable = {'Nontunable', 'Nontunable', 'Nontunable'};

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

block.NumDworks = 0;
  
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

global trafficIDEClient;
trafficIDEClient = cz.cuni.d3s.mdders.traffic.ide.comm.SimulinkClient(block.DialogPrm(1).Data, block.DialogPrm(2).Data);

%end Start

%%
%% Outputs:
%%   Functionality    : Called to generate block outputs in
%%                      simulation step
%%   Required         : Yes
%%   C-MEX counterpart: mdlOutputs
%%
function Outputs(block)
global trafficIDEClient;

packet = block.InputPort(1).Data;
x = block.InputPort(2).Data;
y = block.InputPort(3).Data;
angle = block.InputPort(4).Data;

result = trafficIDEClient.update(typecast(packet, 'int8'), cz.cuni.d3s.mdders.traffic.ide.node.RobotPosition(x, y, angle));

block.OutputPort(1).Data = typecast(result.packet, 'uint8');

orObjects = result.otherRobots.toArray();
otherRobots = zeros(block.DialogPrm(3).Data, 3);

for i = 1:min(size(otherRobots,1), size(orObjects,1))
	otherRobots(i,1) = orObjects(i).x; 
	otherRobots(i,2) = orObjects(i).y; 
	otherRobots(i,3) = orObjects(i).angle;
end

block.OutputPort(2).Data = otherRobots;

%end Outputs

%%
%% Terminate:
%%   Functionality    : Called at the end of simulation for cleanup
%%   Required         : Yes
%%   C-MEX counterpart: mdlTerminate
%%
function Terminate(block)

global trafficIDEClient;
trafficIDEClient.disconnect();

%end Terminate

