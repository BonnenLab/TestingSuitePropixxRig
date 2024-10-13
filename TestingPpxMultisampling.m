clear;
close all;
sca;

multisample = [0,2,4,8]; % zero for off, 1,2,4, or 8 otherwise
nframes = 1000;
timing = {};

for mm=1:length(multisample)
    timing{mm} = nan(nframes,1);
    calibrationSuccess = 0;
    screenNumber = 1;
    bgcolor = .5;
    Datapixx('Open');
    Datapixx('RegWrRd');
    Datapixx('SetTPxAwake');
    Datapixx('RegWrRd');

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

    [windowPtr, windowRect]=PsychImaging('OpenWindow', screenNumber, 0,[],[],[],8,multisample(mm));
    cam_rect = [windowRect(3)/2-1280/2 0 windowRect(3)/2+1280/2 1024];

    Screen('BlendFunction',windowPtr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    frameRate = 120; %Screen('NominalFrameRate',windowPtr);


    KbName('UnifyKeyNames');

    vbl = Screen('Flip',windowPtr);

    for ii=1:1000

        Screen('SelectStereoDrawBuffer', windowPtr, 0);
        Screen('DrawDots', windowPtr, [500;500],30,255,[],2);


        Screen('SelectStereoDrawBuffer', windowPtr, 1);
        Screen('DrawDots', windowPtr, [500;500],30,255,[],2);

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

