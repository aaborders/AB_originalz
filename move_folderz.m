%move spike reg from on MR to another 
curdir = '/Volumes/LMNT/MR';
% subs = {'110' '111' '113' '114' '115' '116' '117' '118' '119' '120' ... 
%          '122' '123' '124' '125' '126' '127'}; %update as I acquire! 
%     runs = {'CW_1' 'CW_2' 'CW_3' 'CD_1' 'CD_2' 'CD_3' 'CM_1' 'CM_2'};
   
 subs = {'128'};
 runs = {'CW_1' 'CW_2' 'CW_3' 'CD_1' 'CD_2' 'CD_3' 'CM_2'};
 
for i = 1:length(subs);
    cursub=subs{i};
    
    for ir = 1:length(runs);
        currun = runs{ir};
        datadir = ['/Volumes/LMNT/MR/' cursub '/imports/' currun '/'];
        sourcedir = ['/Volumes/LMNT/MR_QA/' cursub '/' currun '/'];
        cd(sourcedir);
        
        copyfile('spike*',datadir)      
        
        cd(curdir)
    end

end




%move run data folders back into imports
curdir = '/Volumes/LMNT/MR';
subs = {'111' '113' '114' '115' '116' '117' '118' '119' '120' ... 
              '121' '122' '123' '124' '125' '126' '127' '128'}; 

for i = 1:length(subs)

    cursub=subs{i};
    datadir = ['/Volumes/LMNT/MR/' cursub '/imports/'];
    cd(datadir);

    movefile('CD*','imports/')
    movefile('CW*','imports/')
    movefile('CM*','imports/')
    movefile('mprage*','imports/')
    
    cd(curdir)

end


%move run data folders out of imports and into main sub folder
curdir = '/Volumes/LMNT/MR';
subs = {'128'}; %update as I acquire! 

for i = 1:length(subs)

    cursub=subs{i};
    datadir = ['/Volumes/LMNT/MR/' cursub '/'];
    sourcedir = ['/Volumes/LMNT/MR_QA/' cursub '/'];
    cd(datadir);

    movefile('test_folderz','imports/')
    movefile('imports/CW*')
    movefile('imports/CM*')
    movefile('imports/mprage*')
    
    cd(curdir)

end