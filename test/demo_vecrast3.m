%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 3rd demo to illustrate limitations of vecrast.m
%
% DKS 
% 2019-02-20
%
%
% Summary:
%   Example: image with hatch
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

h=figure('Name','demo3');
hold on;

xlim([0,1]);
ylim([0,1]);

hp = patch('XData',[0 1 1 0],'YData',[0 0 1 1],'FaceColor','none','EdgeColor','none');
hatchfill2(hp,'cross','HatchAngle',45,'HatchDensity',20,'HatchColor','b','HatchLineWidth',2);

ax=gca;
box on;
set(ax,'Layer','top');


% compare vecrasts --------------------------------------------------------
% vecrast.m
opt_stack={'top','bottom'};
for ii=1:numel(opt_stack)
    t_stack=opt_stack{ii};
    vecrast(h,strjoin({h.Name,t_stack},'_'),300,t_stack,'pdf');
end

% vecrast "improved"
myvecrast(h,h.Name,300,'pdf');