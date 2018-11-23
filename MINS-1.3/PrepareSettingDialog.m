function cOutput = PrepareSettingDialog(name, settings_struct, settings)

cOutput = {...
    'Description', sprintf('Please input parameters for: %s', name), 'on'... 
    'Title'      , 'Parameter Setting', 'on'};

for j = 1:size(settings_struct, 1)
    if ~strcmpi(settings_struct{j, 1}, 'separator')
        cOutput{length(cOutput)+1} = {settings_struct{j, 1}; settings_struct{j, 2}};
        if islogical(settings.(settings_struct{j, 2})) && strcmpi(settings_struct{j, 2}, 'skip')
            cOutput{length(cOutput)+1} = [settings.(settings_struct{j, 2}), settings.(settings_struct{j, 2})];
        else
            cOutput{length(cOutput)+1} = settings.(settings_struct{j, 2});
        end
        cOutput{length(cOutput)+1} = settings_struct{j, 4};
    else
        cOutput{length(cOutput)+1} = settings_struct{j, 1};
        cOutput{length(cOutput)+1} = settings_struct{j, 2};
        cOutput{length(cOutput)+1} = 'on';
    end
end
