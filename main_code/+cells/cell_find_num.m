function outputIdx = cell_find_num(cellName, searchVal, varargin )

currCheckCellPart = [];
outputIdx = [];
i = 1;
while isempty(outputIdx)
    
    currCheckCellPart = find(ismember(cellName{i}, searchVal));
    if ~isempty(currCheckCellPart )
        outputIdx = i;
    end
    i=i+1;
    
    
    
end


end