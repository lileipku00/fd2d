if (mod(n,4)==0)
    
    %- plot source and receiver positions ---------------------------------
    
    hold on
    
    if (strcmp(simulation_mode,'forward') || strcmp(simulation_mode,'forward_correlation'))
        
        for k=1:ns
            plot(src_x(k),src_z(k),'kx')
        end
        
    end
    
    if (strcmp(simulation_mode,'forward') || strcmp(simulation_mode,'forward_correlation') || strcmp(simulation_mode,'correlation'))
    
        for k=1:n_receivers
            plot(rec_x(k),rec_z(k),'ko')
        end
        
    end
   
        
    %- plot velocity field ------------------------------------------------
   
    pcolor(X,Z,v');
    set(gca,'FontSize',20);
    axis image
    
    %- scale, label, etc ... ----------------------------------------------
    
    if (n<0.8*length(t))
        scale=max(max(abs(v)));
    end
   
    caxis([-scale scale]);
    colormap(cm);
    shading interp
    xlabel('x [m]','FontSize',20);
    ylabel('z [m]','FontSize',20);
    
    if (strcmp(simulation_mode,'forward') || strcmp(simulation_mode,'forward_correlation'))
        title('velocity field [m/s]','FontSize',20);
    elseif (strcmp(simulation_mode,'correlation') && t(n)<0)
        title('acausal correlation field','FontSize',20);
    elseif (strcmp(simulation_mode,'correlation') && t(n)>=0)
        title('causal correlation field','FontSize',20);
    end
        
    pause(0.01)
    
    hold off
    clf
    
    %- record movie -------------------------------------------------------
    
    if strcmp(make_movie,'yes')
    
        if exist('movie_index','var')
            movie_index=movie_index+1;
        else
            movie_index=1;
        end
        
        M(movie_index)=getframe(gcf);
        
    end
            
end