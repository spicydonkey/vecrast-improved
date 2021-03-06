function myvecrast(figureHandle, filename, resolution, exportType)


% Ensure figure has finished drawing
drawnow;

% Set figure units to points
set(figureHandle, 'units', 'points');

% Ensure figure size and paper size are the same
figurePosition = get(figureHandle, 'Position');
set(figureHandle, 'PaperUnits', 'points', 'PaperSize', [figurePosition(3) figurePosition(4)]);
set(figureHandle, 'PaperPositionMode', 'manual', 'PaperPosition', [0 0 figurePosition(3) figurePosition(4)]);

% Create a copy of the figure and remove smoothness in raster figure
vecrastFigure = copyobj(figureHandle, groot);
set(vecrastFigure, 'GraphicsSmoothing', 'off', 'color', 'w');
rasterFigure = copyobj(figureHandle, groot);
set(rasterFigure, 'GraphicsSmoothing', 'on', 'color', 'w');     % different GraphicsSmoothing may create black grid-lines

% Axes
origaxesHandle = findall(figureHandle, 'type', 'axes');
vraxesHandle = findall(vecrastFigure, 'type', 'axes');
raxesHandle = findall(rasterFigure, 'type', 'axes');
for i = 1:length(vraxesHandle)
    % Fix vector image axis limits based on the original figure
    % (this step is necessary if these limits have not been defined)
    xlim(vraxesHandle(i), 'manual');
    ylim(vraxesHandle(i), 'manual');
    zlim(vraxesHandle(i), 'manual');
    
    xlim(raxesHandle(i), 'manual');
    ylim(raxesHandle(i), 'manual');
    zlim(raxesHandle(i), 'manual');
    
    % normalised axes units for positioning raster
    set(vraxesHandle,'Units','normalized');
    set(raxesHandle,'Units','normalized');
end

% Ensure fontsizes are the same as orig
origText = findall(figureHandle, 'type', 'text');
vecrastText = findall(vecrastFigure, 'type', 'text');
rastText = findall(rasterFigure, 'type','text');
for i=1:length(origText)
    set(vecrastText(i), 'FontSize', get(origText(i), 'FontSize'));
    set(rastText(i), 'FontSize', get(origText(i), 'FontSize'));
end

% Define raster-/vectorizable objects
rasobj_axes={'patch','surface','contour','image','light'};  % rasterizable axes objects
isRaster=@(graphicsObj) any(strcmp(graphicsObj.Type, rasobj_axes));

% Rasterise and layer -----------------------------------------------------
% hide everything graphical in raster to set up a blank canvas
set(rasterFigure.Children,'Visible','off');
set(rasterFigure.Children.Children,'Visible','off');

temp_files={};
% rasterizables
for i=1:length(raxesHandle)
    tr_ax = raxesHandle(i);
    tvr_ax = vraxesHandle(i);
    to_ax = origaxesHandle(i);
    
    % get figure canvas limits wrt this axes (normalised)
    [x0, y0] = figpos2axpos(tr_ax,0,0);
    [x1, y1] = figpos2axpos(tr_ax,1,1);
    
    % find all rasterizables in this axes
    tr_ax_objs = findall(tr_ax);
    tvr_ax_objs = findall(tvr_ax);
    b_rastobjs = arrayfun(@(o) isRaster(o), tr_ax_objs);
    
    for j=1:length(tr_ax_objs)
        if ~b_rastobjs(j)
            continue;
        end
        % Rasterize -------------------------------------------------------
        % isolate rasterizable objs (rasterFigure) (in ax)
        set(tr_ax_objs(j),'visible','on');
        
        % print this rasterizable on temporary .png
        % ('-loose' ensures that the bounding box of the figure is not cropped)
        drawnow;
        tempfilename=sprintf('temp_%s_%d_%d.png',filename,i,j);
        print(rasterFigure, tempfilename, '-dpng', ['-r' num2str(resolution) ], '-loose', '-opengl');
        temp_files{end+1}=tempfilename;     % store temporary file name
        
        % hide this rasterizable in rasterFigure
        set(tr_ax_objs(j),'visible','off');
        
        % Update vec-rast figure ------------------------------------------
        % hide the rasterizable object
        %   NOTE: can cause dependent vectors to invis?
        set(tvr_ax_objs(j),'visible','off');    
   
        % load rasterized png image into this axes
        [A, ~, alpha] = imread(tempfilename);
        if isempty(alpha)==1
            timg_raster=imagesc(tvr_ax, 'XData', [x0,x1], 'YData', [y0,y1], 'CData', flipud(A));
        else
            timg_raster=imagesc(tvr_ax,  'XData', [x0,x1], 'YData', [y0,y1], 'CData', flipud(A), 'alphaData', flipup(alpha));
        end        
        timg_raster.Clipping='off';      % debug: image can flow out of axes 
        
        % layer placement
        tn_new_objs=sum(b_rastobjs(1:j-1));
        uistack(timg_raster,'down',j-1+tn_new_objs);
    end
    
    % ensure axes properties are same as original
    tvr_ax.YDir = to_ax.YDir;
    tvr_ax.XLim = to_ax.XLim;
    tvr_ax.YLim = to_ax.YLim;
end
% cleanup 
close(rasterFigure);
        
% colorbar ticks to original
hcbOriginal = findall(figureHandle, 'type', 'colorbar');
hcbVecrast = findall(vecrastFigure, 'type', 'colorbar');

for i=1:numel(hcbOriginal)
    cbLimits = hcbOriginal(i).Limits;
    hcbVecrast(i).Ticks = (hcbOriginal(i).Ticks - cbLimits(1))/diff(cbLimits);
    hcbVecrast(i).TickLabels = hcbOriginal(i).TickLabels;
end

% Bring all annotations on top
annotations = findall(vecrastFigure, 'Tag', 'scribeOverlay');
for i = 1:length(annotations)
    uistack(annotations(i), 'top');
end

% Ensure figure has finished drawing
drawnow;

% Finalise ----------------------------------------------------------------
% (optional) cleanup: delete temporary pngs
if ~isempty(temp_files)
    delete(temp_files{:});       % COMMENT THIS IF YOU WANT TO KEEP PNG FILE
end

% Print and close the combined vector-raster figure
if strcmp(exportType, 'pdf') == 1
    print(vecrastFigure, [filename '.pdf'], '-dpdf', '-loose', '-painters', ['-r' num2str(resolution) ]);
elseif strcmp(exportType, 'eps') == 1
    print(vecrastFigure, [filename '.eps'], '-depsc2', '-loose', '-painters');
elseif strcmp(exportType, 'svg') == 1
    print(vecrastFigure, [filename '.svg'], '-dsvg', '-loose', '-painters');
end

close(vecrastFigure);

end