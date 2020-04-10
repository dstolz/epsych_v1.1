classdef TDTActiveX < epsych.hw.Hardware

    properties (Constant) % define constant abstract properties from superclass
        Name         = 'TDTActiveX';
        Type         = 'COM.RPco_x';
        Description  = 'Standalone TDT ActiveX controls';
    end

    properties % define publilc abstract properties from superclass
        State          
    end

    
    properties (SetAccess = private)
        handle              % handle to ActiveX

        InterfaceParent     % matlab.ui.container
    end

    properties (Access = private)
        InterfaceDropDownLabel  matlab.ui.control.Label
        InterfaceDropDown       matlab.ui.control.DropDown
        TDTModulesTable         matlab.ui.control.Table
        AddModuleButton         matlab.ui.control.Button
        RemoveModuleButton      matlab.ui.control.Button

        CurrentIdx % selected row
    end
    
    properties
        Parameters

        ConnectionType  (1,:) char {mustBeMember(ConnectionType,{'GB','USB'})} = 'GB';

        ModuleAlias     (1,:) cell
        Module          (1,:) epsych.hw.TDTModules
        ModuleID        (1,:) double {mustBePositive,mustBeInteger}
        ModuleRPvdsFile (1,:) cell
        ModuleFs        (1,:) double {mustBePositive,mustBeFinite} = 24414.0625; % Hz
    end


    properties (Dependent)
        Status
        FsIdx
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

        function obj = TDTActiveX
            % call superclass constructor
            obj = obj@epsych.hw.Hardware;
        end

        function delete(obj)
            obj.cleanup;
        end

        function set.State(obj,newState)
            switch newState
                case epsych.State.Prep
                    obj.prepare;

                case [epsych.State.Run epsych.State.Preview]
                    obj.run;
                    
                case [epsych.State.Pause epsych.State.Resume]
                    % nothing to do here
                    
                case epsych.State.Halt
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


        function i = get.FsIdx(obj)
            mfs = 390625; % master sampling rate for most TDT hardware
            fs = mfs ./ 2.^(0:6);
            i = obj.ModuleFs == fs;
        end


        % UI -----------------------------------------------------
        function add_module(obj,hObj,event)
            % add module to the table
            obj.Module(end+1) = epsych.hw.TDTModules.RZ6;
            D = obj.TDTModulesTable.Data;
            idx = min(setdiff(1:100,[D{ismember(D(:,1),D(end,1)),2}]));
            n = D(end,:);
            n{2} = idx;
            n{4} = '';
            obj.TDTModulesTable.Data(end+1,:) = n;
        end

        function remove_module(obj,hObj,event)
            idx = obj.CurrentIdx;

            if size(obj.TDTModulesTable.Data,1) == 1, return; end

            obj.TDTModulesTable.Data(idx,:) = [];
            
            obj.Module(idx)          = [];
            obj.ModuleID(idx)        = [];
            obj.ModuleFs(idx)        = [];
            obj.ModuleAlias(idx)     = [];
            obj.ModuleRPvdsFile(idx) = [];
        end

        function module_edit(obj,hObj,event)
            obj.CurrentIdx = event.Indices(1);
            row = event.Indices(1,1);
            col = event.Indices(1,2);

            D = hObj.Data;
            
            
            switch col
                case 1 % Module
                case 2 % Index
                    v = event.NewData;
                    try
                        mustBePositive(v);
                        mustBeInteger(v);
                    catch
                        hObj.Data{row,col} = event.PreviousData;
                        return
                    end
                    ar = setdiff(1:size(D,1),row);
                    if ~isempty(ar)
                        ind = ismember(D(:,1),D(row,1));
                        if sum(ind) > 1
                            hObj.Data{row,col} = event.PreviousData;
                            fprintf(2,'Must have unique index for each module of a type')
                        end
                    end
                case 3 % Fs
                case 4 % Alias
                    ua = unique(D(:,col));
                    if length(ua) < size(D,1)
                        fprintf(2,'Invalid Entry: "%s"',event.NewData)
                        hObj.Data{row,col} = '';
                    end
                case 5 % RPvds File
                    hObj.Data{row,5} = '';
                    obj.select_rpvds_file(hObj,event);
            end
        end

        function module_select(obj,hObj,event)
            obj.CurrentIdx = event.Indices(1); % use only first selected row
            
            if event.Indices(1,2) < 5, return; end
            
            obj.select_rpvds_file(hObj,event);
        end

    end % methods
    
    methods (Access = private)
        function select_rpvds_file(obj,hObj,event)
            row = event.Indices(1);
            if row <= length(obj.ModuleRPvdsFile) && ~isempty(obj.ModuleRPvdsFile{row})
                pn = fileparts(obj.ModuleRPvdsFile{row});
            else
                pn = getpref('epsych_Hardware','RPvdsPath',epsych.Info.user_directory);
            end
            [fn,pn] = uigetfile('*.rcx','RPvds File',pn);
            
            if isequal(fn,0), return; end
            
            obj.ModuleRPvdsFile{row} = fullfile(pn,fn);
            
            hObj.Data{row,5} = fn;
            
            setpref('epsych_Hardware','RPvdsPath',pn);
        end % methods (Access = private)
    end
    
end