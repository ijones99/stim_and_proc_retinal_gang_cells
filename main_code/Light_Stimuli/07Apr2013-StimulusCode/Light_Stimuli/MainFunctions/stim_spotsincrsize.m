function stim_spotsincrsize(window,Settings,StimMats)

n=1;
for iRepeats = 1%:Settings.DOT_STIM_REPEATS
    for iDotBrightness = Settings.DOT_BRIGHTNESS_VAL
        for i = 1:length(StimMats.PRESENTATION_ORDER)

            clear tempFrame
            tempFrame = logical(StimMats.varDotStimMtx(:,:,StimMats.PRESENTATION_ORDER(i)));
            tempFrame = (double(tempFrame)*double(Settings.MID_GRAY_DECI)*double(Settings.WHITE_VAL));
            tempFrame(1,1)
            middleInd = find(tempFrame==0);
            tempFrame(middleInd) = iDotBrightness;
            w = Screen(window, 'MakeTexture',  Settings.BLACK_VAL+tempFrame);
            Screen(window, 'DrawTexture', w    );
            paramex(6);
            Screen(window,'Flip');
            paramex(4);
            pause(Settings.DOT_DOT_SHOW_TIME)
            transScrMtx = ones(round(Settings.SURR_DIMS));%set # pixels along edge or...
            transitionScreen = Screen(window, ...
                'MakeTexture',  double(Settings.BLACK_VAL)+double(Settings.MID_GRAY_DECI)...
                *double(transScrMtx)*double(Settings.WHITE_VAL) );
            % blank screen in between dot presentations
            Screen(window, 'DrawTexture', transitionScreen    );
            paramex(6);
            Screen(window,'Flip');
            paramex(4);

            if(KbCheck)
                break;
            end;
            %pause for amount specified minus the intrinsic rate
            pause(Settings.DOT_INTER_SUB_SESSION_WAIT);
            Screen('Close',w);
            n = 1+n;
        end
    end
end

transitionScreen = Screen(window, ...
    'MakeTexture',  double(Settings.BLACK_VAL)+double(Settings.MID_GRAY_DECI)...
    *double(transScrMtx)*double(Settings.WHITE_VAL) );

Screen(window, 'DrawTexture', transitionScreen    );
Screen(window,'Flip');
pause(5)


end





