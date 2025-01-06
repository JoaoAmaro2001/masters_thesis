function called = manualOrCalled()

    stack = dbstack;
    if isscalar(stack)
        disp('Running manually');
        called = 0;  % 0 indicates it is run manually
    else
        disp('Script is being called');
        called = 1;  % 1 indicates it is called from another script or function
    end

end
