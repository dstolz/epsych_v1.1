classdef TDTSynapse < epsych.hw.Hardware
% TODO: UPDATE WITH ACTUAL TDT SYNAPSE API.  THIS WAS BUILT FOR TESTING PURPOSES ONLY.

    properties (Constant) % define constant abstract properties from superclass
        Name         = 'TDTSynapseAPI';
        Type         = 'COM.Synapse'; % NOT ACTUAL NAME OF CLASS
        Description  = 'Interface with TDT Synapse';
        MaxNumInstances = 1;
    end

    properties % define publilc abstract properties from superclass
        State          
    end

    
    properties (SetAccess = private)
        handle              % handle to ActiveX

        InterfaceParent     % matlab.ui.container
    end

    properties (Access = private)
        ConnectionTypeDropDownLabel  matlab.ui.control.Label
        ConnectionTypeDropDown       matlab.ui.control.DropDown
        TDTModulesTable         matlab.ui.control.Table
        AddModuleButton         matlab.ui.control.Button
        RemoveModuleButton      matlab.ui.control.Button
    end
    
    properties
        Parameters

        ConnectionType (1,:) char {mustBeMember(ConnectionType,{'GB','USB'})} = 'GB';
        ModuleAlias    (1,:) char
        Module         (1,:) char {mustBeMember(Module,{'Undefined','RP2','RA16','RL2','RV8','RX5','RX6','RX7','RX8','RZ2','RZ5','RZ6','RM1','RM2'})} = 'Undefined';
        ModuleID       (1,1) double {mustBePositive,mustBeInteger} = 1;
        RPvdsFile      (1,:) char
        Fs             (1,1) double {mustBePositive,mustBeFinite} = 24414.0625; % Hz
    end


    properties (Dependent)
        Status
        FsInt
    end

    properties (Access = private)
        emptyFig
    end

    methods
        interface(obj,parent);
        prepare(obj);

        write(obj,parameter,value);
        v = read(obj,parameter);
        e = trigger(obj,parameter);

        function obj = TDTSynapse
            % call superclass constructor
            obj = obj@epsych.hw.Hardware;
        end

        function delete(obj)
            obj.cleanup;
        end

        function set.State(obj,newState)
            switch newState
                case epsych.enState.Prep
                    obj.prepare;

                case [epsych.enState.Run epsych.enState.Preview]
                    obj.run;
                    
                case [epsych.enState.Pause epsych.enState.Resume]
                    % nothing to do here
                    
                case epsych.enState.Halt
                    obj.stop;

            end
            obj.State = newState;
        end

        function run(obj)
            for i = 1:length(obj.handle)
                if obj.handle(i).Run
                    fprintf('running\n')
                else
                    errordlg(sprintf(['Unable to run %s module!\n\n', ...
                        'Ensure all modules are powered on and connections are secured'], ...
                        module),'Run Error','modal');
                    obj.cleanup;
                    return
                end
            end
        end
        
        function stop(obj)
            for i = 1:length(obj.handle)
                obj.handle(i).Halt;
            end
            obj.cleanup;
        end
        
        function cleanup(obj)
            delete(obj.handle);
            h = findobj('Name','RPfig');
            close(h);
        end

        function status = get.Status(obj)
            if isa(obj.handle,obj.Type)
                for i = 1:length(obj.handle)
                    rpstatus = obj.handle(i).GetStatus;
                    if rpstatus == 7
                        status = epsych.hw.Status.Running;

                    elseif rpstatus == 3
                        status = epsych.hw.Status.Ready;
                        return

                    else
                        status = epsych.hw.Status.InPrep;
                        return
                    end
                end
            else
                status = epsych.hw.Status.Error;
            end
        end % get.Status


        function i = get.FsInt(obj)
            mfs = 390625;
            fs = mfs ./ 2.^(0:6);
            i = obj.Fs == fs;
        end


        function add_module(obj,hObj,event)

        end

        function remove_module(obj,hObj,event)

        end

        function module_edit(obj,hObj,event)

        end
    end % methods
    
end