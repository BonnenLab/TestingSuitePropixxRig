function []=TestingPpxMultisamplingPolygonTarget()
close all;
sca;

multisample = [0,2,4,8]; % zero for off, 1,2,4, or 8 otherwise
timing = {};
samples = 1000;

screenNumber = 1;
theScreen.dist = 1000;
theScreen.width = 1830;
theScreen.pixpermm = [1920/theScreen.width];
% eye geometry
theEye.ipd = 65;           % interpupillary distance (mm)
theEye.off = [0,0]; % offset between eyes and screen origin



% load polygons in
for mm=1:length(multisample)
    Datapixx('Open');
    Datapixx('RegWrRd');
    Datapixx('SetTPxAwake');
    Datapixx('RegWrRd');


    timing{mm} = nan(samples,1);
    filename = '/home/vpixx/Documents/experiment-repos/Bita-manual-3d-prediction/experiment-helper-code/CompositePolygonTargetsSaved/polygons01.mat';
    load(filename,'polygons');
    targetSize = 60;
    frameRate = 120; %Screen('NominalFrameRate',windowPtr);

    PsychImaging('PrepareConfiguration');

    % Tell PTB we want to display on a DataPixx device:
    PsychImaging('AddTask', 'General', 'UseDataPixx');

    % Enable PROPixx RB3D Sequencer
    Datapixx('SetPropixxDlpSequenceProgram', 1); % the 1 is for the RB3D mode
    Datapixx('RegWr'); % command to get the changes to be applied to the device


    % You can modify the per eye crosstalk here.
    Datapixx('SetPropixx3DCrosstalkLR', 0.05); % 0 is the default value of the crosstalk correction
    Datapixx('SetPropixx3DCrosstalkRL', 0.05);
    Datapixx('RegWrRd'); % command to read values from the device to get the most recent ones

    if multisample ==0
        [windowPtr, windowRect]=PsychImaging('OpenWindow', screenNumber, 0,[],[],[],8);
    else
        [windowPtr, windowRect]=PsychImaging('OpenWindow', screenNumber, 0,[],[],[],8,multisample(mm));
    end

    theScreen.center = windowRect(3:4)/2;
    Screen('BlendFunction',windowPtr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);


    KbName('UnifyKeyNames');
    vbl = Screen('Flip',windowPtr);

    for ii=1:1000
        drawPolygon(polygons,theScreen,theEye,windowPtr,300*[0,0,sin(ii/100)],targetSize)
        timing{mm}(ii) = Screen('Flip', windowPtr, vbl +.5*1/frameRate);
    end

    Screen('closeall')
    Datapixx('SetPropixxDlpSequenceProgram', 0);
    Datapixx('Close');
end

%%

figure;
for ii=1:4
    subplot(1,4,ii);
    histogram(diff(timing{ii}))
    axis square;
    drops(ii) = sum(diff(timing{ii})>.0085);
    title(sprintf('m=%i, drops=%i',multisample(ii),drops(ii)))
end
fprintf("frame drops (m=%i): %i\n",[multisample;drops])

end


function[]=drawPolygon(polygons,theScreen,theEye,windowPtr,xyz,targetSize)
[left,right] = to2dProjection(xyz(1),xyz(2),xyz(3),theScreen.dist,theEye.ipd,theEye.off);
left = theScreen.pixpermm*([1,-1].*left)+theScreen.center;
right = theScreen.pixpermm*([1,-1].*right)+theScreen.center;

z = xyz(3);
scale = theScreen.dist/(theScreen.dist-z);
tSize = scale*targetSize;

% Select left-eye image buffer for drawing:
Screen('SelectStereoDrawBuffer', windowPtr, 0);
for ii=1:3
    Screen('FillPoly', windowPtr,255*polygons.Colors(ii,:).^2,polygons.Vertices{ii}*tSize+left,1);
end
ii=4;
Screen('FillPoly', windowPtr,255*polygons.Colors(ii,:).^2,polygons.Vertices{ii}*tSize+left);
Screen('DrawDots',windowPtr,left',scale*3,[255,255,255],[],2);


% Select right-eye image buffer for drawing:
Screen('SelectStereoDrawBuffer', windowPtr, 1);
for ii=1:3
    Screen('FillPoly', windowPtr,255*polygons.Colors(ii,:).^2,polygons.Vertices{ii}*tSize+right,1);
end
ii=4;
Screen('FillPoly', windowPtr,255*polygons.Colors(ii,:).^2,polygons.Vertices{ii}*tSize+right);
Screen('DrawDots',windowPtr,right',scale*3,[255,255,255],[],2);

end


function [ left,right] = to2dProjection( x,y,z,screenDist,ipd,eye )
% to2dProjection takes a set of 3D coordinates and calculates the 2D
%   projections for the left and right eye given a certain viewing distance
%   (screenDist), inter-pupillary distance (ipd) and eye location (eye).


% Calculate x,y offsets for response projection
yoff = (y-eye(2)).*z./(screenDist-z);
xroff = (x-eye(1)-ipd/2).*z./(screenDist-z);
xloff = (x-eye(1)+ipd/2).*z./(screenDist-z);

left = [(x+xloff)',(y+yoff)'];
right = [(x+xroff)',(y+yoff)'];

end