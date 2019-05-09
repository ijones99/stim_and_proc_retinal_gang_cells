function plotc_precise_width(x,y,v, varargin)
%FUNCTION PLOTC_PRECISE_WIDTH(X,Y,V,'MARKER') plots the values of v colour coded
% at the positions specified by x and y, and v (z-axis) in a 3-D axis
% system. A colourbar is added on the right side of the figure.
%
% The colorbar strectches from the minimum value of v to its
% maximum in 9 steps (10 values).
%
% The last argument is optional to define the marker being used. The
% default is a point. To use a different marker (such as circles, ...) send
% its symbol to the function (which must be enclosed in '; see example).
%
% The plot is actually a 3D plot but the orientation of the axis is set
% such that it appears to be a plane 2D plot. However, you can toggle
% between 2D and 3D view either by using the command 'view(3)' (for 3D
% view) or 'view(2)' (for 2D), or by interactively rotating the axis
% system.
%
% Example:
% Define three vectors
%    x=1:10;y=1:10;p=randn(10,1);
%    plotc(x,y,p)
%
%    x=randn(100,1);
%    y=2*x+randn(100,1);
%    p=randn(100,1);
%    plotc(x,y,p,'d')
%    view(3)
%
% Uli Theune, University of Alberta, 2004
% modified by Stephanie Contardo, British OCeanographic Data Centre, 2006
%


marker='.';
markerSize = 10;



% check for arguments
if ~isempty(varargin)
    for i=1:length(varargin)
        if strcmp( varargin{i}, 'marker')
            marker = varargin{i+1};
        elseif strcmp( varargin{i}, 'MarkerSize')
            markerSize = varargin{i+1};
        end
    end
end


map=colormap;
miv=min(v);
mav=max(v);
clrstep = (mav-miv)/size(map,1) ;
% Plot the points
hold on
if length(markerSize) == 1
    for nc=1:size(map,1)
        iv = find(v>=miv+(nc-1)*clrstep & v<=miv+nc*clrstep) ;
        plot3(x(iv),y(iv),v(iv),marker,'color',map(nc,:),'markerfacecolor',map(nc,:),'MarkerSize',markerSize)
    end
    
else
    for nc=1:size(map,1)
        iv = find(v>=miv+(nc-1)*clrstep & v<=miv+nc*clrstep) ;
        for j=1:length(iv)
            try
                plot.circle2(x(iv(j)),y(iv(j)),markerSize(iv(j)),'EdgeColor',map(nc,:),...
                    'FaceColor',map(nc,:))
            catch
                warning('error encountered')
            end
            
            
        end
    end
    
end

hold off

% Re-format the colorbar
h=colorbar;

set(h,'ylim',[1 length(map)]);
yal=linspace(1,length(map),10);
set(h,'ytick',yal);
% Create the yticklabels
ytl=linspace(miv,mav,10);
s=char(10,4);
for i=1:10
    if min(abs(ytl)) >= 0.001
        B=sprintf('%-4.3f',ytl(i));
    else
        B=sprintf('%-3.1E',ytl(i));
    end
    s(i,1:length(B))=B;
end
set(h,'yticklabel',s);
grid on
view(2)
