function txtout = struct2text(fid, s, indent)
    % struct2text Recursively prints the contents of a struct to a file or console.
    %
    % Parameters:
    %   fid    - File identifier for the open text file (use 1 for console output)
    %   s      - The struct to print
    %   indent - (Optional) Indentation string for nested structures

    if nargin < 3
        indent = '';
    end

    txtout = ''; % Initialize the output text variable

    fields = fieldnames(s);
    for i = 1:numel(fields)
        field = fields{i};
        value = s.(field);
        if isstruct(value)
            line = sprintf('%s%s:\n', indent, field);
            fprintf(fid, '%s', line);
            txtout = [txtout line];
            nested_txt = struct2text(fid, value, [indent '    ']);
            txtout = [txtout nested_txt];
        elseif isnumeric(value)
            if isscalar(value)
                line = sprintf('%s%s: %g\n', indent, field, value);
            else
                line = sprintf('%s%s: [', indent, field);
                line = [line sprintf(' %g', value)];
                line = [line ' ]\n'];
            end
            fprintf(fid, '%s', line);
            txtout = [txtout line];
        elseif iscell(value)
            line = sprintf('%s%s: {', indent, field);
            for j = 1:numel(value)
                elem = value{j};
                elem_str = value2str(elem);
                line = [line sprintf(' %s', elem_str)];
            end
            line = [line ' }\n'];
            fprintf(fid, '%s', line);
            txtout = [txtout line];
        else
            value_str = value2str(value);
            line = sprintf('%s%s: %s\n', indent, field, value_str);
            fprintf(fid, '%s', line);
            txtout = [txtout line];
        end
    end
end

function str = value2str(value)
    % value2str Safely converts any value to a string representation
    %
    % Parameters:
    %   value - The value to convert
    %
    % Returns:
    %   str - The string representation of the value

    if isnumeric(value)
        if isscalar(value)
            str = sprintf('%g', value);
        else
            str = ['[' sprintf(' %g', value) ' ]'];
        end
    elseif islogical(value)
        if isscalar(value)
            str = mat2str(value);
        else
            str = ['[' sprintf(' %d', value) ' ]'];
        end
    elseif ischar(value)
        str = ['''' value ''''];
    elseif isstring(value)
        str = ['"' char(value) '"'];
    elseif iscell(value)
        str = '{';
        for k = 1:numel(value)
            str = [str ' ' value2str(value{k})];
        end
        str = [str ' }'];
    elseif isstruct(value)
        str = '<struct>';
    elseif isdatetime(value)
        str = datestr(value);
    elseif isa(value, 'categorical')
        str = char(value);
    else
        % For other data types, use class name or convert to string if possible
        try
            str = char(value);
        catch
            str = ['<' class(value) '>'];
        end
    end
end
