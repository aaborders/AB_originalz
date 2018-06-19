clear
cur_dir = pwd;
cd /Users/aborders/Dropbox/Projects/DTI/data/
  %Set working directory


[z,headervars] = eprimetxt2vars('CW_DTI-101-1.txt');

CWmask = strcmp('CWTrials', cellstr(z.Procedure));
ntrials = sum(CWmask);

rx = z.MouseResponseX(CWmask);
ry = z.MouseResponseY(CWmask);
cx = z.MouseCorrectX(CWmask);
cy = z.MouseCorrectY(CWmask);

    respX = cell2str(rx);
    respY = cellstr(ry);
    corrX = cellstr(cx);
    corrY = cellstr(cy);


    absAngleError = nan(ntrials,1);  
    TargAng = nan(nPre,1); 
    RespAng = nan(nPre,1);

    for itrial = 1:nPre

        %If they don't move the mouse, don't analyze trial
        if RespXpre(itrial) == CenterX && RespYpre(itrial) == CenterY
            absAngleError(itrial,1) = NaN;            
            TargAng(itrial,1) = NaN;
            RespAng(itrial,1) = NaN;
            
        else
            ang1 = atan2(CenterY - CorrYpre(itrial), ...
                CorrXpre(itrial) - CenterX)*180/pi;
            ang2 = atan2(CenterY - RespYpre(itrial), ...
                RespXpre(itrial) - CenterX)*180/pi; 

            rawanger = ceil(min(mod(ang1-ang2, 360),mod(ang2-ang1, 360)));           
            iangerr = max(1,rawanger);
            absAngleError(itrial,1) = iangerr;
            
            TargAng(itrial,1) = ang1;
            RespAng(itrial,1) = ang2;
        end
       
    end %iPRE trials












  
subs = {143};



col_sub = nan(length(subs),1);
col_grp = nan(length(subs),1);
col_k = nan(length(subs),1);
col_pT = nan(length(subs),1);
col_pG = nan(length(subs),1);
col_LL = nan(length(subs),1);
col_sd = nan(length(subs),1);

agg_resp = [];
agg_targ = [];
agg_anger = [];

CenterY = 512;
CenterX = 640;

for isub = 1:length(subs);
    curSub = subs{isub};
    %curSub = str2num(subs{isub});

    fname = sprintf('%d.txt', curSub); %create file name
    z = tdfread(fname);
    %z = tdfread('108.txt');
        try  curSub == z.Subject(1);
        fprintf('Analyzing data for subject %d\n', z.Subject(1));
        catch
            warning('warning');
            fprintf('Subject %d input mismatch!\n', curSub);
        end     
%     CenterY = z.screenheight(1)/2;
%     CenterX = z.screenwidth(1)/2;
    
    CWmask = strcmp('CWTrials', cellstr(z.Procedure0x5BTrial0x5D));



col_sub(isub) = curSub;

%% Calculate angle of responses PRE
  
    % Get test trial coordinates
    RespX = cellstr(z.MouseResponseX);
    RespY = cellstr(z.MouseResponseY);
    CorrX = cellstr(z.MouseCorrectX);
    CorrY = cellstr(z.MouseCorrectY);
    
    RespXpre = RespX(PREmask);
    RespYpre = RespY(PREmask);
    CorrXpre = CorrX(PREmask);
    CorrYpre = CorrY(PREmask);
    
    RespXpre = cellfun(@str2double,RespXpre);
    RespYpre = cellfun(@str2double,RespYpre);
    CorrXpre = cellfun(@str2double,CorrXpre);
    CorrYpre = cellfun(@str2double,CorrYpre);

% Trial-by-trial analysis of angle error

    % make empty matrices
    absAngleError = nan(nPre,1);  
    TargAng = nan(nPre,1); 
    RespAng = nan(nPre,1);

    for itrial = 1:nPre

        %If they don't move the mouse, don't analyze trial
        if RespXpre(itrial) == CenterX && RespYpre(itrial) == CenterY
            absAngleError(itrial,1) = NaN;            
            TargAng(itrial,1) = NaN;
            RespAng(itrial,1) = NaN;
            
        else
            ang1 = atan2(CenterY - CorrYpre(itrial), ...
                CorrXpre(itrial) - CenterX)*180/pi;
            ang2 = atan2(CenterY - RespYpre(itrial), ...
                RespXpre(itrial) - CenterX)*180/pi; 

            rawanger = ceil(min(mod(ang1-ang2, 360),mod(ang2-ang1, 360)));           
            iangerr = max(1,rawanger);
            absAngleError(itrial,1) = iangerr;
            
            TargAng(itrial,1) = ang1;
            RespAng(itrial,1) = ang2;
        end
       
    end %iPRE trials

     %if NANs, remove
    RespAng = RespAng(~any(isnan(RespAng),2),:);
    TargAng = TargAng(~any(isnan(TargAng),2),:);
    absAngleError = absAngleError(~any(isnan(absAngleError),2),:);
    
    col_abserr = absAngleError;

