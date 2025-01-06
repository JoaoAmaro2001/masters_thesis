%% How to add an inset to a plot

subplotPosition = get(gca,'position');
insetRelativePosition = [0.6 0.2 0.35 0.2]; % SouthEast. 
deltax = subplotPosition(3)*insetRelativePosition(1);
deltay = subplotPosition(4)*insetRelativePosition(2);
insetPosition = [subplotPosition(1:2) 0 0] + [deltax deltay subplotPosition(3:4).*insetRelativePosition(3:4)];
axes('Position',insetPosition)