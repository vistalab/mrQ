function logname=mrQ_PD_LRB1SPGR_GridParams(mrQ,FilterSize,percent_coverage)
%  logname=mrQ_PD_LRB1SPGR_GridParams(mrQ,FilterSize,percent_coverage)
%
% This function writes a file containing the parameters used in creating a
% 3D grid for creating the B1 mask. It uses a local regression.
%
%   ~INPUTS~
%               mrQ:   The mrQ structure
%        FilterSize:   The length, in millimeters, of one side of the box
%                      comprising the grid
%                      (Default is 6 millimeters)
%  percent_coverage:   Amount of overlap between boxes
%                      (Between 0 and 1; default is 0.33)  
%
%   ~OUTPUTS~
%           logname: Location of a logfile containing all the options used 
%                    during processing

%%
% We build a structure, "opt", which will be used to fit B1.   
opt.mrQfile=mrQ.name;

%opt.AnalysisInfoFile=AnalysisInfo.name;


%% Get names and files 

outDir = mrQ.outDir;
subName=mrQ.sub;

%% LR size and minimum local coverage
if notDefined('FilterSize')
    FilterSize =6;
end

if notDefined('percent_coverage')
    percent_coverage =0.33;
end

opt.percent_coverage=percent_coverage;
opt.FilterSize=FilterSize;

 opt.AlignFile=mrQ.spgr2epiAlignFile;

 opt.tisuuemaskFile=mrQ.maskepi_File;
 BM=readFileNifti(mrQ.maskepi_File);opt.pixdim=BM.pixdim;
 BM=logical(ones(size(BM.data)));

% Use the mask where we would like to have a B1 mask
opt.N_Vox2Fit=length(find(BM));
opt.TR=mrQ.SPGR_niiFile_TR;
opt.FlipAngle=mrQ.SPGR_niiFile_FA;


%%
sgename    = [subName '_B1'];
dirname    = [outDir '/tmpSGB1' ];
dirDatname = [outDir '/tmpSGB1dat'];
jumpindex  = 100; %number of boxes for each SGE run

opt.dirDatname = dirDatname;
opt.name = [dirname '/B1boxfit_iter'] ;
opt.date = date;
opt.jumpindex = jumpindex;
opt.dirname=dirname;

opt.SGE=sgename;
% Save a logfile with all the options used during processing:
logname = [outDir '/fitLogB1.mat'];
opt.logname=logname;

% Save an information file we can load afterwards, if needed.
save(opt.logname,'opt');

