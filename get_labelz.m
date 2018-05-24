%%% Get structure names from Table Output of SPM



save('labelz_CD')

load(TabDat_CD.mat);

clus = length(TabDat.dat);
labelz = {};
for i=1:clus
    % pv = TabDat.dat{i,7}; %peak p-val
    pv = TabDat.dat{i,3}; %cluster p-val
    if ~isempty(pv) && pv <.05
        labelz{i,1} = pv;
        coord = (TabDat.dat{i,12})';
        labelz{i,2} = coord;
        [x,y] = cuixuFindStructure(coord);
        labelz{i,3} = x;
    end
end



