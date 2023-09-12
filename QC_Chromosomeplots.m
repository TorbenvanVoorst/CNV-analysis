BEFORE RUNNING:
% Put in the minimal confidence level required to plot CNVs
ConfidenceLevel = 25;

% Put in the minimal length of CNV.
% CNVs with a length below minimalLength will be plotted as an opaque 
% and dashed line.
% They will still be plotted because sometimes multiple smaller CNVs next
% to each other actually belong to one larger CNV.
minimalLength = 50000;

% Do you want to save the pictures (Y/N)?
SavePics = 'Y';

FROM HERE ON YOU DON'T NEED TO CHANGE ANYTHING
% Prompt the user to select a file
[file, path] = uigetfile({'*.xlsx;*.xls;*.csv','Supported Files (*.xlsx, *.xls, *.csv)'},'Select the data file');

if file == 0
    error('File selection canceled by the user.');
end

% Construct the full file path
filePath = fullfile(path, file);

% Check the file extension to determine the appropriate read function
[~, ~, fileExt] = fileparts(filePath);

if strcmpi(fileExt, '.csv')
    % Read the CSV file with headers
    try
        tableVarName = readtable(filePath);
        
        % Convert the 'Length' column for CSV files
        tableVarName.Length = str2double(tableVarName.Length);
    catch
        error('Error reading the data file.');
    end
elseif strcmpi(fileExt, '.xlsx') || strcmpi(fileExt, '.xls')
    % Read the Excel file
    try
        tableVarName = readtable(filePath);
    catch
        error('Error reading the data file.');
    end
else
    error('Unsupported file format. Please select an Excel (XLSX/XLS) or CSV file.');
end

% Prompt the user for the save directory
if strcmpi(SavePics, 'Y')
    saveDir = uigetdir('', 'Select a directory to save the figures');
    if saveDir == 0
        error('Figure saving canceled by the user.');
    end
end

    % Convert 'Coordinates' to a cell array of character vectors
    coordinates = cellstr(tableVarName.Coordinates);
    
    % Split the 'Coordinates' column
    splitCoords = cellfun(@(x) strsplit(x, {':', '-'}), coordinates, 'UniformOutput', false);

    % Extract 'chrom', 'start', and 'end' values
    chrom = cellfun(@(x) x{1}, splitCoords, 'UniformOutput', false);
    start = cellfun(@(x) x{2}, splitCoords, 'UniformOutput', false);
    stop = cellfun(@(x) x{3}, splitCoords, 'UniformOutput', false);

    % Convert the resulting cell arrays to numeric arrays if needed
    start = str2double(start);
    stop = str2double(stop);

    % Create a new table with the split columns
    newTable = table(chrom, start, stop);

    % Append the new table to the original table
    tableVarName = [tableVarName newTable];

% Get unique 'chrom' values
uniqueChrom = unique(tableVarName.chrom);

% Calculate the number of unique 'chrom' values
numUniqueChrom = numel(uniqueChrom);

% Convert 'Sample' column to categorical
tableVarName.Sample = categorical(tableVarName.Sample);

% Initialize a color map for unique 'Sample' values
uniqueSamples = unique(tableVarName.Sample);
colorMap = lines(numel(uniqueSamples));

% Create a cell array to store the legend labels
legendLabels = cell(1, numel(uniqueSamples));

% Loop through each unique 'chrom' value
for i = 1:numUniqueChrom
    chromValue = uniqueChrom{i};
    
    % Filter the table for the current 'chrom' value
    filteredTable = tableVarName(strcmp(tableVarName.chrom, chromValue), :);
    
    % Create a figure for the current 'chrom' value
    figure ('Position', [100, 100, 1200, 400]);;
    
    % Plot connecting lines with unique colors based on 'Sample' values
    for row = 1:size(filteredTable, 1)
        startValue = filteredTable.start(row);
        endValue = filteredTable.stop(row);
        sampleValue = filteredTable.Sample(row);  % Get the 'Sample' value
        ConfidenceValue = filteredTable.Confidence(row);  % Get the 'Confidence' value
        LengthValue = filteredTable.Length(row);  % Convert to numeric
        CNValue = filteredTable.CN(row);  % Get the 'CN' value for the current row
       
        % Check if LengthValue is NaN after conversion (e.g., if the data is not numeric)
        if isnan(LengthValue)
            continue;  % Skip this row if LengthValue is not numeric
        end 
        
        % Determine the color based on 'Sample' value
        colorIndex = find(uniqueSamples == sampleValue);
        if ~isempty(colorIndex)
            color = colorMap(colorIndex, :);
            
            % Check 'Confidence' and 'Length' conditions
            if ConfidenceValue >= ConfidenceLevel
                if LengthValue >= minimalLength
                    % Plot the line with full opacity and set 'DisplayName' for legend
                    plot([startValue, endValue], [row, row], '-', 'Color', [color, 1], 'LineWidth', 2, 'DisplayName', char(sampleValue)); % Adjust line properties as needed
                else
                    % Plot the line with 50% opacity and set 'DisplayName' for legend
                    plot([startValue, endValue], [row, row], '--', 'Color', [color, 0.5], 'LineWidth', 2, 'DisplayName', char(sampleValue)); % 50% opacity
                end
                
                % Hold on for subsequent lines
                hold on;

                % Plot makers for start, stop and CNvalue
                text((startValue + endValue) / 2, row + 0.1, num2str(CNValue), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'Color', 'black', 'FontSize', 8);
                plot(startValue, row, 'o', 'MarkerSize', 4, 'MarkerFaceColor', [color], 'MarkerEdgeColor', [color] , 'HandleVisibility', 'off');
                plot(endValue, row, 'o', 'MarkerSize', 4, 'MarkerFaceColor', [color], 'MarkerEdgeColor', [color] , 'HandleVisibility', 'off');
            end
        end
    end
    
    % Set titles, labels, etc. as needed
    title([chromValue]);
    xlabel('Position');
    ylabel('Row');
    
    % Adjust any other plot settings as needed
    ylim([0, size(filteredTable, 1) + 1]);
       
    % Add a legend next to the plot
    if ~isempty(legendLabels)
        legend('Location', 'EastOutside', 'Interpreter', 'none'); % Place legend to the right (East) of the plot
    end
    
    % Figure saving
    if strcmpi(SavePics, 'Y')
    figFilePath = fullfile(saveDir, [chromValue '.png']);
    saveas(gcf, figFilePath);
    end
    % Hold off to stop adding lines to the same plot
    hold off;
end
