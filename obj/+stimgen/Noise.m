classdef Noise < stimgen.StimType
    
    properties
        HighPass  (1,1) double {mustBeNonnegative,mustBeFinite} = 500; % Hz
        LowPass   (1,1) double {mustBeNonnegative,mustBeFinite} = 20000; % Hz
        
        FilterOrder (1,1) double {mustBePositive,mustBeInteger,mustBeFinite} = 40;
        digFilter % designfilt object
    end
   
    
    methods
                
        function obj = Noise(varargin)
            obj = obj@stimgen.StimType(varargin{:});
        end

        function set.HighPass(obj,fc)
            obj.HighPass = fc;
            obj.update_digFilter;
        end
        
        function set.LowPass(obj,fc)
            obj.LowPass = fc;
            obj.update_digFilter;
        end
        
        function set.FilterOrder(obj,fo)
            obj.FilterOrder = fo;
            obj.update_digFilter;
        end
        
        function set.digFilter(obj,d)
            assert(isa(d,'digitalFilter'),'Must use a designfilt object')            
            obj.digFilter = d;
        end
        
        function d = get.digFilter(obj)
            if isempty(obj.digFilter) || ~isvalid(obj.digFilter)
                obj.update_digFilter;
            end
            d = obj.digFilter;
        end
        
        function update_signal(obj)
            t = obj.Time;

            y = randn(length(t),1);
            
            y = filter(obj.digFilter,y);
            
            obj.Signal = y';
            
            obj.apply_gate;
            
            obj.apply_normalization;
        end
    
        function update_digFilter(obj)
            obj.digFilter = designfilt('bandpassfir', ...
                    'FilterOrder',obj.FilterOrder, ...
                    'CutoffFrequency1',obj.HighPass, ...
                    'CutoffFrequency2',obj.LowPass, ...
                    'SampleRate',obj.Fs);
        end
    end
    
end
