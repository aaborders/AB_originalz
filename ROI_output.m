%% output_ROI_cons.m

%% This will extract, for each subject, the % signal change for each contrast.
%%%%% It will save out the results in a .csv file (MxN matrix), 
%%%%% where M is # of subjects and N is # of contrasts
%% It will also plot the mean values for each contrast 
%% (with SEM bars), which can be saved manually.


clear
datadir = 'E:/analysis/combo_model/';
subjs = [110, 113, 114, 115, 116, 117, 119, 120];

cons = {'con_0004.img' 'con_0005.img' 'con_0008.img'}; %change to the cons of interest
fullconlabels = {'CD_hvm' 'CW_hvm' 'interaction'};
conlabels = {'CD_hvm' 'CW_hvm' 'interaction'};
ROI_dir = ['E:/ROIs_PA_MTL/'];

ROIs = {[strcat(ROI_dir, 'AMY_L_traced_mask.img')] ... 
    [strcat(ROI_dir, 'AMY_R_traced_mask.img')] ... 
    [strcat(ROI_dir, 'HIPP_HEAD_L_mask.img')] ... 
    [strcat(ROI_dir, 'HIPP_HEAD_R_mask.img')]};

output_dir = [strcat(datadir,'/RFX/rois/')];

for curROI = 1:length(ROIs);
    fprintf('Starting %s\n',ROIs{curROI})
    cnt = 2;
    clear output
    %output=cell(length(subjs)+4,length(cons)+1);
    %output(1,1) = {'subject'};
    output(1,1) = 0;
    [roi_y roi_xyz] = spm_read_vols(spm_vol(ROIs{curROI}));
    for  curSub = 1:length(subjs)     
        fprintf('Working on %d\n',subjs(curSub))
        
        cd([datadir [(num2str(subjs(curSub)))]])
        for curCon = 1:length(cons)
            [con_y con_xyz] = spm_read_vols(spm_vol(cons{curCon}));
            t = con_y(roi_y~=0 & ~isnan(roi_y));
            t = t(~isnan(t));
            
            output(cnt,1) = subjs(curSub);            
            output(cnt,2+(curCon - 1)*1) = mean(t);
            output(1,(2+(curCon - 1)*1)) = curCon;
            
        end
        cnt = cnt + 1;
    end
    
    for xx=2:length(output(1,:))
        %avg(xx-1)=mean(cell2mat(output(2:length(subjs)+1),xx));
        %sem(xx-1)=std(cell2mat(output(2:length(subjs)+1,xx)))/sqrtm(length(output(:,1))-1);
        %output(cnt+1,xx) = {avg(xx-1)};
        %output(cnt+2,xx) = {sem(xx-1)};
        avg(xx-1)=mean(output(2:length(subjs)+1,xx));
        sem(xx-1)=std(output(2:length(subjs)+1,xx))/sqrtm(length(output(:,1))-1);
        output(cnt+1,xx) = avg(xx-1);
        output(cnt+2,xx) = sem(xx-1);
    end
    figure(curROI)
    bar(avg)
    hold on
    set(gca,'XTickLabel',conlabels)
    errorbar(avg,sem)
    title(ROIs{curROI})
    [a b c] = fileparts(ROIs{curROI});
    cd(output_dir)
    %     xlswrite('cons.xls',output,b) %using r2007a xlswrite
    csvwrite(strcat('cons_n8_',b,'.csv'),output);
end

