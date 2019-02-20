%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2nd demo to illustrate limitations of vecrast.m
%
% DKS 
% 2019-02-20
%
%
% Summary:
%   Example: image with colorbar
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

h=figure('Name','demo2');
hold on;

ax=gca;

az=linspace(-pi,pi,1e2);
el=linspace(-pi/2,pi/2,1e2);

[gaz,gel] = ndgrid(az,el);

f = @(th,phi) 10 * sin(th).*sin(phi);

F = f(gaz,gel);

I=imagesc(az,el,F);

ax.YDir='normal';
axis tight;
axis equal;
box on;
set(ax,'Layer','top');

cbar = colorbar();
cbar.Label.String='F';


% compare vecrasts --------------------------------------------------------
% vecrast.m
opt_stack={'top','bottom'};
for ii=1:numel(opt_stack)
    t_stack=opt_stack{ii};
    vecrast(h,strjoin({h.Name,t_stack},'_'),300,t_stack,'pdf');
end

% vecrast "improved"
myvecrast(h,h.Name,300,'pdf');