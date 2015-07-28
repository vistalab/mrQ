function mrQ_fitB1LR_Call(opt_logname,SunGrid,RunSelectedJob,clobber)
% function mrQ_fitB1LR_Call(opt_logname,SunGrid,RunSelectedJob,clobber)
%
%This function loads the opt structure that contains all the fit
% information and sends it to the computer grid if one is defined (SunGrid
% and/or proclus). If no grid is defined, the function will send the fit
% information to the local computer solver (SGE is faster, but it works 
% fine with out it as well).
%
%  INPUTS
%     opt_logname: Directory to the .mat file containing the appropriate
%                  parameters, as created in mrQ_PD_LRB1SPGR_GridParams.m
%         SunGrid: Whether to use the SunGrid; default is no.
%  RunSelectedJob:
%         clobber: Default is false.
%
%

load(opt_logname);
dirname=opt.dirname;
sgename=opt.SGE;
jumpindex=opt.jumpindex ;

if notDefined('clobber')
    clobber =false;
end

if clobber && (exist(dirname,'dir'))
    % In the case we start over and there are old fits, 
    % so we will delete them
    eval(['! rm -r ' dirname]);
end

if (~exist(dirname,'dir')),
        mkdir(dirname);
end 
%%   Perform the gain fits
% Perform the fits for each box using the SunGrid Engine
if SunGrid==1; %if there is a grid
    
     if notDefined('RunSelectedJob')
    
    % Check to see if there is an existing SGE job that can be
    % restarted. If "no", start the job; if "yes", prompt the user.
    
    % should we control the sgeoutput clear it before we start?
    %    eval(['!rm -f ~/sgeoutput/*' sgename '*'])
    %    sgerun2('mrQ_B1_LRFit(opt,jumpindex,jobindex);',sgename,1,1:ceil(opt.N_Vox2Fit/jumpindex),[],[],5000);
        
            sgerun('mrQ_B1_LRFit(opt_logname,jumpindex,jobindex);',sgename,1,1:ceil(opt.N_Vox2Fit/jumpindex),[],[],5000);
     else
         % Run only the selected jobs  
           MissingFileNumber=mrQ_multiFit_HowIsMissing( dirname,N_Vox2Fit,jumpindex); % the job to run
           sgerun('mrQ_B1_LRFit(opt_logname,jumpindex,jobindex);',sgename,1,MissingFileNumber,[],[],5000);
                  
           % (We can also add an interactive call.
           % The code for that is commented below.)
           
     end
          
    
else %if there is not a grid
    
    % Without a grid, this will take very long.
    disp('No parallel computation grid is used to fit PD. Using the local machine instead.');
    disp('      This may take a long time!!!');
    
    % In this case, the jumpindex is the number of voxels to fit (no jumps, only one job)
    jumpindex=   opt.N_Vox2Fit;
    opt.jumpindex=jumpindex;
    save(opt.logname,'opt');
    mrQ_B1_LRFit(opt_logname,jumpindex,1);
 
     
end




%%

        
%         if notDefined('RunSelectedJob')
%             
%             % Prompt the user
%             inputstr = sprintf('An existing SGE run was found. \n Would you like to try and finish the exsist SGE run?');
%             RunSelectedJob = questdlg( inputstr,'mrQ_B1_LRFit','Yes','No','Yes' );
%             if strcmpi(RunSelectedJob,'yes'), RunSelectedJob = true; end
%             if strcmpi(RunSelectedJob,'no'),  RunSelectedJob = false; end
%         end
%         
%         % User opted to try to finish the started SGE run
%         if RunSelectedJob==true
%             MissingFileNumber=mrQ_multiFitControl( dirname,N_Vox2Fit,jumpindex)
%             
%             %% should we clean the SGE output Dir ?
%             if length(find(reval)) > 0
%                 eval(['!rm -f ~/sgeoutput/*' sgename '*'])
%             end
%         end
%          
%         
% %                     for kk=1:length(reval)
% %                         sgerun2('mrQ_B1_LRFit(opt,jumpindex,jobindex);',[sgename num2str(kk)],1,MissingFileNumber(kk),[],[],5000);
% %                     end
%                     sgerun('mrQ_B1_LRFit(opt,jumpindex,jobindex);',sgename,1,MissingFileNumber,[],[],5000);
%                 end
%             end
%             
%             % User opted to restart the existing SGE run
%         elseif RunSelectedJob==false,
%             t = pwd;
%             cd (opt.outDir)
%             eval(['!rm -rf ' dirname]);
%             cd (t);
%             eval(['!rm -f ~/sgeoutput/*' sgename '*'])
%             mkdir(dirname);
%             if proclass==1
%                 sgerun2('mrQ_B1_LRFit(opt,jumpindex,jobindex);',sgename,1,1:ceil(opt.N_Vox2Fit/jumpindex),[],[],5000);
%             else
%                 sgerun('mrQ_B1_LRFit(opt,jumpindex,jobindex);',sgename,1,1:ceil(opt.N_Vox2Fit/jumpindex),[],[],5000);
%                 
%             end
%         else
%             error('User cancelled');
%         end
%         
%         end
    
        
