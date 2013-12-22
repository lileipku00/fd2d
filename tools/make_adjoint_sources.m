%==========================================================================
% compute and store adjoint sources
%
% function misfit=make_adjoint_sources(u,u_0,t,mode)
%
% input:
%-------
% u: synthetic displacement seismograms
% u_0: observed displacement seismograms
% t: time axis
% veldis: 'dis' for displacements, 'vel' for velocities
% measurement:  'waveform_difference' for L2 waveform difference
%
% When u_0, i.e. the observed displacement seismograms, are set to zero, 
% the code performs data-independent measurements. 
% 
%==========================================================================

function misfit=make_adjoint_sources(u,u_0,t,veldis,measurement)

%==========================================================================
%- initialisations --------------------------------------------------------
%==========================================================================

path(path,'../input/');
path(path,'../code/propagation/');
path(path,'misfits/')
input_parameters;

fid_loc=fopen([adjoint_source_path 'source_locations'],'w');

nt=length(t);

misfit=0.0;

%- convert to velocity if wanted ------------------------------------------

if strcmp(veldis,'vel')
    nt=length(t);
    v=zeros(length(rec_x),nt);
    
    for k=1:length(rec_x)
        v(k,1:nt-1)=diff(u(k,:))/(t(2)-t(1));
        v(k,nt)=0.0;
    end
   
    u=v;
    
end

%==========================================================================
%- march through the various recodings ------------------------------------
%==========================================================================

for n=1:length(rec_x)
   
    fprintf(1,'station number %d\n',n)
    
    %- plot traces --------------------------------------------------------
    
    plot(t,u(n,:),'k')
    hold on
    plot(t,u_0(n,:),'r')
    plot(t,u(n,:)-u_0(n,:),'k--')
    hold off
   
    title(['receiver ' num2str(n) ' ,original in black, perturbed in red, difference dashed'])
    xlabel('t [s]')
    ylabel('displacement [m]')
   
    %- select time windows and taper seismograms --------------------------
   
    disp('select left window');
    [left,dummy]=ginput(1);
    disp('select_right_window');
    [right,dummy]=ginput(1);
    
    u(n,:)=taper(u(n,:),t,left,right,(right-left)/10);
    u_0(n,:)=taper(u_0(n,:),t,left,right,(right-left)/10);
    
    %- compute misfit and adjoint source time function --------------------
    
    if strcmp(measurement,'waveform_difference')
        [misfit_n,adstf]=waveform_difference(u(n,:),u_0(n,:),t);
    end
    
    misfit=misfit+misfit_n;
    
    %- plot adjoint source before time reversal ---------------------------
   
    plot(t,adstf,'k')
    xlabel('t [s]')
    title('adjoint source before time reversal')
    pause(1.0)
   
    %- write time-reversed adjoint source to file -------------------------
   
    fprintf(fid_loc,'%g %g\n',rec_x(n),rec_z(n));
    
    %- write source time functions ------------------------------------
    fn=[adjoint_source_path 'src_' num2str(n)];
    fid_src=fopen(fn,'w');
    for k=1:nt
        fprintf(fid_src,'%g\n',adstf(nt+1-k));
    end
    fclose(fid_src);
      
end

%==========================================================================
%- clean up ---------------------------------------------------------------
%==========================================================================

fclose(fid_loc);