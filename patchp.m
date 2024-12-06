function [p, boundary_plot, BOUNDARY] = patchp(varargin)
% Wrapper for `patch` that plots parcellated data w/wo boundaries

%% Parse inputs
[ax, args, ~] = axescheck(varargin{:});
if isempty(ax); ax = gca; end

ip = inputParser;

addOptional(ip, 'Vertices',         []);
addOptional(ip, 'Faces',            []);
addOptional(ip, 'Parcellation',     []);
addOptional(ip, 'FaceVertexCData',  []);

addParameter(ip, 'PatchOptions',     {}, @iscell); 
addParameter(ip, 'FaceColor', [0 0 0],   @(x) isnumeric(x) || isStringScalar(x) || ischar(x));
addParameter(ip, 'FaceAlpha', 1,         @(x) isnumeric(x) || isStringScalar(x) || ischar(x));
addParameter(ip, 'EdgeColor', [0 0 0],   @(x) isnumeric(x) || isStringScalar(x) || ischar(x));
addParameter(ip, 'LineStyle', "-",       @(x) isStringScalar(x) || ischar(x));

addParameter(ip, 'BoundaryMethod',   'faces',        @(x) any(strcmpi(x,{'faces','midpoint','centroid','edge_faces','edge_vertices','none'})));
addParameter(ip, 'BoundaryColor',    [0 0 0],        @(x) isnumeric(x) || isStringScalar(x) || ischar(x));
addParameter(ip, 'BoundaryOptions',  {},             @iscell);
addParameter(ip, 'UnknownColor',     [0.5 0.5 0.5],  @(x) isnumeric(x) || isStringScalar(x) || ischar(x));

addParameter(ip, 'overrideAssertions', false, @islogical); 

parse(ip, args{:});
ipr     = ip.Results;

verts   = ipr.Vertices;
faces   = ipr.Faces;
rois    = ipr.Parcellation;
data    = ipr.FaceVertexCData;

if ~ipr.overrideAssertions
    [verts,faces,rois,data] = checkVertsFacesRoisData(verts,faces,rois,data,...
        'checkContents',true,'fillEmpty',false); 
end


%% Unpack parcellation and data
% Set rois and data if they are empty
% Unparcellate data if needed

if isempty(rois)
    rois = ones(height(verts),1);
end

if isempty(data)
    data = (1:max(rois))';
end

if height(data) == max(rois)
    data = unparcellate(rois, data, nan);
end


%% Draw main patch
p = patch(ax, 'Vertices', verts, 'Faces', faces, 'FaceVertexCData', data, ...
    'FaceColor', ipr.FaceColor, 'FaceAlpha', ipr.FaceAlpha, ...
    'EdgeColor', ipr.EdgeColor, 'LineStyle', ipr.LineStyle, ipr.PatchOptions{:});
hold on;


%% Plot unknown (faces indexed 0 or data indexed nan)
% dataFaces are the faces that contain data and should NOT be plotted as part of
% the boundary or unknown areas

roiFaces = rois(faces);
nanFaces = any(ismember(faces, find(isnan(data))), 2);

if strcmp(ipr.BoundaryMethod, 'faces')
    dataFaces = any(roiFaces, 2); % faces with any vertex on known region
else
    dataFaces = all(roiFaces, 2); % faces with all vertices on known regions
end

boundary_plot.nanZeroPatch = ...
    patch(ax, 'Vertices', verts, 'Faces', faces(nanFaces | ~dataFaces,:), ...
    'FaceColor', ipr.UnknownColor, 'FaceAlpha', ipr.FaceAlpha, ...
    'EdgeColor', ipr.EdgeColor, 'LineStyle', ipr.LineStyle, ipr.PatchOptions{:});


%% Draw boundary
if strcmpi(ipr.BoundaryMethod, 'none')
    BOUNDARY = nan;
    boundary_plot.boundary = nan;
elseif strcmpi(ipr.BoundaryMethod, 'faces')
    BOUNDARY = any(diff(roiFaces, [], 2), 2);
    boundary_plot.boundary = ...
        patch(ax, 'Vertices', verts, 'Faces', faces(BOUNDARY,:), ...
        'FaceColor', ipr.BoundaryColor, ipr.PatchOptions{:}, ipr.BoundaryOptions{:});
else
    BOUNDARY = findROIboundaries(verts, faces, rois, ipr.BoundaryMethod);
    boundary_plot.boundary = cellfun(@(x) ...
        plot3(x(:,1), x(:,2), x(:,3), ...
        'Color', ipr.BoundaryColor, 'LineWidth', p.LineWidth+2, ipr.BoundaryOptions{:}), ...
      BOUNDARY);
end


end


