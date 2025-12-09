
function release = findSlxSavedRelease(slxFile)
% findSlxSavedRelease  Determine saved-in release of a .slx file.
%   r = findSlxSavedRelease('model.slx')
%   Returns "" if unknown, otherwise a string like "R2024a".
%
% Preferred search order:
%  1) modelDescription.xml attributes (SavedInVersion, SavedInMatlabVersion, programVersion)
%  2) coreProperties.xml <cp:version> element
%  3) any RYYYYa/b token in extracted text files

release = "";
if nargin==0 || ~isfile(slxFile)
    return
end

tmp = tempname;
mkdir(tmp);
cleanup = onCleanup(@() rmdir(tmp,'s'));

% Unzip .slx (it's a zip archive)
try
    unzip(slxFile, tmp);
catch
    return
end

% Helper: extract first RYYYYa/b match from text
firstReleaseMatch = @(txt) (string(regexp(txt, 'R\d{4}[ab]', 'match', 'once')));

% 1) modelDescription.xml attributes
md = fullfile(tmp,'modelDescription.xml');
if isfile(md)
    txt = fileread(md);
    attrs = {'SavedInVersion','SavedInMatlabVersion','programVersion','SavedBy'};
    for a = 1:numel(attrs)
        pat = sprintf('%s\\s*=\\s*"(.*?)"', attrs{a});
        tk = regexp(txt, pat, 'tokens', 'once');
        if ~isempty(tk) && ~isempty(tk{1})
            m = regexp(tk{1}, 'R\d{4}[ab]', 'match', 'once');
            if ~isempty(m)
                release = string(m);
                return
            end
        end
    end
    % fallback: any RYYYYa/b in modelDescription.xml
    m = firstReleaseMatch(txt);
    if m~=""
        release = m;
        return
    end
end

% 2) coreProperties.xml <cp:version>
cp = fullfile(tmp,'docProps','core.xml'); % common location inside .slx zip
if isfile(cp)
    txt = fileread(cp);
    % match <cp:version> ... </cp:version> allowing optional namespace prefix
    tk = regexp(txt, '<(?:\w+:)?version\b[^>]*>(.*?)</(?:\w+:)?version>', 'tokens', 'once');
    if ~isempty(tk) && ~isempty(tk{1})
        m = regexp(tk{1}, 'R\d{4}[ab]', 'match', 'once');
        if ~isempty(m)
            release = string(m);
            return
        end
    end
end

% 3) Search other extracted text files (skip binaries)
files = dir(fullfile(tmp, '**', '*.*'));
for k = 1:numel(files)
    f = files(k);
    if f.isdir
        continue
    end
    [~,~,ext] = fileparts(f.name);
    if any(strcmpi(ext,{'.png','.jpg','.jpeg','.gif','.bin','.zip','.slx','.mat'}))
        continue
    end
    try
        txt = fileread(fullfile(f.folder,f.name));
    catch
        continue
    end
    m = firstReleaseMatch(txt);
    if m~=""
        release = m;
        return
    end
end

% nothing found -> return empty string
release = "";
end