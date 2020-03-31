classdef Helper < handle
    
    properties
     
    end
    
    
    methods
        % Constructor
        function obj = Helper()
          
        end
        
        % Destructor
        function delete(obj)
         
        end
        
    end
    
    
    methods (Static)


        function update_highlight(tableH,row,highlightColor)
            if nargin < 3 || isempty(highlightColor), highlightColor = [0.2 0.6 1]; end
            n = size(tableH.Data,1);
            c = repmat([1 1 1; 0.9 0.9 0.9],ceil(n/2),1);
            c(n+1:end,:) = [];
            if ~isempty(row)
                c(row,:) = repmat(highlightColor,numel(row),1);
            end
            tableH.BackgroundColor = c;
        end

        
    end
end

