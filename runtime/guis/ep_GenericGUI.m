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
h.output = hObj;

guidata(hObj, h);

% Generate a new timer object and then start it
h.GTIMER = ep_GenericGUITimer(h.ep_GenericGUI);
h.GTIMER.TimerFcn = @GenericGUIRunTime;
h.GTIMER.StartFcn = @GenericGUISetup;
h.GTIMER.Period = 0.05; 

start(h.GTIMER);

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





function GenericGUISetup(~,~,f)
% figure handles
h = guidata(f);


p = getpref('ep_GenericGUI','lastPosition',[]);
if ~isempty(p), h.ep_GenericGUI.Position = p; end


guiStr = getpref('ep_GenericGUI','guiStr',{'Data Plot'; 'Trial History'});
h.popup_Launcher.String = [guiStr; {'< ADD GUI >'}];
h.popup_Launcher.Value = 1;

sot = getpref('ep_GenericGUI','stayOnTop',false);
h.stayOnTop.Value = sot;
stay_on_top(h.stayOnTop);


% Setup h.tbl_TrialParameters
setup_tblTrialParameters(h);

update_trials_table(h);

% Setup h.tbl_Triggers
setup_tblTriggers(h);

% Reset session info
update_session_info(h);





function update_session_info(h)
global RUNTIME

trc = RUNTIME.TRIALS.DATA(end).TrialID;
if isempty(trc), trc = '---'; end
h.txt_TrialCount.String = trc;

idx = RUNTIME.TRIALS.NextTrialID;
if isempty(idx), idx = '---'; end
h.txt_ThisTrialIdx.String = idx;

ttind = ismember(RUNTIME.TRIALS.writeparams,'TrialType');
if isempty(idx)
    tt = '---';
else
    tt = RUNTIME.TRIALS.trials{idx,ttind};
end
h.txt_TrialType.String = tt;




function GenericGUIRunTime(timerObj,~,f)
% This function can be used to monitor during an experiment 

% see main help file for this GUI for more info on these global variables
global RUNTIME PRGMSTATE


% persistent variables hold their values across calls to this function
persistent lastupdate


% stop if the program state has changed
if ismember(PRGMSTATE,{'ERROR','STOP'}), stop(timerObj); return; end


% number of trials is length of
ntrials = RUNTIME.TRIALS.DATA(end).TrialID;

if isempty(ntrials)
    ntrials = 0;
    lastupdate = 0;
