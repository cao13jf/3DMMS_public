function [data, seg, settings, g_settings, status] = ModuleCommand(iStep, data, seg, settings, g_settings, command)

workflow = GetWorkflow();
eval(sprintf('[data, seg, settings, g_settings, status] = %s(data, seg, settings, g_settings, command);', workflow{iStep}));
