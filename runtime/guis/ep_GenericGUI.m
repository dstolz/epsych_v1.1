function varargout = ep_GenericGUI(varargin)
% ep_GenericGUI;
%
% In the ep_RunExpt GUI, click "GUI Figure" under the "Function
% Definitions" menu.  This will prompt you to enter the name to this or 
%
% The primary purpose of this GUI is to serve as a modifiable template for
% developing new guiStr for use with EPsych behavior software (ep_RunExpt).
%
% This GUI was created using Matlab's GUIDE utility.  To modify this GUI,
% enter 'guide ep_GenericGUI' in the command window.  Save the GUI as your
% own and modify the GUI and code to suit your needs.
%
%
% Useful global variables
% > RUNTIME contains info about currently running experiment including
% trial data collected so far.
%
% > AX is the ActiveX control being used.  Gives direct programmatic access
% to running RPvds circuit(s).  AX will be a single handle to OpenDeveloper
% activex control, if using OpenEx, or handle(s) to ActiveX control if not
% using OpenEx.  See TDT documentation for more information on using these
% activex controls.  The function TDTpartag can be used to make the same
% code compatible with either activex control.
%
% Also see, TDTpartag
%
% Daniel.Stolzberg@gmail.com 4/2017


% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ep_GenericGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @ep_GenericGUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT










% --- Executes just before ep_GenericGUI is made visible.
function ep_GenericGUI_OpeningFcn(hObj, ~, h, varargin)
global RUNTIME

h.output = hObj;


h = GenericGUISetup(h);

guidata(hObj, h);



% --- Outputs from this function are returned to the command line.
function varargout = ep_GenericGUI_OutputFcn(hObj, ~, h) 
varargout{1} = h.output;



function close_request(f)
global PRGMSTATE

if isequal(PRGMSTATE,'RUNNING')
    h = guidata(f);
    v = h.stayOnTop.Value;
    h.stayOnTop.Value = 0;
    stay_on_top(h.stayOnTop);
    r = questdlg(sprintf('Experiment is still running.  Closing this GUI will not stop the experiment from running.  Use the main control panel to stop the experiment.\n\nWould you like to continue closing this GUI?'), ...
        'ep_GenericGUI','Close Anyway','Cancel','Cancel');
    h.stayOnTop.Value = v;
    stay_on_top(h.stayOnTop);
    if isequal(r,'Cancel'), return; end
end
setpref('ep_GenericGUI','lastPosition',f.Position);

delete(f);





function h = GenericGUISetup(h)

p = getpref('ep_GenericGUI','lastPosition',[]);
if ~isempty(p), h.ep_GenericGUI.Position = p; end


guiStr = getpref('ep_GenericGUI','guiStr',{'Data Plot'; 'Trial History'});
h.popup_Launcher.String = [guiStr; {'< ADD GUI >'}];
h.popup_Launcher.Value = 1;

sot = getpref('ep_GenericGUI','stayOnTop',false);
h.stayOnTop.Value = sot;
stay_on_top(h.stayOnTop);


% Setup h.tbl_Triggers
h.objTriggers = gui.Triggers(h.panel_Triggers);

% Setup session info
h.objTrialCount = gui.TrialCount(h.panel_SessionInfo);



% Setup h.tbl_TrialParameters
h.objParameterTable = gui.ParameterTable(h.panel_TrialParameters);

addlistener(h.objParameterTable,'ParametersModified',@parameters_modified);






function parameters_modified(hObj,event)
f = ancestor(hObj.table,'figure');
h = guidata(f);

h.btn_commitChanges.Enable = 'on';
h.btn_commitChanges.BackgroundColor = [0.2 1 0.2];

h.btn_resetChanges.Enable = 'on';
h.btn_resetChanges.BackgroundColor = [1 0.2 0.2];

drawnow














function launch_locate_gui(h)
guiStr = h.popup_Launcher.String;
guiStrSel = guiStr{h.popup_Launcher.Value};

switch guiStrSel
    case 'Online Plot'
        epsych.OnlinePlot;
        
    case 'Data Plot'
        ep_GenericPlot;
        
    case 'Trial History'
        ep_GenericTrialHistory;
        
    case '< ADD GUI >'
        guiNew = inputdlg('Enter the name of a new GUI function (must be on Matlab''s path):', ...
            'Add GUI',1);
        if isempty(guiNew), return; end
        guiNew = char(guiNew);
        
        w = which(guiNew);
        if isempty(w)
            vprintf(0,1,'The function "%s" was not found along Matlab''s path!',guiNew)
            return
        end
        guiStr = guiStr(:);
        guiStr = [guiStr(1:end-1); guiNew; guiStr(end)];
        h.popup_Launcher.String = guiStr;
        h.popup_Launcher.Value = length(guiStr)-1;
        
        setpref('ep_GenericGUI','guiStr',guiStr(1:end-1));
        
    otherwise
        eval(guiStrSel);
end






function commit_changes(h)
global RUNTIME

TBL = h.objParameterTable.table;


% Update the TRIALS structure with the active trials used by the trial
% selection function
RUNTIME.TRIALS.activeTrials = [TBL.Data{1,:}]';

Data = TBL.Data(2:end,:)';

wp = RUNTIME.TRIALS.writeparams;

rn = TBL.RowName; % table rows may be in a different order than the TRIALS tructure


rn(ismember(rn,'ACTIVE')) = [];
for i = 1:length(wp)
    ind = ismember(rn,wp{i});
    if ~any(ind), continue; end
    RUNTIME.TRIALS.trials(:,i) = Data(:,ind);
end


h.btn_commitChanges.Enable = 'off';
h.btn_commitChanges.BackgroundColor = [0.94 0.94 0.94];

h.btn_resetChanges.Enable = 'off';
h.btn_resetChanges.BackgroundColor = [0.94 0.94 0.94];

drawnow



function update_highlight(hObj,row,highlightColor)
if nargin < 3 || isempty(highlightColor), highlightColor = [0.2 0.6 1]; end
n = size(hObj.Data,1);
c = repmat([1 1 1; 0.9 0.9 0.9],ceil(n/2),1);
c(n+1:end,:) = [];
if ~isempty(row)
    c(row,:) = repmat(highlightColor,numel(row),1);
end

hObj.BackgroundColor = c;













