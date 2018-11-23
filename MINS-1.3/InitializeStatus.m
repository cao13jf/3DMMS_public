function cStatus = InitializeStatus()

cStatus = repmat({'unreached'}, 1, GetTotalSteps());
cStatus{1} = 'initialized';

% cStatus = {'initialized', 'unreached', 'unreached', 'unreached', 'unreached', 'unreached'};
% cStatus = {'initialized', 'initialized', 'initialized', 'initialized', 'initialized', 'initialized'};
