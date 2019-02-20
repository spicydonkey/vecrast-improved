%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% demo to illustrate limitations of vecrast.m
%
% DKS 
% 2019-02-17
%
%
% Summary:
%   vecrast creates ONE overlaid raster figure per figure hence layer
%   orders cannot be generalised.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

h=figure('Name','demo_raster_layers');
hold on;

ax=gca;

lim_x=[0,1];
lim_y=[0,1];
set(ax,'XLim',lim_x);
set(ax,'YLim',lim_y);

set(ax,'Layer','top');

% bottom layer (half-filled background)
h_patch_xsemi=patch('XData',[0.4,0.9,0.9,0.4],...
    'YData',[ax.YLim(1),ax.YLim(1),ax.YLim(2),ax.YLim(2)],...
    'FaceColor','b','FaceAlpha',0.33,'EdgeColor','none');     % patch half-axis
uistack(h_patch_xsemi,'bottom');


% mid-layer (hatched)
h_patch_ax=patch('XData',[ax.XLim(1),ax.XLim(2),ax.XLim(2),ax.XLim(1)],...
    'YData',[ax.YLim(1),ax.YLim(1),ax.YLim(2),ax.YLim(2)],...
    'FaceColor','none','EdgeColor','none');     % patch whole axis
uistack(h_patch_ax,'top');
h_hatch=hatchfill2(h_patch_ax,'single','HatchAngle',45,'HatchDensity',20,...
    'HatchColor','k','HatchLineWidth',0.5);

% top-layer (fill)
h_patch_top=patch('XData',[ax.XLim(1),ax.XLim(2),ax.XLim(2),ax.XLim(1)],...
    'YData',[0.1,0.1,0.7,0.7],...
    'FaceColor',0.3*ones(1,3),'EdgeColor','none');

box on;


% compare vecrasts --------------------------------------------------------
% vecrast.m
opt_stack={'top','bottom'};
for ii=1:numel(opt_stack)
    t_stack=opt_stack{ii};
    vecrast(h,strjoin({h.Name,t_stack},'_'),300,t_stack,'pdf');
end

% vecrast "improved"
myvecrast(h,h.Name,600,'pdf');