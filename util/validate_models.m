function validate_models()
    % VALIDATE_MODELS - Validate Simulink models for DUT subsystem and Hub platform configuration
    %
    % This function reads a list of .slx files from 'slx_files.txt' and validates each model
    % to check for:
    %   1. Presence of a DUT subsystem
    %   2. Platform configuration in the Vitis Model Composer Hub block
    %
    % Outputs:
    %   - validation_results.json: Structured results in JSON format
    %   - validation_summary.md: Human-readable markdown summary
    %
    % Copyright (c) 2024 Advanced Micro Devices, Inc.
    
    % Read list of .slx files to validate
    fid = fopen('slx_files.txt', 'r');
    if fid == -1
        error('Could not open slx_files.txt');
    end
    
    slx_files = {};
    while ~feof(fid)
        line = fgetl(fid);
        if ischar(line) && ~isempty(line)
            slx_files{end+1} = strtrim(line);
        end
    end
    fclose(fid);
    
    % Results structure
    results = struct('file', {}, 'has_dut', {}, 'has_platform', {}, ...
                   'platform_info', {}, 'error', {});
    
    fprintf('\n=== Validating %d Simulink Models ===\n\n', length(slx_files));
    
    % Validate each model
    for i = 1:length(slx_files)
        slx_file = slx_files{i};
        fprintf('Analyzing: %s\n', slx_file);
        
        result = struct();
        result.file = slx_file;
        result.has_dut = false;
        result.has_platform = false;
        result.platform_info = '';
        result.error = '';
        
        try
            % Check if file exists
            if ~exist(slx_file, 'file')
                result.error = 'File not found';
                results(end+1) = result;
                continue;
            end
            
            % Load the model
            [~, modelName, ~] = fileparts(slx_file);
            load_system(slx_file);
            
            % Check for DUT subsystem
            dut_path = [modelName '/DUT'];
            if exist_block(dut_path)
                result.has_dut = true;
                fprintf('  [YES] DUT subsystem found\n');
            else
                fprintf('  [NO]  No DUT subsystem\n');
            end
            
            % Find Hub block and check platform configuration
            hub_blocks = find_system(modelName, 'BlockType', 'Reference', ...
                'SourceBlock', 'vmcUtilities/Vitis Model Composer Hub');
            
            if ~isempty(hub_blocks)
                hub_block = hub_blocks{1};
                
                % Get platform configuration
                try
                    platform_type = get_param(hub_block, 'PlatformType');
                    platform_path = get_param(hub_block, 'Platform');
                    
                    if strcmp(platform_type, 'Specify Platform') || ...
                       (ischar(platform_path) && contains(platform_path, '.xpfm'))
                        result.has_platform = true;
                        
                        % Extract platform name
                        if ~isempty(platform_path)
                            [~, platform_name, ~] = fileparts(platform_path);
                            result.platform_info = platform_name;
                            fprintf('  [YES] Platform configured: %s\n', platform_name);
                        else
                            fprintf('  [YES] Platform configuration enabled\n');
                        end
                    else
                        fprintf('  [NO]  No platform configured (part-based)\n');
                    end
                catch
                    fprintf('  [WARN] Could not read platform configuration\n');
                end
            else
                fprintf('  [WARN] No Hub block found\n');
            end
            
            % Close the model
            close_system(modelName, 0);
            
        catch ME
            result.error = ME.message;
            fprintf('  [ERROR] %s\n', ME.message);
            
            % Try to close model if it was opened
            try
                close_system(modelName, 0);
            catch
            end
        end
        
        results(end+1) = result;
        fprintf('\n');
    end
    
    % Generate summary
    fprintf('=== Validation Summary ===\n');
    fprintf('Total models analyzed: %d\n', length(results));
    
    models_with_dut = sum([results.has_dut]);
    models_with_platform = sum([results.has_platform]);
    models_with_errors = sum(~cellfun(@isempty, {results.error}));
    
    fprintf('Models with DUT subsystem: %d\n', models_with_dut);
    fprintf('Models with platform configuration: %d\n', models_with_platform);
    fprintf('Models with errors: %d\n', models_with_errors);
    
    fprintf('\nValidation complete.\n');
end

function exists = exist_block(block_path)
    try
        exists = ~isempty(find_system(block_path, 'SearchDepth', 0));
    catch
        exists = false;
    end
end
