%% This script does 4 things for each subject:
% - extracts CW data from the EPrime files, 
% - converts XY locations to angles/radians (and writes these to csv file), 
% - fits the data to a mixture model (Von Mises + uniform)
% - aggregates all sub data and fits to a group model
% 
% Written by AAB 12/8/16, model fit functions from paulbays.comcode/JV10/ 
% Updated by AAB 10/4/17 to pull in patient .mat files
% TODO: incorporate swap errors


%% Setup
%datadir = '/Volumes/LMNT/MR/';
datadir = '/Volumes/LMNT/CW_PT/subject_data/';
cd(datadir)

subs = {'s01' 's02'}; %Need to make all subs similar!

% subs = {'110' '111' '113' '114' '115' '116' '117' '118' '119' '120' ...
%        '121' '122' '123' '124' '125' '126' '127' '128'};

%col_sub = nan(length(subs)+1,1);
col_k = nan(length(subs)+1,1);
col_pT = nan(length(subs)+1,1);
col_pG = nan(length(subs)+1,1);
col_LL = nan(length(subs)+1,1);
col_sub = [];
agg_resp = [];
agg_targ = [];
agg_anger = [];


%% Analyse each subject
for isub = 1:length(subs);
    curSub = subs{isub};
    col_sub{isub} = curSub;
    subdir = sprintf('%s/', curSub);
    cd(subdir);
    
    % Load CW mat files
    x = dir('R*.mat');
    flz = {x.name};

   
    fpath = sprintf('%s/', curSub); %%%% update/standardize the filenames
    fstub = sprintf('Record_S*b%d.mat'); %%%% update!
    fname = fullfile(fpath, fstub);
    z = load(fname);
    
    fprintf('Analyzing CW data for subject %d\n', curSub);

    
    
    
    
% % %     
% % %     G = global values and sub info
% % % 
% % % ?PData? files are for practice blocks. The ?data? only files preallocate trial specific info for each possible practice set. ?PDataRcd? will have the actual practice trial accuracy (16 for single practice; 32 for two practice sets)
% % % 
% % % Data_sn1_b#.mat = pre-allocated trial info
% % % Record_sn1_b#.mat = data file with participant responses for full block trials
% % % 
% % % Two Bars: 2 blocks 
% % % Listed as Task 3
% % % Blocks 1 & 2
% % % 
% % % Variable on each trial: 
% % % ?IntvofChg?	:we think means a high or low res change
% % % ?Resp?		:1/2 button press
% % % ?Correct?	:0/1 accuracy
% % % ?SDT?		:is response type
% % % 		[1,0,0] corr
% % % 		[0,1,0] Resp 1 incorrect
% % % 		[0,0,1] Resp 2 incorrect
% % % 
% % % 
% % % Color Perc: 1 block
% % % Listed as Task 5
% % % Block 3
% % % all color/location numbers are in 2 degree increments (circle is 180 deg)
% % % Variables on each trial:
% % % 
% % % Mem		:target color on normal CW
% % % TlocM/MLocM1	:location of target square on screen
% % % ClutRotDeg	:random rotation of displayed CW
% % % MemRot		:location of target color on rotated/displayed CW
% % % estimate	:location of response on circle
% % % Error		:estimate - memrot (errorx2 = true error in degrees) 
% % % 
% % % 
% % % Color WM: 2 blocks
% % % Listed as Task 1
% % % Blocks 4 & 5
% % % all color/location numbers are in 2 degree increments (circle is 180 deg)
% % % Variables on each trial:
% % % 
% % % 
% % % Mem#		:Each color in the array on normal CW, Mem1 is always target color
% % % TlocM/MLocM1	:location of target square on screen
% % % ClutRotDeg	:random rotation of displayed CW
% % % MemRot#		:location of array colors on rotated/displayed CW
% % % estimate	:location of response on circle
% % % Error		:estimate - memrot1 (errorx2 = true error in degrees) 
% % % 
% % % 

    
    
    
    
    
    
    
    
    %if NANs, remove
    RespAng = RespAng(~any(isnan(RespAng),2),:);
    TargAng = TargAng(~any(isnan(TargAng),2),:);
    absAngleError = absAngleError(~any(isnan(absAngleError),2),:);
    
    col_abserr = absAngleError;
    
    %convert to radians for model input
    col_targ = wrap(TargAng/180*pi);
    col_resp = wrap(RespAng/180*pi);
    
    % Build Aggregate
    agg_resp = [agg_resp; col_resp];
    agg_targ = [agg_targ; col_targ];
    agg_anger = [agg_anger; col_abserr];
    
   cd(datadir); %return to dat folder
%% Eprime version
    % Load raw CW Data
    fpath = 'ePrime_txt/';
    fstub = sprintf('CWdat_%d.txt', curSub);
    fname = fullfile(fpath, fstub);
    z = tdfread(fname);

