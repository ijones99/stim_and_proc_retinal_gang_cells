function marching_bar_new_test
% show_gray([0...1]) full screen on or off

%%         
         
waitTimeBetweenPresentations = 1;
              
% !!!! Must center on one of the 9 blocks!!!
% Run time = .5 flash interval x 5 repeats x 10 flashes x 10 positions= 
umToPixConv = 1.79;
% -------------------- Stimulus Variables ------------------
horizontalPosition = 0; % block contains 3 squares [-1, 0 ,1] = [left, middle, right]
distBtwnBlockCenters = 6*16/1.75; % ctr-to-ctr distance between elec configs (horizontal), converted to pixels
    horizontalPosition = [horizontalPosition*distBtwnBlockCenters 0 ]
flashInterval = .5; % seconds
numberRepeats = 1 ;  
save_recording = 1;
numFlashes = 1;       
interRepeatInterval = 1;
       
stimuliSet = 1; % pick for switch
  
switch stimuliSet
    case 1
        stepSize = [0 round(200/(1.75*2))]; % movement steps in pixels
        numStepsVertical = ceil(350/100+1);
        startingPositionDiff = [0, -(17*18.5/2)/1.75];
        edgeLength = round(200/1.75); % in pixels

    case 2
        stepSize = [0 100/(2*1.75)]; % movement steps in pixels
        numStepsVertical = ceil(350/50+1);
        startingPositionDiff = [0, -(17*18.5/2)/1.75];
        edgeLength = 200/1.75; % in pixels

    case 3
        stepSize = [0 50/(2*1.75)]; % movement steps in pixels
        numStepsVertical = ceil(350/25+1);
        startingPositionDiff = [0, -(17*18.5/2)/1.75];
        edgeLength = 100/1.75; % in pixels
end

parapin(0)

% Make sure this is running on OpenGL Psychtoolbox:
AssertOpenGL;

% KbName('KeyNamesLinux') %run this command to get the
% names of the keys
RestrictKeysForKbCheck(66) % Restrict response to the space bar

HideCursor

%Brightness Values
blackVal = 0;
whiteVal = 255; 
darkGrayVal = 115;
grayVal = 163;
lightGrayVal = 205;
 
% get screen id and open a gray window
screenid = max(Screen ('Screens'));
window = Screen('OpenWindow', screenid, [0 grayVal grayVal  0]);


beep
pause(.3)
beep
pause(.3)
HideCursor
KbWait;


% make gray full screen       
screenSize = get(0,'ScreenSize');
fullScreenImage = ones(screenSize(3),screenSize(4),3)*255 ;
fullScreenImage(:,:,1) = 0;
w(1) = Screen(window, 'MakeTexture',  fullScreenImage*(grayVal/whiteVal)   );
  
flipIm = 1; % this is to take into account the transformations of the image from projector to MEA

imageVector = ones(edgeLength,edgeLength,3 ) ;
imageVector(:,:,1) = 0;
w(1) = Screen(window, 'MakeTexture',  imageVector*whiteVal   );
w(2) = Screen(window, 'MakeTexture',  imageVector*blackVal   );
 w(3) = Screen(window, 'MakeTexture',  imageVector*grayVal   ); 
% Screen dimensions
maxX = screenSize(3); maxY =screenSize(4) ; 
% maxX = 1200; maxY = maxX;
   
imWidth = size(imageVector,2);
imHeight = size(imageVector,1);

centerCoordsXY = [maxX/2 maxY/2 ]; 

%Create coordinates:
correctionForRectWindow = (maxX - maxY)/2;
centerPositionAdjustment = [-imWidth/2  -imHeight/2 ]

for i=1:numStepsVertical
    imageCoords{i} = centerCoordsXY + startingPositionDiff + stepSize*(i-1) + horizontalPosition;
    if flipIm
        %         imageCoords{i} = [ (maxX - imageCoords{i}(2) - imWidth/2 - correctionForRectWindow), (maxY - imageCoords{i}(1)-imHeight/2 + correctionForRectWindow  )   ];% however, must rotate and flip coords
        imageCoords{i} = [ (imageCoords{i}(2)+correctionForRectWindow ), ( imageCoords{i}(1)-correctionForRectWindow  )   ];% however, must rotate and flip coords
  
   
    end
     imageCoords{i} = imageCoords{i} + centerPositionAdjustment;
     sourceRect{i} = [imageCoords{i}(1),imageCoords{i}(2), imageCoords{i}(1)+size(imageVector,2),imageCoords{i}(2 )+size(imageVector,1)];
end

% sourceRect = [centerCoordsXY(1),centerCoordsXY(2), centerCoordsXY(1)+size(imageVector,2),centerCoordsXY(2 )+size(imageVector,1)]
if save_recording
    hidens_startSaving(0,'bs-hpws03')
    pause(.5)
end

for k = 1:numberRepeats
    for i=1:numStepsVertical
        for j=1:numFlashes
            parapin(6)
            Screen('DrawTexture', window, w(1), [], sourceRect{i}, [], [], [], [], [], [], []);
            Screen(window,'Flip');
            pause(flashInterval)
            parapin(4)
            Screen('DrawTexture', window, w(2), [], sourceRect{i}, [], [], [], [], [], [], []);
            Screen(window,'Flip');
            pause(flashInterval)
            if KbCheck
                break;
            end
        end
        if KbCheck
            break;
        end
    end
    if KbCheck
        break;
    end
    
        parapin(0)
    Screen('DrawTexture', window, w(3), [], sourceRect{i}, [], [], [], [], [], [], []);
    Screen(window,'Flip');


    pause(interRepeatInterval)
end


if save_recording
    pause(waitTimeBetweenPresentations)
    hidens_stopSaving(0,'bs-hpws03')
end


Screen('DrawTexture', window, w(3), [], sourceRect{i}, [], [], [], [], [], [], []);
Screen(window,'Flip');

umToPixConv
pause(.3)
HideCursor
KbWait;
  

Screen('CloseAll');

end