%convert to radians for model input
    col_targ = wrap(TargAng/180*pi);
    col_resp = wrap(RespAng/180*pi);
    
 % Precision & Bias
    [P,B] = JV10_error(col_resp, col_targ);

% Mixture Model
    [Par, LL] = JV10_fit(col_resp, col_targ);

    col_k(isub,1) = Par(1);
    col_pT(isub,1) = Par(2);
    col_pG(isub,1) = Par(4);
    col_LL(isub,1) = LL;  
    col_sd(isub,1) = rad2deg(k2sd(Par(1)));
    

%% Calculate angle of responses POST
  
    % Get test trial coordinates
    
    RespXpost = RespX(POSTmask);
    RespYpost = RespY(POSTmask);
    CorrXpost = CorrX(POSTmask);
    CorrYpost = CorrY(POSTmask);
    
    RespXpost = cellfun(@str2double,RespXpost);
    RespYpost = cellfun(@str2double,RespYpost);
    CorrXpost = cellfun(@str2double,CorrXpost);
    CorrYpost = cellfun(@str2double,CorrYpost);

% Trial-by-trial analysis of angle error

    absAngleError = nan(nPost,1);  
    TargAng = nan(nPost,1); 
    RespAng = nan(nPost,1);

    for itrial = 1:nPost

        %If they don't move the mouse, don't analyze trial
        if RespXpost(itrial) == CenterX && RespYpost(itrial) == CenterY
            absAngleError(itrial,1) = NaN;            
            TargAng(itrial,1) = NaN;
            RespAng(itrial,1) = NaN;
          

            
        else
            ang1 = atan2(CenterY - CorrYpost(itrial), ...
                CorrXpost(itrial) - CenterX)*180/pi;
            ang2 = atan2(CenterY - RespYpost(itrial), ...
                RespXpost(itrial) - CenterX)*180/pi; 

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
    
 % Precision & Bias
 %   [P,B] = JV10_error(col_resp, col_targ);

% Mixture Model
    [Par, LL] = JV10_fit(col_resp, col_targ);

    col_POST_k(isub,1) = Par(1);
    col_POST_pT(isub,1) = Par(2);
    col_POST_pG(isub,1) = Par(4);
    col_POST_LL(isub,1) = LL; 
    col_POST_sd(isub,1) = rad2deg(k2sd(Par(1)));


end %sub


%% Write dataset with individual & aggregate parameters
FIThdr = {'Subject' 'Group' 'Pre K' 'Post K' 'Pre sd' 'Post sd' 'Pre pTarget' 'Post pTarget' 'Pre pGuess' 'Post pGuess' 'Pre LL' 'Post LL'};
FITdat = [col_sub col_grp col_k col_POST_k col_sd col_POST_sd col_pT col_POST_pT col_pG col_POST_pG col_LL col_POST_LL];

    x = [FIThdr;num2cell(FITdat)];
    xname = sprintf('CW_parameters_4.csv');
        fid = fopen(xname, 'w');
        fprintf(fid, '%s,', x{1,1:end-1});
        fprintf(fid, '%s\n', x{1,end});
        fclose(fid);
    dlmwrite(xname, x(2:end,:), '-append');






% cd /plots/
% 
% nbins = 90;
% figure(curSub)
%     histogram(col_abserr,nbins)

% % Build Aggregate 
% if strcmp('MF',cond);
%     aggMF_resp = [aggMF_resp; col_resp];
%     aggMF_targ = [aggMF_targ; col_targ];
%     aggMF_anger = [aggMF_anger; col_abserr];
%     
% elseif 
%     strcmp('MW',cond);
%     aggMW_resp = [aggMW_resp; col_resp];
%     aggMW_targ = [aggMW_targ; col_targ];
%     aggMW_anger = [aggMW_anger; col_abserr];
% end
