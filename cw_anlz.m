function [err_ang, anglz, radz, Param_var] = cw_anlz(respx, targx, respy, targy, screenHEIGHT, screenWIDTH)
try
    CenterY = screenHEIGHT/2;
    CenterX = screenWIDTH/2;
catch
    warning('No screen dimensions input, assuming 1024x1280');
    CenterY = 512;
    CenterX = 640;
end

if length(respx) == length(targx) && length(respy) == length(targy);    
else error('Warning: target and response vector lengths are unequal');
end

ntrials = length(respx);

% make empty matrices
    absAngleError = nan(ntrials,1);  
    TargAng = nan(ntrials,1); 
    RespAng = nan(ntrials,1);

    for itrial = 1:ntrials;

        % NaN the trial if they don't move the mouse
        if respx(itrial) == CenterX && respy(itrial) == CenterY
            absAngleError(itrial,1) = NaN;            
            TargAng(itrial,1) = NaN;
            RespAng(itrial,1) = NaN;
            
        else
            ang1 = atan2(CenterY - targy(itrial), ...
                targx(itrial) - CenterX)*180/pi;
            ang2 = atan2(CenterY - respy(itrial), ...
                respx(itrial) - CenterX)*180/pi; 

            rawanger = ceil(min(mod(ang1-ang2, 360),mod(ang2-ang1, 360)));           
            iangerr = max(1,rawanger);
            absAngleError(itrial,1) = iangerr;
            
            TargAng(itrial,1) = ang1;
            RespAng(itrial,1) = ang2;
        end       
    end %itrials

    %if NANs, remove
    anglz.resp = RespAng(~any(isnan(RespAng),2),:);
    anglz.targ = TargAng(~any(isnan(TargAng),2),:);
    
    absAngleError = absAngleError(~any(isnan(absAngleError),2),:);    
    err_ang = absAngleError;
    
    %convert to radians for model input
    radz.targ = wrap(TargAng/180*pi);
    radz.resp = wrap(RespAng/180*pi);
    
    % fit to mixture model
    [Par, LL] = JV10_fit(col_resp, col_targ);
    [P,B] = JV10_error(col_resp, col_targ);
    
    Param_var.k = Par(1);
    Param_var.sd = rad2deg(k2sd(Par(1)));
    Param_var.pT = Par(2);
    Param_var.pG = Par(4);
    Param_var.LL = LL;
    Param_var.prec = P;
    Param_var.bias = B;

end %anlzCWcoord