function cSettings = InitializeSettings()

workflow = GetWorkflow();    
cSettings = cell(1, length(workflow));

for i = 1:length(cSettings)
    clear settings
    eval(sprintf('settings_struct = %s();', workflow{i}));
    for j = 1:size(settings_struct, 1)
        if ~strcmpi(settings_struct{j, 1}, 'separator')
            settings.(settings_struct{j, 2}) = settings_struct{j, 3};
        end
    end

    cSettings{i} = settings;
end