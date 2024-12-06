%%% Shared variables

[sphv, sphf] = sphereMesh(100, 'fib'); 
[~,sphp] = pdist2(equilateralMesh(20), sphv, 'seuclidean', 'Smallest', 1); 
sphp = sphp'; 
sphd = pdist2(kron([1;-1], eye(3)), sphv, 'seuclidean', 'Smallest', 1)'; 


%% No rois or data
figure; 

% No extra inputs
patchp(nexttile, 'Vertices', sphv, 'Faces', sphf); 

% Change face color
patchp(nexttile, 'Vertices', sphv, 'Faces', sphf, 'FaceColor', 'flat'); 
patchp(nexttile, 'Vertices', sphv, 'Faces', sphf, 'FaceColor', 'interp'); 

% Use struct syntax
patchp(nexttile, struct('Vertices', sphv, 'Faces', sphf), 'FaceColor', 'interp'); 


%% Simple rois and/or data
figure; 

% Parcellation only
patchp(nexttile, 'Vertices', sphv, 'Faces', sphf, 'FaceColor', 'interp', 'Parcellation', sphp); 

% Data only (vertex level)
patchp(nexttile, 'Vertices', sphv, 'Faces', sphf, 'FaceColor', 'interp', 'FaceVertexCData', sphd); 

% Parcellation and data (parcel level)
patchp(nexttile, 'Vertices', sphv, 'Faces', sphf, 'FaceColor', 'interp', 'Parcellation', sphp, 'FaceVertexCData', splitapply(@mean,sphd,sphp)); 

% Parcellation and data (vertex level)
patchp(nexttile, 'Vertices', sphv, 'Faces', sphf, 'FaceColor', 'interp', 'Parcellation', sphp, 'FaceVertexCData', sphd); 


%% ROIs and/or data set to 0/NaN
figure; 

% Parcellation with region set to 0
patchp(nexttile, 'Vertices', sphv, 'Faces', sphf, 'FaceColor', 'flat', 'Parcellation', sphp-1); 

% Vertex level data with one parcel set to all NaN's 
patchp(nexttile, 'Vertices', sphv, 'Faces', sphf, 'FaceColor', 'flat', 'FaceVertexCData', sphp+0./(sphp-7)); 
patchp(nexttile, 'Vertices', sphv, 'Faces', sphf, 'FaceColor', 'flat', 'Parcellation', sphp-1, 'FaceVertexCData', sphp+0./(sphp-7));

% Parcel level data with entire parcel(s) set to NaN
rois = sphp-1; 
data = randn(max(rois),1); 
data(6) = NaN; %data(7) = NaN; 
patchp(nexttile, 'Vertices', sphv, 'Faces', sphf, 'FaceColor', 'interp', 'Parcellation', rois, 'FaceVertexCData', data); 

% Vertex level data with some vertices set to NaN
data = sphd; 
data(data>1) = NaN; 
patchp(nexttile, 'Vertices', sphv, 'Faces', sphf, 'FaceColor', 'flat', 'Parcellation', sphp-1, 'FaceVertexCData', data); 


%% Skip over some parcels
% eg parcel IDs are 1 2 3 5 7 9 (parcels 4 6 8 absent)
figure; 

% Parcel level data with some parcels set to 0
patchp(nexttile, 'Vertices', sphv, 'Faces', sphf, 'FaceColor', 'flat', 'Parcellation', sphp.*(ismember(sphp,1:3:max(sphp)))); 

% Vertex level data with some parcels set to 0
patchp(nexttile, 'Vertices', sphv, 'Faces', sphf, 'FaceColor', 'flat', 'Parcellation', sphp.*(ismember(sphp,1:3:max(sphp))), 'FaceVertexCData', sphd); 


%% Test all boundary methods
figure; 
for ii = ["faces", "midpoint", "centroid", "edge_vertices", "edge_faces", "none"]
    patchp(nexttile, 'Vertices', sphv, 'Faces', sphf, 'Parcellation', sphp, 'BoundaryMethod', ii, 'FaceColor', 'interp'); 
    title(ii, 'Interpreter','none'); view([0 0]); axis('equal','tight','off','vis3d'); 
end
% colormap(lines(max(sphp)));


%% Input a colour for each parcel
% Note that colormap cannot change this later
figure; 
patchp(nexttile, 'Vertices', sphv, 'Faces', sphf, 'Parcellation', sphp, 'FaceVertexCData', lines(max(sphp)), ...
    'FaceColor', 'interp', 'BoundaryMethod', 'none', 'overrideAssertions', true); 
patchp(nexttile, 'Vertices', sphv, 'Faces', sphf, 'Parcellation', sphp-1, 'FaceVertexCData', lines(max(sphp-1)), ...
    'FaceColor', 'interp', 'BoundaryMethod', 'none', 'overrideAssertions', true); 

% Other examples: 
%   patchp(nexttile, 'Vertices', sphv, 'Faces', sphf, 'Parcellation', sphp-1, 'FaceVertexCData', (1:max(sphp)-1)', ...
%     'FaceColor', 'interp', 'BoundaryMethod', 'none'); 


%% Beautification example

figure; 
p = patchp(nexttile, 'Vertices', sphv, 'Faces', sphf, 'Parcellation', sphp, 'FaceVertexCData', sphd, ...
    'FaceColor', 'interp', 'EdgeColor', 'none'); 
axis equal tight off vis3d; 

p.FaceLighting = 'gouraud'; p.Clipping = 'off'; 
material dull;  
camlight(  0,15);
camlight(180,15); 


%% Annotation file
d = @(x) fullfile(fileparts(which('patchp')), 'examples', x); 
v = load(d("surface_data.mat"), 'lh_inflated_verts').lh_inflated_verts; 
f = load(d("surface_data.mat"), 'lh_faces').lh_faces; 
[~,b,c] = read_annotation('lh.HCPMMP1.annot'); 
[~,r] = ismember(b, c.table(:,5)); % get ROI IDs from annotation data

figure; 
[p,q] = patchp('Vertices', v, 'Faces', f, 'Parcellation', r, 'FaceVertexCData', r, ...
    'FaceColor', 'flat', 'EdgeColor', 'none'); 
clim(minmax(nonzeros(r))); colormap(c.table(1+any(~r):end,1:3)/255); % set colormap
colorbar; axis equal tight off vis3d; view([-90 0]); 

p.FaceLighting = 'gouraud'; 
p.Clipping = 'off'; q.boundary.Clipping = 'off'; q.nanZeroPatch.Clipping = 'off'; 
material dull;  
camlight(  0,15); 
camlight(180,15); 




