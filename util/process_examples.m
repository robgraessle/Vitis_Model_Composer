function process_examples(NameValueArgs)
% PROCESS_EXAMPLES operates on the Vitis_Model_Composer examples and tutorials
% repo. It converts all README.md files to HTML. It also writes an
% index.csv that contains the mapping between each example/tutorial's
% unique name and its path. It stages all changed files for a Git commit.
%
% Arguments:
% mode: 'force' or '' (default). Default behavior is to only generate the
%   HTML file when there have been changes in the README.md. 'force' will
%   re-generate all README.html files (this may take a while).
% folder: default is 'Vitis_Model_Composer'. Relative path from the current
%   folder to the top level folder of the Vitis_Model_Composer repo.

arguments
    NameValueArgs.mode = ''
    NameValueArgs.folder = 'Vitis_Model_Composer'
    NameValueArgs.release = '';
end

% Get path to the top level folder of the 'Vitis_Model_Composer' repo
homepath = fullfile(pwd, NameValueArgs.folder);

% Delete any existing index.csv so we can create a new one.
index_file = "index.csv";
if exist(fullfile(homepath,index_file), "file")
    delete(fullfile(homepath,index_file));
end

% Initialize key-value table for example names and paths
index_list = containers.Map();

% Call recursive function to iterate through each directory and process files
recurseThroughDir(homepath,0);

% Write index list into index.csv
index_list = cat(1, index_list.keys, index_list.values);
writecell(index_list, index_file)

% Stage new index.csv file for commit
system(strcat("git add ", index_file));

% Display git status
% system("git status");

% Return to calling directory
cd("..");

% End of process_examples script
% --------------------------
%% Recursive function definition
function recurseThroughDir(directory,cnt)
    %% Navigate to next directory and get contents
    cd(directory)
    contents = dir(".");
    contents = contents(~ismember({contents.name}, {'.', '..', '.git'}));
    blocks = contents([contents.isdir]);

    % Get lists of .md, .html, and .slx files
    mds = contents(endsWith({contents.name}, '.md'));
    htmls = contents(endsWith({contents.name}, '.html'));
    slxs = contents(endsWith({contents.name}, '.slx'));

    % Find newest .md and newest .html file
    [~, newest] = max([mds.datenum]);
    newestMd = mds(newest);
    [~, newest] = max([htmls.datenum]);
    newestHtml = htmls(newest);
   
    %% Update SLX File Versions
    if ~isempty(NameValueArgs.release) && ~isempty(slxs)
        for ii = 1:length(slxs)
            [~,modelname,~] = fileparts(slxs(ii).name);

            % Query the release of the model
            mdlInfo = Simulink.MDLInfo(modelname);
            % If it does not match the desired release, we need to convert it
            if ~contains(mdlInfo.ReleaseName, NameValueArgs.release)
                convertSlxToRelease(modelname, NameValueArgs.release);
            end
        end
    end

    %% Generate HTML files
    % Check to see if newest .html is newer than newest .md
    % (Or if 'force' command line argument is provided)
    update = strcmp(NameValueArgs.mode, 'force') || (datetime(newestHtml.date) < datetime(newestMd.date));
    
    % We need to produce an updated .html file
    if update
        
        % For each .md file in this folder
        for h = 1:length(mds)
            disp(pwd + " Processing.");

            md = mds(h).name;
            html_file = strcat(erase(md, '.md'), '.html');
            
            % If corresponding .html file already exists, need to delete it so we can
            % create a new one.
            if exist(fullfile(pwd,html_file), 'file')
                delete(fullfile(pwd,html_file));
            end

            % Invoke Showdown to convert the .md file to .html
            [filepath,~,~] = fileparts(mfilename('fullpath'));
            showdown_cmd = strcat("/usr/bin/node ", filepath, "/convert.js");
            [status, ~] = system(showdown_cmd);
            if status ~= 0
                error("Something went wrong while running Showdown");
            end

            % Replace markdown emojis (e.g. :bulb:) with <img src> tags
            replaceEmojiWithImage(homepath);

            % For Examples and Tutorials only:
            % Append HTML/JavaScript to beginning of README.html
            % This adds "Open Design" or "Open Lab Directory" button to the page
            if strcmp(html_file, 'README.html')
                if contains(pwd, 'Examples') && length(slxs) >= 1
                    insertHtmlToOpenDesign('no_labs');
                elseif contains(pwd, 'Tutorials')
                    insertHtmlToOpenDesign('labs');
                end
            end
            
            % Replace any link to another help page with call to example API
            replaceLinksToHelp(html_file);
            
            % Stage updated HTML file for commit
            system(strcat("git add ", html_file));
        end
    end
    
    %% Update Index
    % Only for folders that have a help page (.md file), or for Block Help folders
    if ~isempty(mds) || (~isempty(slxs) && contains(pwd, 'Block_Help'))
        % Get current directory name
        dir_name = regexp(pwd, '\/([\w\-]+)', 'tokens');
        dir_name = dir_name{end};
        dir_name = dir_name{1};
    
        old_name = dir_name;
    
        % Check for duplicate example entry and prompt user for an alternate name if needed
        while any(strcmp(index_list.keys, dir_name))
            dir_name = input(strcat("Duplicate conflict file: ", erase(pwd, homepath), ...
                "\nDuplicate name: ", dir_name, "\nEnter new name: "), 's');
        end
        
        path = erase(pwd, homepath);
    
        % Check to see if we are in the Git repo base folder
        % On Git, this will always be "Vitis_Model_Composer"
        if strcmp(dir_name, NameValueArgs.folder)
            index_list("Vitis_Model_Composer") = path(2:end);
        else
            index_list(dir_name) = path(2:end);
        end
        
        % If needed, move duplicate into folder with new name
        if ~strcmp(old_name, dir_name)
            movefile('.', strcat('../', dir_name));
            cd('..');
            rmdir(old_name, 's');
            cd(dir_name);
        end
    end

    % Count recursion levels
    % If we go more than 4 levels deep, we are into subfolders and
    % generated code folders. Return.
    cnt = cnt+1;
    if cnt == 5
        return
    else
        for b = 1:length(blocks)
            recurseThroughDir(blocks(b).name,cnt);
            cd("..");
        end
    end
