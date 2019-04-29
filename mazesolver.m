function mazesolver(file)
    %read image and break in down into rgb matricies
    disp('Reading image');
    Itemp = imread(file);
    [m, n, depth] = size(Itemp);
    if depth == 1
        disp('Converting to RGB');
        Itemp = double(Itemp);
        Itemp = Itemp - 1;
        Itemp = Itemp * -255;
        Itemp = uint8(Itemp);
        I = cat(3, Itemp, Itemp, Itemp);
    else
        I = Itemp;
    end
    %disp(I(:,:,1));
    Ired = I(:,:,1);
    Igreen = I(:,:,2);
    Iblue = I(:,:,3);
    
    [width, indicies] = getInfo(Ired);
    %disp(width);
    %return;
    
    %get the indicies of the walls of the maze
    disp('Finding walls');
    walls = find(~Ired);
    
    %construct a dim by dim graph that represents the maze png
    disp('Generating Graph');
    g = graph;
    index = 1:(m*n);
    a = reshape(index, m, n);
    a = string(a);
    g = addnode(g, string(index));
    
    %connect the nodes into a lattice formation
    disp('Adding horizontal edges');
    g = addedge(g, a(1:size(a,1), 1:size(a,2)-1), a(1:size(a,1), 2:size(a,2)));
    disp('Adding vertical edges');
    g = addedge(g, a(1:size(a,1)-1, 1:size(a,2)), a(2:size(a,1), 1:size(a,2)));
    %Uncomment the following 4 lines for a prettier path but slower execution time
    disp('Adding right diagonal edges');
    g = addedge(g, a(1:size(a,1)-1, 1:size(a,2)-1), a(2:size(a,1), 2:size(a,2)));
    disp('Adding left diagonal edges');
    g = addedge(g, a(2:size(a,1), 1:size(a,2)-1), a(1:size(a,1)-1, 2:size(a,2)));
    disp('Done adding edges');
    
    %remove the nodes that correspond to the walls on the maze
    disp('Adding maze walls to graph');
    g = rmnode(g, string(walls));
    
    %find the start and end indicies
    start = indicies(1, 1);
    finish = indicies(2, 1);
    
    %find the shortest path through the graph from start to finish
    disp('Finding shortest path');
    p = shortestpath(g, string(start), string(finish));
    p = double(p);
    
    %print the path found as a red line
    disp('Printing path');
    Igreen(p) = 0;
    Iblue(p) = 0;
    I(:,:,2) = Igreen;
    I(:,:,3) = Iblue;
    
    %show the answer to the maze
    disp('Done');
    imshow(I);
end

function [width, indicies] = getInfo(Ired)
    %get dimentions of image
    [m, n] = size(Ired);
    
    %get the edges of the image
    top = Ired(1,:);
    bottom = Ired(m,:);
    left = Ired(:,1);
    right = Ired(:,n);
    
    
    targets = [];   %the index of where the exit and entrance is
    %test if there is an entrance in the top edge
    t = [find(top~=0, 1, 'first') find(top~=0, 1, 'last')];
    temp = 1;
    if isempty(t)
        t = [-1, -1];
        temp = [];
    end
    targets = [targets temp];
    %test if there is an entrance in the bottom edge
    b = [find(bottom~=0, 1, 'first') find(bottom~=0, 1, 'last')];
    temp = 2;
    if isempty(b)
        b = [-1, -1];
        temp = [];
    end
    targets = [targets temp];
    %test if there is an entrance in the left edge
    l = [find(left~=0, 1, 'first') find(left~=0, 1, 'last')];
    temp = 3;
    if isempty(l)
        l = [-1, -1];
        temp = [];
    end
    targets = [targets temp];
    %test if there is an entrance in the right edge
    r = [find(right~=0, 1, 'first') find(right~=0, 1, 'last')];
    temp = 4;
    if isempty(r)
        r = [-1, -1];
        temp = [];
    end
    targets = [targets temp];
    
    %add indices to matrix
    solutions = [t; b; l; r];
    
    %disp(solutions);
    %disp(targets);
    
    %caclulate width
    width = abs(solutions(targets(1), 1) - (solutions(targets(1), 2)+1));
    
    %convert indice matrix to a vector in the original maze-space
    indicies = [];
    for i = targets
        switch i
            case 1
                indicies = [indicies; n*(solutions(1, 1)-1)+1 n*(solutions(1, 2)-1)+1];
            case 2
                indicies = [indicies; n*(solutions(2, 1)) n*(solutions(2, 2))];
            case 3
                indicies = [indicies; solutions(3, 1) solutions(3, 2)];
            case 4
                indicies = [indicies; n*(m-1)+(solutions(4, 1)) n*(m-1)+(solutions(1, 2))];
        end
        
    end
    %disp(indicies);
end

