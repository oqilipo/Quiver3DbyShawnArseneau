function RGBvalue = ColorSpec_to_RGBvalue(name)

% RGBvalue = ColorSpec_LongName_to_RGBvalue(LongName) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     
%     Given the color name ('r' or 'red',...) convert to the RGB equivalent
%         
% 
%     Author: Shawn Arseneau
%     Created: September 14, 2006
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    switch(lower(name))
        case {'y','yellow'}
            RGBvalue = [1 1 0];
        case {'m','magenta'}
            RGBvalue = [1 0 1];            
        case {'c','cyan'}
            RGBvalue = [0 1 1];            
        case {'r','red'}
            RGBvalue = [1 0 0];            
        case {'g','green'}
            RGBvalue = [0 1 0];            
        case {'b','blue'}
            RGBvalue = [0 0 1];            
        case {'w','white'}
            RGBvalue = [1 1 1];            
        case {'k','black'}
            RGBvalue = [0 0 0];            
        otherwise
            msg = [...
                'Unrecognized color name: ' lower(name) ...
                '. Valid names are:' newline...
                '   y   |    m    |  c   |  r  |    g ,   b ,   w  ,   k' newline ...
                'yellow | magenta | cyan | red | green, blue, white, black'];
            error(msg); 
    end