end

end

function insertHtmlToOpenDesign(type)
    arguments
        type(1,:) char {mustBeMember(type,{'labs','no_labs'})} = 'no_labs'
    end
    
    fid = fopen('README.html');
    cac = textscan( fid, '%s', 'Delimiter','\n', 'CollectOutput',true );
    fclose( fid );
    
    if strcmp(type, 'labs')
        text = fileread('html_text_labs.html');
    else
        text = fileread('html_text.html');
    end


    fid = fopen('tmp.html', 'w' );

    jj = 1;
    while(~strcmp(cac{1}{jj},"<div id='content'>"))
        fprintf( fid, '%s\n', cac{1}{jj} );
        jj = jj +1;
    end

    jj = jj + 1;
    fprintf( fid, '%s\n', cac{1}{jj} );

    fprintf(fid, '%s\n', text);

    cont = jj+1;
    for jj = cont : length(cac{1})
        fprintf( fid, '%s\n', cac{1}{jj} );
    end
    fclose( fid );

    copyfile('tmp.html','README.html')
    delete('tmp.html');

end

function replaceEmojiWithImage(parentDir)
    currDir = pwd;
    fp = currDir(length(parentDir)+1:end);
    numUp = count(fp,"/");
    imgSrc = "";
    for j=1:numUp
        imgSrc = imgSrc + "..\/";
    end
    lbpath = append(imgSrc, "Images\/bulb.png");
    command = "sed -i 's/:bulb:/" + '<img width="18" height="18" src="'+  lbpath + '">' + "/g' README.html";
    
    status = system(command);
    
    if status ~= 0
        error("Something went wrong in replacing the emoji");
    end
end