end

    
% escape timer function until a trial has finished
if ntrials == lastupdate,  return; end
lastupdate = ntrials;
% `````````````````````````````````````````````````````````````````````````
% There was a new trial, so do stuff with new data

% Retrieve a structure of handles to objects on the GUI.
h = guidata(f);

% update_trials_table(h);

update_session_info(h);





function update_trials_table(h)
global RUNTIME


rn = h.tbl_TrialParameters.RowName;
rn(ismember(rn,'ACTIVE')) = [];
wp = RUNTIME.TRIALS.writeparams;
for i = 1:length(wp)
    ind = ismember(rn,wp{i});
    if ~any(ind), continue; end
    tpData(ind,:) = RUNTIME.TRIALS.trials(:,i)'; %#ok<AGROW>
end


% update the table with any changes made by the trial function or something
% else
at = num2cell(RUNTIME.TRIALS.activeTrials);
tpData = [at(:)'; tpData];

% find indices that contain a structure which defines a buffer (usualy wav file)
ind = cellfun(@isstruct,tpData);

% update values for buffers
tpData(ind) = cellfun(@(a) a.file,tpData(ind),'uni',0);

h.tbl_TrialParameters.Data = tpData;








function launch_locate_gui(h)
guiStr = h.popup_Launcher.String;
guiStrSel = guiStr{h.popup_Launcher.Value};

switch guiStrSel
    case 'Online Plot'
        ep_GenericOnlinePlot;
        
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




function setup_tblTrialParameters(h)
global RUNTIME

if isempty(RUNTIME)
    h = errordlg('Something''s wrong. RUNTIME global variable has not been initialized!', ...
        'title','modal');
    uiwait(h);
    return
end

% TRIALS matrix
T = RUNTIME.TRIALS.trials;

% find indices that contain a structure which defines a buffer (usualy wav file)
ind = cellfun(@isstruct,T);

% update values for buffers
T(ind) = cellfun(@(a) a.file,T(ind),'uni',0);

% rotate values so that rows represent parameters
T = T';

% use field names from DATA strcuture for the table column names
fn = RUNTIME.TRIALS.writeparams;


% restrict access to parameters with these prefixes
ind = cellfun(@(a) ismember(a(1),{'~','*','!'}),fn);
T(ind,:) = [];
fn(ind) = [];

% find parameters that have multiple values
for i = 2:size(T,1)
    if ischar(T{i,1})
        nu(i) = numel(unique(T(i,:)));
    else
        nu(i) = numel(unique([T{i,:}]));
    end
end
[nu,idx] = sort(nu,'descend');
uind = nu > 1;
fn = fn(idx);
T  = T(idx,:);

% put the important stuff up top
ttind = ismember(fn,'TrialType');
ridx = [find(ttind) find(~ttind)];
fn = fn(ridx);
T  = T(ridx,:);

% Add a row of checkboxes to allow the user to include/exclude trials
T = [num2cell(true(1,size(T,2))); T];

% add name for first column which controls which trials are active
fn = [{'ACTIVE'} fn];

% add some color
c = repmat([1 1 1; .95 .95 .95],length(fn),1);
c(logical([0 uind]),:) = repmat([1 .95 .7],sum(uind),1);
c = [.3 .8 1; c(2:length(fn),:)];
c(ttind,:) = [.5 .94 .65];

% update table data and info, including original parameters in case user
% wants to reset the table
set(h.tbl_TrialParameters, ...
    'Data',T, ...
    'ColumnEditable',true, ...
    'RowName',fn, ...
    'UserData',RUNTIME.TRIALS.trials, ...
    'BackgroundColor',c, ...
    'CellEditCallback',@tbl_TrialParameters_CellEdit);




function tbl_TrialParameters_CellEdit(hObj,event)
% Respond to updated parameter
if isempty(event.Indices), return; end

row = event.Indices(1);
col = event.Indices(2);

% make certain the new data is valid
if isnumeric(event.NewData)
    NewData = event.NewData;
else
    NewData = str2double(event.NewData);
end
if row > 1 && isnan(NewData)
    hObj.Data{row,col} = event.PreviousData;
    errordlg('Invalid input.  Values must be numeric, finite, real, and scalar','ep_GenericGui','modal');
    return
end


h = guidata(hObj);

h.btn_commitChanges.Enable = 'on';
h.btn_commitChanges.BackgroundColor = [0.2 1 0.2];

h.btn_resetChanges.Enable = 'on';
h.btn_resetChanges.BackgroundColor = [1 0.2 0.2];

drawnow


function commit_changes(h)
global RUNTIME

TBL = h.tbl_TrialParameters;


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





function setup_tblTriggers(h)
global RUNTIME AX

if ~isa(AX,'COM.RPco_x') && ~isa(AX,'COM.TDevAcc_X')
    vprintf(0,1,'ep_GenericGUI:AX Not defined!')
    return
end
% RUNTIME.TRIALS.MODULES names the modules for updates without OpenEx
midx  = struct2array(RUNTIME.TRIALS.MODULES);
fn    = fieldnames(RUNTIME.TRIALS.MODULES);

isOpenEx = RUNTIME.UseOpenEx; % using OpenEx

state = [];
T = {};
tmIdx = [];
for i = 1:length(RUNTIME.TDT.triggers)
    for j = 1:length(RUNTIME.TDT.triggers{i})
        tmIdx(end+1) = RUNTIME.TDT.trigmods(i);

        if isOpenEx
            mname = fn{tmIdx(end) == midx};
            T{end+1} = [mname '.' RUNTIME.TDT.triggers{i}{j}];
            state(end+1) = AX.GetTargetVal(T{end});
        else
            T{end+1} = RUNTIME.TDT.triggers{i}{j};
            state(end+1) = AX(tmIdx(end)).GetTagVal(T{end});
        end
    end
end


if isempty(T)
    set(h.tbl_Triggers, ...
        'Data',{'N/A'}, ...
        'Enable','off', ...
        'UserData',[]);
    return
end

T = [T(:) num2cell(logical(state(:)))];


set(h.tbl_Triggers, ...
    'Data',T, ...
    'Enable','on', ...
    'ColumnWidth',{150,20}, ...
    'ColumnEditable', [false, true], ...
    'ColumnFormat',{'char','logical'}, ...
    'CellEditCallback',@tbl_Triggers_CellEdit, ...
    'UserData',tmIdx);

update_highlight(h.tbl_Triggers,find(state),[1 0.6 0.6]);


function tbl_Triggers_CellEdit(hObj,event)
if isempty(event.Indices), return; end

global AX RUNTIME

row = event.Indices(1);
triggerName = hObj.Data{row,1};
state = single(event.EditData);

% update trigger tag states
tmIdx = hObj.UserData;

if RUNTIME.UseOpenEx
    AX.SetTargetVal(triggerName,state);
else
    AX(tmIdx(row)).SetTagVal(triggerName,state);
end
hObj.Data{row,2} = logical(state);

update_highlight(hObj,find([hObj.Data{:,2}]),[1 0.6 0.6]);










