function newCell = parse_cell(myCell, elementNumbers)
% function newCell = parse_cell(myCell, elementNumbers)
% Descr: saves elements of cell to new cell
% author: ijones

% get field names
cellFieldNames = fieldnames(myCell{1});

% new cell
newCell = {};

% create cell
for j=1:length(elementNumbers)
    
    
        eval(['newCell{',num2str(j),'} = myCell{', num2str(elementNumbers(j)),'};'])
        
 
end

end