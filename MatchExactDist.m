tic
data = importdata([folder '\data\data_' file '.mat']);
dta = reshape(struct2array(data), [], numel(fieldnames(data)));

cov_dta = cov(dta(:,4:end));

if weight=="diag"
    cov_dta = eye(size(cov_dta)).*cov_dta;
end

inv_cov = inv(cov_dta); % unit, treat, bin, distvars

for b=1:max(dta(:,3))
    disp(['Match bin ' num2str(b) ' of ' num2str(max(dta(:,3)))])
    dta_bin = dta(dta(:,3)==b,[1:2 4:end]); % unit, treat, distvars
    treat   = dta_bin(dta_bin(:,2)==1,[1 3:end]); % unit, distvars
    ctrl    = dta_bin(dta_bin(:,2)==0,[1 3:end]); % unit, distvars
    if ~(isempty(treat) || isempty(ctrl))
        dist = nan(length(treat(:,1)),length(ctrl(:,1)));
        for t=1:length(treat(:,1))
            for c=1:length(ctrl(:,1))                
                dist(t,c) = (treat(t,2:end)-ctrl(c,2:end))*inv_cov*(treat(t,2:end)-ctrl(c,2:end)).'; %#ok<MINV>
            end
        end
        dist = sqrt(dist./length(treat(1,2:end)));
        [M,I] = min(dist,[],2);
        unit = treat(:,1);
        match = ctrl(I,1);
        if b==1
            matched = [unit match M];
        else
            matched = [matched; [unit match M]];
        end
    end
end
toc
writematrix(matched, [folder '\data\match_' file '.csv']);

%%
fid = fopen([folder '\data\match_done.txt'],'wt');
fprintf(fid, 'Matching done!');
fclose(fid);