%Check to make sure the subject number I added corresponds to the file to
%catch any exporting errors
    if  curSub == z.Subject(1)
        fprintf('Analyzing CW data for subject %d\n', z.Subject(1));
    else error ('Subject input mismatch!');
    end %
    
%Sort trial variables
    all_trials = cellstr(z.Running0x5BBlock0x5D); 
    TestMask = strcmp('TestList', all_trials); % only active test trials   
    ntrials = sum(TestMask);    
    
 %% Calculate angle of responses
    
 % Determine center of circle
    CenterY = z.screenheight(1)/2;
    CenterX = z.screenwidth(1)/2;
    
    % Get test trial coordinates
    RespX = z.MouseResponseX(TestMask);
    RespY = z.MouseResponseY(TestMask);
    CorrX = z.MouseCorrectX(TestMask);
    CorrY = z.MouseCorrectY(TestMask);

% Trial-by-trial analysis of angle error

    % make empty matrices
    absAngleError = nan(ntrials,1);  
    TargAng = nan(ntrials,1); 
    RespAng = nan(ntrials,1);

    for itrial = 1:ntrials

        %If they don't move the mouse, don't analyze trial
        if RespX(itrial) == CenterX && RespY(itrial) == CenterY
            absAngleError(itrial,1) = NaN;            
            TargAng(itrial,1) = NaN;
            RespAng(itrial,1) = NaN;
            
        else
            ang1 = atan2(CenterY - CorrY(itrial), ...
                CorrX(itrial) - CenterX)*180/pi;
            ang2 = atan2(CenterY - RespY(itrial), ...
                RespX(itrial) - CenterX)*180/pi; 

            rawanger = ceil(min(mod(ang1-ang2, 360),mod(ang2-ang1, 360)));           
            iangerr = max(1,rawanger);
            absAngleError(itrial,1) = iangerr;
            
            TargAng(itrial,1) = ang1;
            RespAng(itrial,1) = ang2;
        end
       
    end %itrials

    %if NANs, remove
    RespAng = RespAng(~any(isnan(RespAng),2),:);
    TargAng = TargAng(~any(isnan(TargAng),2),:);
    absAngleError = absAngleError(~any(isnan(absAngleError),2),:);

col_abserr = absAngleError;

%convert to radians for model input
    col_targ = wrap(TargAng/180*pi);
    col_resp = wrap(RespAng/180*pi);
    
% Build Aggregate 
    agg_resp = [agg_resp; col_resp];
    agg_targ = [agg_targ; col_targ];
    agg_anger = [agg_anger; col_abserr];

    

    
end %subs


%% Graph histogram
cd /Volumes/LMNT/MR/Model_Files/

nbins = 90;
figure(curSub)
    histogram(col_abserr,nbins)


%% Model fit

% Precision & Bias
    [P,B] = JV10_error(col_resp, col_targ);

% Mixture Model
    [Par, LL] = JV10_fit(col_resp, col_targ);

    col_k(isub,1) = Par(1);
    col_pT(isub,1) = Par(2);
    col_pG(isub,1) = Par(4);
    col_LL(isub,1) = LL;

%% Write out
CWhdr = {'Target' 'Response' 'AbsErr'};
CWdata = [col_targ col_resp col_abserr ];
 
      m = [CWhdr;num2cell(CWdata)];      
      cname = sprintf('ModParam_%d.csv', curSub);
          fid = fopen(cname, 'w');
          fprintf(fid, '%s,', m{1,1:end-1});
          fprintf(fid, '%s\n', m{1,end});
          fclose(fid);
      dlmwrite(cname, m(2:end,:), '-append'); 
      cd /Volumes/LMNT/MR/




end %subs


%% Create Aggregate Model fit
[Par, LL] = JV10_fit(agg_resp, agg_targ);

    col_sub(end,1) = 999;
    col_k(end,1) = Par(1);
    col_pT(end,1) = Par(2);
    col_pG(end,1) = Par(4);
    col_LL(end,1) = LL;

col_sd = rad2deg(k2sd(col_k));

cd /Volumes/LMNT/MR/Model_Files/
figure(999)
     histogram(agg_anger,90)
     saveas(gcf, 'Aggregate_Fig.png')

%% Write dataset with individual & aggregate parameters
FIThdr = {'Subject' 'K' 'sd' 'pTarget' 'pGuess' 'LL'};
FITdat = [col_sub col_k col_sd col_pT col_pG col_LL];

    x = [FIThdr;num2cell(FITdat)];
    xname = sprintf('FullParam.csv');
        fid = fopen(xname, 'w');
        fprintf(fid, '%s,', x{1,1:end-1});
        fprintf(fid, '%s\n', x{1,end});
        fclose(fid);
    dlmwrite(xname, x(2:end,:), '-append');
    cd /Volumes/LMNT/MR/
      
      

