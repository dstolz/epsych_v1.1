function varargout = ep_GenericTrialHistory(varargin)
% EP_GENERICTRIALHISTORY MATLAB code for ep_GenericTrialHistory.fig
%      EP_GENERICTRIALHISTORY, by itself, creates a new EP_GENERICTRIALHISTORY or raises the existing
%      singleton*.
%
%      H = EP_GENERICTRIALHISTORY returns the handle to a new EP_GENERICTRIALHISTORY or the handle to
%      the existing singleton*.
%
%      EP_GENERICTRIALHISTORY('CALLBACK',hObj,event,h,...) calls the local
%      function named CALLBACK in EP_GENERICTRIALHISTORY.M with the given input arguments.
%
%      EP_GENERICTRIALHISTORY('Property','Value',...) creates a new EP_GENERICTRIALHISTORY or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ep_GenericTrialHistory_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ep_GenericTrialHistory_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ep_GenericTrialHistory

% Last Modified by GUIDE v2.5 09-May-2019 10:19:53

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ep_GenericTrialHistory_OpeningFcn, ...
                   'gui_OutputFcn',  @ep_GenericTrialHistory_OutputFcn, ...
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


% --- Executes just before ep_GenericTrialHistory is made visible.
function ep_GenericTrialHistory_OpeningFcn(hObj, event, h, varargin)
% Choose default command line output for ep_GenericTrialHistory
h.output = hObj;

% Update h structure
guidata(hObj, h);

% --- Outputs from this function are returned to the command line.
function varargout = ep_GenericTrialHistory_OutputFcn(hObj, event, h) 
% Get default command line output from h structure
varargout{1} = h.output;


% Generate a new timer object and then start it
h.GTIMER = ep_GenericGUITimer(h.ep_GenericTrialHistory);
h.GTIMER.TimerFcn = @GUITimerRunTime;
h.GTIMER.StartFcn = @GUITimerSetup;

start(h.GTIMER);

sot = getpref('ep_GenericTrialHistory','stayOnTop',false);
h.stayOnTop.Value = sot;
stay_on_top(h.stayOnTop);

guidata(h.ep_GenericTrialHistory,h);

function GUITimerSetup(~,~,f)
global RUNTIME
h = guidata(f);


% RUNTIME.TRIALS.DATA is a structure with fields named after variables
% (note that the names may be slightly altered from their real version so
% that they are valid structure field names)

% Call a function to rearrange DATA to make it easier to use (see below).
[DATA,INFO] = rearrange_data(RUNTIME.TRIALS.DATA);

% Display each trial in the GUI table h.tbl_trialHistory ------------------
h = guidata(f);

% Flip the DATA matrix so that the most recent trials are displayed at the
% top of the table.
set(h.tbl_trialHistory,'Data',flipud(DATA));

% set the row names as the trial ids
set(h.tbl_trialHistory,'RowName',flipud(INFO.TrialID));

% set the column names
set(h.tbl_trialHistory,'ColumnName',INFO.fields);





function GUITimerRunTime(timerObj,~,f)
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

    
% escape timer function until the next trial has finished
if ntrials == lastupdate,  return; end
lastupdate = ntrials;
% `````````````````````````````````````````````````````````````````````````

% this shouldn't happen, but just in case
if isempty(RUNTIME.TRIALS.DATA(end).ResponseCode), return; end

% Call a function to rearrange DATA to make it easier to use (see below).
[DATA,INFO] = rearrange_data(RUNTIME.TRIALS.DATA);

% Display each trial in the GUI table h.tbl_trialHistory ------------------
h = guidata(f);

% Flip the DATA matrix so that the most recent trials are displayed at the
% top of the table.
set(h.tbl_trialHistory,'Data',flipud(DATA));

% set the row names as the trial ids
set(h.tbl_trialHistory,'RowName',flipud(INFO.TrialID));

% set the column names
set(h.tbl_trialHistory,'ColumnName',INFO.fields);





% -------------------------------------------------------------------------
function [DATAout,INFO] = rearrange_data(DATAin)
% Access some fields from DATA that are automatically generated by EPsych.
% Note that while the following is just fine, it is coded here for clarity
% and relative ease of use.  You can modify this function for your own
% needs.


% Use Response Code bitmask to compute behavior performance
INFO.ResponseCode = [DATAin.ResponseCode]';

% Trial numbers
INFO.TrialID = [DATAin.TrialID]';


% Crude timestamp of when the trial occured.  This is not indended for use
% in data analysis.  Only use timestamps generated by the TDT hardware
% since it is much more accurate and precise.
INFO.ComputerTimestamp = cellfun(@(a) datestr(a,'HH:MM:SS.FFF'),{DATAin.ComputerTimestamp}','uni',0);


% remove these fields
DATAin = rmfield(DATAin,{'ResponseCode','TrialID','ComputerTimestamp'});


% The remaining fields of the DATA structure contain parameters for each
% trial.
fieldsin = fieldnames(DATAin);


% % Remove the leading module alias
% INFO.fields = cellfun(@(a) (a(find(a=='_',1))),fieldsin,'uni',0);

% The following for loop will vectorize fields of the structure DATAin and
% tored in a NxM matrix called DATAout. M is the number of fields in
% DATAin, and N is the number of trials so far.
% Since we don't know the field names of structure ahead of time (changes
% for each experiment), we use dynamic field names (search Matlab
% documentation for more info).
for i = 1:length(fieldsin)
    DATAout(:,i) = [DATAin.(fieldsin{i})];
end

% prefix ComputerTimestamp and ResponseCode fields
DATAout = num2cell(DATAout);
DATAout = [num2cell(INFO.ResponseCode) DATAout];
DATAout = [INFO.ComputerTimestamp DATAout];

INFO.fields = [{'Time'};{'Code'};fieldsin];




function scroll_to(what,h)

tbl = h.tbl_trialHistory;

% move the scroll bar


