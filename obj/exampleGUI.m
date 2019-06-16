%% How to create a custom GUI with EPsych GUI objects 

global RUNTIME % Need to pass RUNTIME to GUI objects
global AX % Need to pass AX to the GUI objects that access the TDT hardware directly using ActiveX

% Create a new figure for the GUI objects.
f = figure('Name','Basic EPsych GUI','NumberTitle','off','Position',[400 150 700 450]);

% Create containers for GUI objects:

% Plotting objects requires an axes container - an axes object will be
% created if another type of container (figure or uipanel) is specified.
axPsychPlot  = axes(f,'Units','Normalized','Position',[0.1 0.1 0.3 0.5]);
axOnlinePlot = axes(f,'Units','Normalized','Position',[0.1 0.78 .85 0.2]);

% Information objects require uipanel objects.
pHistory     = uipanel(f,'Units','Normalized','Position',[0.5 0.05 0.45 0.55]);


% Create the psychophysics object
D = psychophysics.Detection;

% Create the OnlinePlot object and assign it to the axOnlinePlot container
watchedParameters = {'!TrialDelivery','~InTrial_TTL','~DelayPeriod', ...
    '~RespWindow','~Spout_TTL','~ShockOn','~GO_Stim','~NOGO_Stim'};
BoxID = 1;
O = gui.OnlinePlot(RUNTIME,AX,watchedParameters,axOnlinePlot,BoxID);

% Create the PsychPlot object and assign it to the axPsychPlot container
P = gui.PsychPlot(D,RUNTIME.HELPER,axPsychPlot);

% Create the trial History object and assign it to the pHistory container
H = gui.History(D,RUNTIME.HELPER,pHistory);