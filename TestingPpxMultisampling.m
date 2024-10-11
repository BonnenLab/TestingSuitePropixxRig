% function []=TestingTpx()
clear;
close all;
sca;

calibrationSuccess = 0;
screenNumber = 1;
bgcolor = .5;
Datapixx('Open');
Datapixx('RegWrRd');
Datapixx('SetTPxAwake');
Datapixx('RegWrRd');

multisample = 8; % zero for off, 1,2,4, or 8 otherwise

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

[windowPtr, windowRect]=PsychImaging('OpenWindow', screenNumber, 0,[],[],[],8,multisample);
cam_rect = [windowRect(3)/2-1280/2 0 windowRect(3)/2+1280/2 1024];

Screen('BlendFunction',windowPtr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
frameRate = 120; %Screen('NominalFrameRate',windowPtr);


KbName('UnifyKeyNames');

vbl = Screen('Flip',windowPtr);

for ii=1:1000
    % tic;
    [pressed dum keycode] = KbCheck;
    if pressed
        if keycode(KbName('escape'))
            break;
        end
    end

    Screen('SelectStereoDrawBuffer', windowPtr, 0);
    Screen('DrawDots', windowPtr, [500;500],30,255,[],2);


    Screen('SelectStereoDrawBuffer', windowPtr, 1);
    Screen('DrawDots', windowPtr, [500;500],30,255,[],2);

    Screen('Flip', windowPtr, vbl +.5*1/frameRate);

end

Screen('closeall')
Datapixx('SetPropixxDlpSequenceProgram', 0);
Datapixx('Close');










