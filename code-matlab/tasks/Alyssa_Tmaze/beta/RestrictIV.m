function iv_out = RestrictIV(cfg_in,iv_in,varargin)
%RESTRICTIV Restrict iv data to time intervals in n^2 time. Restricts
% contents of ivdata fields accordingly.
%data fields accordingly.
%   iv_out = RESTRICTIV(cfg,iv_in,iv_t)
%   iv_out = RESTRICTIV(cfg,iv_in,tstart,tend)
%
%
% aacarey Nov 2015
% -- uses code from MvdM restrict
% see also restrict restrict2 SelectIV RemoveIV

mfun = mfilename;

cfg_def.straddle = 1;
cfg_def.rTSD = 0;
cfg_def.verbose = 1;

% parse cfg parameters
cfg = ProcessConfig(cfg_def,cfg_in,mfun);

% check that it's an iv
if ~CheckIV(iv_in);
    error('iv_in must be an iv data type.')
end

% convert input arguments to iv if not already done
if nargin == 3
    if ~CheckIV(varargin{1})
        error('Single input argument must be iv datatype.');
    end  
    iv_r = varargin{1}; 
    
elseif nargin == 4    
    iv_r = iv(varargin{1},varargin{2}); 
    
else
    error('Unsupported number of input arguments.');
end

%restrict stuff here

keep = false(size(iv_in.tstart));

switch cfg.straddle
    case 0
        for iT = 1:length(iv_r.tstart)
            keep = keep | (iv_in.tstart >= iv_r.tstart(iT) & iv_in.tend <= iv_r.tend(iT));
        end
    case 1
        for iT = 1:length(iv_r.tstart)
            keep = keep | (iv_in.tstart >= iv_r.tstart(iT) & iv_in.tstart <= iv_r.tend(iT)) | (iv_in.tend >= iv_r.tstart(iT) & iv_in.tend <= iv_r.tend(iT));
        end
end
    
%%

keep = logical(keep);

cfg_temp.verbose = 0; % don't let SelectIV talk
iv_out = SelectIV2(cfg_temp,iv_in,keep);
% iv_out = iv_in;
% iv_out.tstart = iv_out.tstart(keep);
% iv_out.tend = iv_out.tend(keep);
% 
% % also remove data from .ivdata fields, if they exist
% if isfield(iv_in,'ivdata')
%     ivfields = fieldnames(iv_in.ivdata);
%     for iField = 1:length(ivfields)
%         iv_out.ivdata.(ivfields{iField}) = iv_out.ivdata.(ivfields{iField})(keep);
%     end
% end

% tell me how many
if cfg.verbose
    disp([mfun,': ',num2str(length(iv_in.tstart)),' intervals in, ',num2str(length(iv_out.tstart)),' intervals out.'])
end

% housekeeping
iv_out.cfg.history.mfun = cat(1,iv_in.cfg.history.mfun,mfun);
iv_out.cfg.history.cfg = cat(1,iv_in.cfg.history.cfg,{cfg});

end

