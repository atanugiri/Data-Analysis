% Read the existing CSV file and store the data
existingTable = readtable('InitialVsLateTask.csv');
[~, filename] = fileparts('InitialVsLateTask');
filename = sprintf('%s.csv', filename);

colNames = {'Source', 'Sum Sq.', 'd.f.', 'Singular?', 'Mean Sq.', 'F', 'Prob$>$F'};
existingTable.Properties.VariableNames = colNames;

% Apply formatting to the numeric data in columns 2, 5, 6, and 7
formatSpec = '%.4f';  % Format to display up to 4 decimal places
colToFormat = [2, 5, 6, 7];

for row = 1:size(existingTable, 1)
    for col = colToFormat
        % Check if the cell contains a numeric value or a string
        if isnumeric(existingTable{row, col})
            % Convert the numeric value to a formatted string
            numericValue = existingTable{row, col};
            formattedValue = sprintf(formatSpec, numericValue);
            
            % Assign the formatted string back to the table
            existingTable{row, col} = string(formattedValue);
        end
    end
end

% Save the modified table to a CSV file
writetable(existingTable, filename);