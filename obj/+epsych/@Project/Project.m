classdef Project < handle
    
    properties
        BitmaskFile     (1,1) string
        RPvdsFile       (1,1) string
        ScheduleFile    (1,1) string
        ConfigFiles     (:,1) string
        
        Mode            (1,:) char {mustBeMember(Mode,{'Normal','OpenEx','Synapse'})} = 'Normal';
        
        Notes           (1,:) string
    end
    
    methods
        function obj = Project(varargin)
            
            for i = 1:2:length(varargin)
                obj.(varargin{i}) = varargin{i+1};
            end
            
        end
        
        function m = validate(obj)
            % Returns # files missing from project
            p = [obj.BitmaskFile; obj.RPvdsFile; obj.ScheduleFile; obj.ConfigFiles];
            ind = arrayfun(@(a) exist(a,'file') == 2,p);
            m = sum(~ind);
        end
    end
    
end