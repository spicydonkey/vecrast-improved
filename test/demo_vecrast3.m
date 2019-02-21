%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 3rd demo to illustrate limitations of vecrast.m
%
% DKS 
% 2019-02-20
%
%
% Summary:
%   Example: Cross-hatching of multi-face patch
% EXAMPLE from by Neil Tandon (hatchfill)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

h=figure('Name','demo3');
hold on;

xdata = [2 2 0 2 5;
   2 8 2 4 5;
   8 8 2 4 8];
ydata = [4 4 4 2 0;
   8 4 6 2 2;
   4 0 4 0 0];

hp = patch(xdata,ydata,linspace(0,1,size(xdata,2)),'EdgeColor','none');
hatchfill2(hp,'cross','HatchAngle',45,'HatchDensity',20,'HatchColor','b','HatchLineWidth',2);
title('Example 3: Hatching a patch object with multiple faces');

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