
function checkSlxSavedRelease(targetRelease)
% checkSlxSavedRelease  Search current folder and subfolders for .slx files
%   checkSlxSavedRelease('R2024a')
if nargin < 1
    targetRelease = 'R2024a';
end

% Find all .slx files recursively
files = dir(fullfile(pwd, '**', '*.slx'));
if isempty(files)
    fprintf('No .slx files found under %s\n', pwd);
    return
end

notMatching = struct('file', {}, 'foundRelease', {});
for k = 1:numel(files)
    fpath = fullfile(files(k).folder, files(k).name);
    try
        rel = findSlxSavedRelease(fpath); %#ok<NASGU>
    catch ME
        % If helper throws, treat as unknown
        rel = "";
        warning('Error reading %s: %s', fpath, ME.message);
    end

    if isempty(rel) || ~strcmp(char(rel), targetRelease)
        notMatching(end+1).file = fpath; %#ok<AGROW>
        notMatching(end).foundRelease = string(rel);
    end
end

% Report
if isempty(notMatching)
    fprintf('All %d .slx files are saved in %s\n', numel(files), targetRelease);
else
    fprintf('%d of %d .slx files are NOT saved in %s:\n', numel(notMatching), numel(files), targetRelease);
    for i = 1:numel(notMatching)
        fprintf('  %s  →  saved-in: %s\n', notMatching(i).file, notMatching(i).foundRelease);
    end
end
end