function replaceLinksToHelp(html_file)
    % Get contents of HTML file
    text = fileread(html_file);

    % Replace links to other example pages with call to example API
    % URL Format 1
    pattern  = '<a\shref="[\w\.\/\-]*\/([\w\-]+)\/README\.md">';
    tokens = regexp(text, pattern, 'tokens');
    
    for index = 1:length(tokens)
        tok = tokens{index};
        tok = tok{1};
       
        new_string = strcat('<a href="matlab:XmcExampleApi.getExample(''', tok, ''')">');
        old_pattern = strcat('<a\shref="[\w\.\/\-]*\/', tok, '\/README\.md">');

        text = regexprep(text, old_pattern, new_string);
    end
    
    % URL Format 2
    pattern  = '<a\shref="([\w\-]+)\/README\.md">';
    tokens = regexp(text, pattern, 'tokens');
    
    for index = 1:length(tokens)
        tok = tokens{index};
        tok = tok{1};
       
        new_string = strcat('<a href="matlab:XmcExampleApi.getExample(''', tok, ''')">');
        old_pattern = strcat('<a\shref="', tok, '\/README\.md">');

        text = regexprep(text, old_pattern, new_string);
    end

    % URL Format 3
    pattern  = '<a\shref="(?:https?:\/\/)?[\w\.:\/\-]*\/Xilinx\/Vitis_Model_Composer\/[\w\.:\/\-]*\/([\w\-]+)\/README\.md">';
    tokens = regexp(text, pattern, 'tokens');
    
    for index = 1:length(tokens)
        tok = tokens{index};
        tok = tok{1};
       
        new_string = strcat('<a href="matlab:XmcExampleApi.getExample(''', tok, ''')">');
        old_pattern = strcat('<a\shref="(?:https?:\/\/)?[\w\.:\/\-]*\/', tok, '\/README\.md">');

        text = regexprep(text, old_pattern, new_string);
    end

    % URL Format 4
    pattern  = '<a\shref="[\w\.\/\-]*\/([\w\-\/]+)">';
    tokens = regexp(text, pattern, 'tokens');
    
    for index = 1:length(tokens)
        tok = tokens{index};
        tok = tok{1};
        
        modified = false;
        if tok(end) == '/'
            tok = tok(1:end-1);
            modified = true;
        end

        new_string = strcat('<a href="matlab:XmcExampleApi.getExample(''', tok, ''')">');

        old_pattern = strcat('<a\shref="[\w\.\/\-]*\/', tok, '">');
        if modified
            disp(old_pattern);
            old_pattern = strcat('<a\shref="[\w\.\/\-]*\/', strcat(tok, '/'), '">');
        end

        text = regexprep(text, old_pattern, new_string);
    end

    % Replace links to block help with calls to block help API (vmcHelp)
    pattern = '\/VMC\_Help\/([\w\.\/\-]*)\/README\.md';
    tokens = regexp(text, pattern, 'tokens');
    
    for index = 1:length(tokens)
        tok = strsplit(string(tokens{index}),'/');
        blockName = tok(end);
        blockCat = tok(end-1);

        new_string = strcat('<a href="matlab:helpview(vmcHelp(name=''', blockName, ''',category=''', blockCat, '''))">');
        old_pattern = strcat('<a\shref="https:\/\/github.com\/Xilinx\/VMC_Help\/', tokens{index}, '\/README\.md">');

        text = regexprep(text, old_pattern, new_string);
    end

    % Fix image paths for display in product
    pattern  = 'src="((?:\.\.\/)+)Images';
    tokens = regexp(text, pattern, 'tokens');
    
    for index = 1:length(tokens)
        tok = tokens{index};
        tok = tok{1};
       
        new_string = strcat('src="../Images');
        old_pattern = strcat('src="', tok, 'Images');

        text = regexprep(text, old_pattern, new_string);
    end

    % Write revised HTML contents out to file
    fileID = fopen(html_file, 'w');
    if fileID == -1, error('Cannot open file %s', html_file); end
    fwrite(fileID, text, 'char');
    fclose(fileID);
end

function convertSlxToRelease(modelname,release)
%CONVERTSLXTORELEASE Converts Simulink model to a specified Simulink release
%   Use this function to convert all example Simulink models to the base
%   release.

% Rename the model and open it
movefile([modelname '.slx'],[modelname '_old.slx']);
load_system([modelname '_old']);

% Export back to the original filename
Simulink.exportToVersion([modelname '_old'], modelname, release);

% Close the renamed model and delete the file
close_system([modelname '_old']);
delete([modelname '_old.slx']);

end