% HOMOGRAPHY2D - computes 2D homography
%
% Usage:   H = homography2d(x1, x2)
%          H = homography2d(x)
%
% Arguments:
%          x1  - 3xN set of homogeneous points
%          x2  - 3xN set of homogeneous points such that x1<->x2
%         
%           x  - If a single argument is supplied it is assumed that it
%                is in the form x = [x1; x2]
% Returns:
%          H - the 3x3 homography such that x2 = H*x1
%
% This code follows the normalised direct linear transformation 
% algorithm given by Hartley and Zisserman "Multiple View Geometry in
% Computer Vision" p92.

% Copyright (c) 2003-2005 Peter Kovesi
% School of Computer Science & Software Engineering
% The University of Western Australia
% pk at csse uwa edu au
% http://www.csse.uwa.edu.au/~pk
% 
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, subject to the following conditions:
% 
% The above copyright notice and this permission notice shall be included in 
% all copies or substantial portions of the Software.
%
% The Software is provided "as is", without warranty of any kind.

% May 2003  - Original version.
% Feb 2004  - Single argument allowed for to enable use with RANSAC.
% Feb 2005  - SVD changed to 'Economy' decomposition (thanks to Paul O'Leary)

function Rigid = rigid2d(varargin)
    
    [x1, x2] = checkargs(varargin(:));
%     [rows,npts] = size(x1);
%     if rows == 2    % Pad data with homogeneous scale factor of 1
%         x1 = [x1; ones(1,npts)];
%         x2 = [x2; ones(1,npts)];        
%     end
    x1=x1(1:2,:)';
    x2=x2(1:2,:)';
    % Attempt to normalise each set of points so that the origin 
    % is at centroid and mean distance from origin is sqrt(2).
    centroid_x1 = mean(x1);
    centroid_x2 = mean(x2);

    N = size(x1,1);
    p1 = x1 - repmat(centroid_x1, N, 1);
    p2 = x2 - repmat(centroid_x2, N, 1);
    H = p1' * p2;

    [U,~,V] = svd(H);

    R = V*U';

    if det(R) < 0
        %printf("Reflection detected\n");
        V(:,2) = -V(:,2);
        R = V*U';
    end
    alpha=trace(p2*R*p1')/trace(p1'*p1);
    t = -alpha*R*centroid_x1' + centroid_x2';
    Rigid=eye(3);
    Rigid(1:2,1:2)=R;
    Rigid(1:2,3)=t;

%--------------------------------------------------------------------------
% Function to check argument values and set defaults

function [x1, x2] = checkargs(arg);
    
    if length(arg) == 2
	x1 = arg{1};
	x2 = arg{2};
	if ~all(size(x1)==size(x2))
	    error('x1 and x2 must have the same size');
	elseif size(x1,1) ~= 3
	    error('x1 and x2 must be 3xN');
	end
	
    elseif length(arg) == 1
	if size(arg{1},1) ~= 6
	    error('Single argument x must be 6xN');
	else
	    x1 = arg{1}(1:3,:);
	    x2 = arg{1}(4:6,:);
	end
    else
	error('Wrong number of arguments supplied');
    end
    