function mazesolver(file)
    %read image and break in down into rgb matricies
    disp('Reading image');
    Itemp = imread(file);
    [dim, ~, depth] = size(Itemp);
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
    
    %get the indicies of the walls of the maze
    disp('Finding walls');
    walls = find(~Ired);
    
    %construct a dim by dim graph that represents the maze png
    %TODO make this work for non-square images
    disp('Generating Graph');
    g = graph;
    %TODO dynamically find dim
    %dim = 1802;
    index = 1:dim^2;
    a = reshape(index, dim, dim);
    a = string(a);
    g = addnode(g, string(index));
    
    %connect the nodes into a lattice formation
    disp('Adding horizontal edges');
    g = addedge(g, a(1:size(a,1), 1:size(a,2)-1), a(1:size(a,1), 2:size(a,2)));
    disp('Adding vertical edges');
    g = addedge(g, a(1:size(a,1)-1, 1:size(a,2)), a(2:size(a,1), 1:size(a,2)));
    disp('Adding right diagonal edges');
    g = addedge(g, a(1:size(a,1)-1, 1:size(a,2)-1), a(2:size(a,1), 2:size(a,2)));
    disp('Adding left diagonal edges');
    g = addedge(g, a(2:size(a,1), 1:size(a,2)-1), a(1:size(a,1)-1, 2:size(a,2)));
    disp('Done adding edges');
    
    %remove the nodes that correspond to the walls on the maze
    disp('Adding maze walls to graph');
    g = rmnode(g, string(walls));
    
    %find the start and end indicies
    %TODO dynamically find these values instead of hard coding
    start = dim*2+1;
    finish = dim*dim-3;
    
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
