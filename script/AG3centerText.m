
% Returns coordinates for displaying text in the center of the screen.
% JC 02/2006

function [hPos, vPos] = AG1centerText(window,screenNumber,message);

screenRect=Screen(screenNumber,'Rect');
[normBoundsRect, offsetBoundsRect]= Screen('TextBounds', window, message);
hPos = screenRect(3)/2 - normBoundsRect(3)/2;
vPos = screenRect(4)/2 - normBoundsRect(4)/2;