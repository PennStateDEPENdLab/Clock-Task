function [Events Parameters Stimuli_sets Block_Export Trial_Export  Numtrials]=Demo(Parameters, Stimuli_sets, Trial, Blocknum, Modeflag, ...
    Events,Block_Export,Trial_Export,Demodata)
load('blockvars')
points_wheel = 1;
%Paradigm coded by Michael R Hess, August '15

%Experiment is adjusted for a screen resolution of 1024x768

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Parameters%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Trial Parameters% (Not all. For the rest, scroll down to "The Experiment Display" section.)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%CHANGEHERE% %Total number of trials
Numtrials = 50 + 1; %Because of the way this block file runs, set Numtrials equal to the amount of trials you want and then add 1

%When the instructions will be displayed from the start of the experiment (Trial 1)
instruction_display_time = 0;

%CHANGEHERE% %When the color wheel and color question will appear on pre-surprise trials (after retention)
if Trial == 1
    color_wheel_time = instruction_display_time + .01;
else
    color_wheel_time = instruction_display_time + 2;
end

%CHANGEHERE% %How long the total accuracy score will display on screen at the end of the trials
total_feedback_time = 5;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Create segmented wheel
num_segments = 12;
seg_colors{1} = [255 155 0];
seg_colors{2} = [0 0 255];
add_wheel_borders = 1;

[seg_values scorecolormatrix change_spot num_wheel_boxes] = segment_wheel(num_segments,seg_colors,add_wheel_borders);save('seg_values','seg_values');
segment_score = zeros(num_segments,2);
segment_score_name = 'segment_score';
save('segment_score_name','segment_score');

%Enables mouse
Parameters.mouse.enabled = 1;

%Color Wheel 1 (Outer)
colorWheelRadius1 = 260; %radius of color wheel
%Cartesian Conversion
colorWheelLocations1 = [cosd(1:360).*colorWheelRadius1 + Parameters.centerx; ...
    sind(1:360).*colorWheelRadius1 + Parameters.centery];

%Color Wheel 2 (Inner)
colorWheelRadius2 = 252; %radius of color wheel
%Cartesian Conversion
colorWheelLocations2 = [cosd(1:360).*colorWheelRadius2 + Parameters.centerx; ...
    sind(1:360).*colorWheelRadius2 + Parameters.centery];

%Points Wheel (Outer-most)
pointsWheelRadius = colorWheelRadius1 + 18; %radius of color wheel
%Cartesian Conversion
pointsWheelLocations = [cosd(1:360).*pointsWheelRadius + Parameters.centerx; ...
    sind(1:360).*pointsWheelRadius + Parameters.centery];

%Location Wheel
locationWheelRadius = 258; %radius of color wheel
%Cartesian Conversion
locationWheelLocations = [cosd(1:360).*locationWheelRadius + Parameters.centerx; ...
    sind(1:360).*locationWheelRadius + Parameters.centery];

%Used for mouse clicks on color wheel
for i = 1:360
    buttonlocs{i} = [locationWheelLocations(1,i),locationWheelLocations(2,i),12];
end

save('colorWheelLocations1','colorWheelLocations1');
save('colorWheelLocations2','colorWheelLocations2');
save('pointsWheelLocations','pointsWheelLocations','scorecolormatrix','seg_values','change_spot');

if strcmp(Modeflag,'InitializeBlock')
    clear Stimuli_sets
    
    locx = Parameters.centerx;
    locy = Parameters.centery;
    
    %Load face pics
    face_stims = 1;
    face_dir = dir('Stimuli/faces');
    stimstruct = CreateStimStruct('image');
    for f = 3:length(face_dir)
        stimstruct.stimuli{f-2} = sprintf('faces/%s',face_dir(f).name);
    end
    Stimuli_sets(face_stims) = Preparestimuli(Parameters,stimstruct);
    
    %Token
    %     token = 500;
    %     stimstruct = CreateStimStruct('image');
    %     stimstruct.stimuli{1} = 'token.png';
    %     Stimuli_sets(token) = Preparestimuli(Parameters,stimstruct);
    
    %Token
    token = 500;
    stimstruct = CreateStimStruct('image');
    stimstruct.stimuli = {'coinface.png','coin45.png','coinside.png','coin135.png'};
    stimstruct.stimsize = 0.25;
    Stimuli_sets(token) = Preparestimuli(Parameters,stimstruct);
    
    %No reward
    left_x = 501;
    right_x = 502;
    red_xs = [left_x right_x];
    for xs = 1:length(red_xs)
        stimstruct = CreateStimStruct('shape');
        stimstruct.stimuli = {'DrawLine'};
        stimstruct.linelength = 425;
        stimstruct.linewidth = 35;
        stimstruct.color = [255 0 0];
        if xs == 1
            stimstruct.lineangle = 45;
            red_x = left_x;
        else
            stimstruct.lineangle = 135;
            red_x = right_x;
        end
        Stimuli_sets(red_x) = Preparestimuli(Parameters,stimstruct);
    end
    
    %Shape Structs & Instructions
    
    %Fixation Cross & Questions
    stimstruct = CreateStimStruct('text');
    stimstruct.wrapat = 0;
    stimstruct.stimuli = {'+','Click anywhere on the points wheel to try to score a token.'};
    stimstruct.stimsize = 20;
    Stimuli_sets(30) = Preparestimuli(Parameters,stimstruct);
    
    %Instructions (before practice trials)
    stimstruct = CreateStimStruct('text');
    stimstruct.wrapat = 0;
    stimstruct.stimuli = {'On each trial, you will see a face surrounded by a "points wheel".','Your task is to click on different parts of this points wheel in','order to figure out which section is more likely to award you more points.','Press any button once you''re ready to begin.'};
    stimstruct.stimsize = 20;
    stimstruct.wrapat = 0;
    stimstruct.vSpacing = 5;
    Stimuli_sets(31) = Preparestimuli(Parameters,stimstruct);
    
    %Text Feedback
    stimstruct = CreateStimStruct('text');
    stimstruct.wrapat = 0;
    stimstruct.stimuli = {'No line was displayed.','Displayed Color','Color You Chose'};
    stimstruct.stimsize = 30;
    stimstruct.vSpacing = 5;
    Stimuli_sets(36) = Preparestimuli(Parameters,stimstruct);
    
    %Accuracy Feedback
    stimstruct = CreateStimStruct('text');
    stimstruct.wrapat = 0;
    stimstruct.stimuli = {'1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','17','18','19','20','21','22','23','24','25','26','27','28','29','30','31','32','33','34','35','36','37','38','39','40','41','42','43','44','45','46','47','48','49','50','51','52','53','54','55','56','57','58','59','60','61','62','63','64','65','66','67','68','69','70','71','72','73','74','75','76','77','78','79','80','81','82','83','84','85','86','87','88','89','90','91','92','93','94','95','96','97','98','99','100'};
    stimstruct.stimsize = 30;
    stimstruct.vSpacing = 5;
    Stimuli_sets(40) = Preparestimuli(Parameters,stimstruct);
    
    %Accuracy Feedback
    stimstruct = CreateStimStruct('text');
    stimstruct.wrapat = 0;
    stimstruct.stimuli = {'Your color selection was', '%', 'accurate.'};
    stimstruct.stimsize = 30;
    stimstruct.vSpacing = 5;
    Stimuli_sets(41) = Preparestimuli(Parameters,stimstruct);
    
    %Accuracy Feedback
    reward = 300;
    stimstruct = CreateStimStruct('text');
    stimstruct.wrapat = 0;
    stimstruct.stimuli = {'Congrats! You won a token!', 'Sorry, no points this time.','Congrats! You won another token!','Total: '};
    stimstruct.stimsize = 30;
    stimstruct.vSpacing = 5;
    Stimuli_sets(reward) = Preparestimuli(Parameters,stimstruct);
    
    %Base blocks of the wheel
    for  stimstruct = CreateStimStruct('shape');
        stimstruct.stimuli = {'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';
            'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';
            'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';
            'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';
            'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';
            'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';
            'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';
            'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';
            'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';
            'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';
            'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';
            'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';
            'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';
            'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';
            'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';
            'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';
            'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';
            'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FillRect';'FrameRect'};
        stimstruct.color = zeros(1,3,360) + 220;
        stimstruct.xdim = [100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100];
        stimstruct.ydim = [100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100];
        
        Stimuli_sets(50) = Preparestimuli(Parameters,stimstruct);
    end
    
    rand_faces = randperm(length(face_dir)-2);
    
    probs = [0.2 0.4 0.6 0.8];
    probs = [1 1 1 1]; %TESTING%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    probs = Shuffle(probs);
    prob_count = 1;
    for i = 1:360
        if ~mod(i,90) && i < 360
            prob_count = prob_count + 1;
        end
        wheel_probs(i) = probs(prob_count);
    end
    score = 0;
    
elseif strcmp(Modeflag,'InitializeTrial')
    add=0;
    Events.variableNames{1} = 'StimNum';
    Events.variableFunctions{1} = 'StimNum(Parameters)';
    
    Events.variableNames{3}  = 'ReportedColor';
    Events.variableFunctions{3} = '';
    
    %Center coordinates
    locx = Parameters.centerx;
    locy = Parameters.centery;
    
    %Mouse appears
    Events = newevent_mouse_cursor(Events,instruction_display_time,locx,locy,0);
    
    %Mouse Parameters
    mouseresponse_color = CreateResponseStruct;
    
    %Responsestruct
    responsestruct = CreateResponseStruct;
    responsestruct.x = locx;
    responsestruct.y = locy;
    
    %Instruction Display (before practice trials)
    if Trial == 1
        Events = newevent_mouse_cursor(Events,0,locx,locy,0);
        Events = newevent_show_stimulus(Events,31,1,locx,locy-100,instruction_display_time,'screenshot_no','clear_yes');
        
        Events = newevent_show_stimulus(Events,31,2,locx,locy,instruction_display_time,'screenshot_no','clear_no');
        Events = newevent_show_stimulus(Events,31,3,locx,locy+100,instruction_display_time,'screenshot_no','clear_no');
        responsestruct.allowedchars = 0;
        Events = newevent_keyboard(Events,instruction_display_time,responsestruct);
        
        %Selects a random color
        shuffled_colors = randperm(360);
        color_probe = shuffled_colors(1);
        
    else
        %%Feedback%%
        
        y_offset = 75;
        rewardtext_locy = locy - 400;
        token_locy = locy - 100;
        
        %Find prob of click space
        selected_prob = wheel_probs(color_response);
        
        %Find selected segment of the wheel
        show_selected_segment;
        
        win = 0;
        
        chance = rand(1);
        if chance <= selected_prob
            win = 1;
%             load('segment_score');
%                        before_add= segment_score(selected_row,2)
            %Add a point to the selected segment
%             segment_score(selected_row,1) = segment_score(selected_row,1) + 1;
            
            %Add to the counter of how many times this segment was selected
            
%             segment_score(selected_row,2) = segment_score(selected_row,2) + 1;
%                        after_add= segment_score(selected_row,2)
%             sca;keyboard
            score = score + 1;
% score = segment_score(selected_row,2) + 1;
% save('segment_score','segment_score');
            save('pointsWheelLocations','pointsWheelLocations','scorecolormatrix','seg_values','change_spot','color_response','win','selected_row','add','score');
            
%             show_score
            
            color_wheel_time = color_wheel_time + 1.5;
            for spin = 1:10
                spin_time = spin*2*.1;
                reward_time = instruction_display_time+spin_time;
                
                %Won a token!
                if score < 2
                    %Loads color Wheel
                    command =   'load(''selected_segment'');';
                    Events = newevent_command(Events,reward_time,command,'clear_no'); %selected segment
                    command =   'load(''colorWheelLocations1'');';
                    Events = newevent_command(Events,reward_time,command,'clear_no');
                    command =   'load(''colorWheelLocations2'');';
                    Events = newevent_command(Events,reward_time,command,'clear_no');
                    command =   'Screen(''DrawDots'', Parameters.window, colorWheelLocations1, 10, selected_segment'', [], 1);';
                    Events = newevent_command(Events,reward_time,command,'clear_yes');
                    command =   'Screen(''DrawDots'', Parameters.window, colorWheelLocations2, 10, selected_segment'', [], 1);';
                    Events = newevent_command(Events,reward_time,command,'clear_no');
                    
                    if points_wheel
%                                                 command =   'show_score';
%                                                 Events = newevent_command(Events,reward_time,command,'clear_no');
                                                command =   'load(''pointsWheelLocations'');';
                                                Events = newevent_command(Events,reward_time,command,'clear_no');
%                         %                         sca;keyboard
%                         %                         show_score
%                         segment_score_name = sprintf('segment_score%d',Trial);
%                         save(segment_score_name,'segment_score');
%                         save('seg_filename','segment_score_name');
%                         %                                                                         command =   'load(''segment_score'');load(''pointsWheelLocations'');load(''seg_values'');[selected_row,w,x]=find(seg_values==color_response);if add==0;segment_score(selected_row,2) = segment_score(selected_row,2) + 1;add=1;end;show_score;';
%                                                                                                 showscorecommand =   'load(segment_score_name);load(''pointsWheelLocations'');load(''seg_values'');[selected_row,w,x]=find(seg_values==color_response);if add==0;segment_score(selected_row,2) = segment_score(selected_row,2) + 1;save(segment_score_name,''segment_score'');[add]=show_score(segment_score,add);end';
%                         %                         showscorecommand = ('
%                         Events = newevent_command(Events,reward_time,showscorecommand,'clear_no');
                        showdotscommand =   'Screen(''DrawDots'', Parameters.window, pointsWheelLocations, 10, scorecolormatrix'', [], 1);';
                        Events = newevent_command(Events,reward_time,showdotscommand,'clear_no');
                    end
                    
                    Events = newevent_show_stimulus(Events,reward,1,locx,rewardtext_locy+y_offset,reward_time,'screenshot_no','clear_no'); %reward coin
                else
                    %Loads color Wheel
                    command =   'load(''selected_segment'');';
                    Events = newevent_command(Events,reward_time,command,'clear_no'); %selected segment
                    command =   'load(''colorWheelLocations1'');';
                    Events = newevent_command(Events,reward_time,command,'clear_no');
                    command =   'load(''colorWheelLocations2'');';
                    Events = newevent_command(Events,reward_time,command,'clear_no');
                    command =   'Screen(''DrawDots'', Parameters.window, colorWheelLocations1, 10, selected_segment'', [], 1);';
                    Events = newevent_command(Events,reward_time,command,'clear_yes');
                    command =   'Screen(''DrawDots'', Parameters.window, colorWheelLocations2, 10, selected_segment'', [], 1);';
                    Events = newevent_command(Events,reward_time,command,'clear_no');
                    
                    if points_wheel
                        command =   'load(''pointsWheelLocations'');';
                        Events = newevent_command(Events,reward_time,command,'clear_no');
%                         command =   'Screen(''DrawDots'', Parameters.window, pointsWheelLocations, 10, scorecolormatrix'', [], 1);';
%                         Events = newevent_command(Events,reward_time,command,'clear_no');
%                                                                         showscorecommand =   'load(''segment_score'');load(''pointsWheelLocations'');load(''seg_values'');[selected_row,w,x]=find(seg_values==color_response);if add==0;segment_score(selected_row,2) = segment_score(selected_row,2) + 1;add=1;end;show_score;';
%                                                 Events = newevent_command(Events,reward_time,showscorecommand,'clear_no');
%                         showdotscommand =   'Screen(''DrawDots'', Parameters.window, pointsWheelLocations, 10, scorecolormatrix'', [], 1);';
                        Events = newevent_command(Events,reward_time,showdotscommand,'clear_no');
                    end
                    
                    Events = newevent_show_stimulus(Events,reward,3,locx,rewardtext_locy+y_offset,reward_time,'screenshot_no','clear_no'); %reward coin
                end
                
                if points_wheel
                    command =   'load(''pointsWheelLocations'');';
                    Events = newevent_command(Events,reward_time,command,'clear_no');
                    command =   'Screen(''DrawDots'', Parameters.window, pointsWheelLocations, 10, scorecolormatrix'', [], 1);';
                    Events = newevent_command(Events,reward_time,command,'clear_no');
                end
                
                Events = newevent_show_stimulus(Events,reward,4,locx,locy+75+y_offset,reward_time,'screenshot_no','clear_no');
                Events = newevent_show_stimulus(Events,40,score,locx,locy+125+y_offset,reward_time,'screenshot_no','clear_no');
                if spin < 5
                    Events = newevent_show_stimulus(Events,token,spin,locx,token_locy+y_offset,reward_time,'screenshot_no','clear_no'); %token
                elseif spin == 5 || spin == 10
                    Events = newevent_show_stimulus(Events,token,1,locx,token_locy+y_offset,reward_time,'screenshot_no','clear_no'); %token
                else
                    Events = newevent_show_stimulus(Events,token,spin-5,locx,token_locy+y_offset,reward_time,'screenshot_no','clear_no'); %token
                end
            end
            
            %Didn't win a token :'(
        else
            %Add to the counter of how many times this segment was selected
            segment_score(selected_row,2) = segment_score(selected_row,2) + 1;
            save('pointsWheelLocations','pointsWheelLocations','scorecolormatrix','seg_values','change_spot','color_response','segment_score');
                        show_score
            
            %Loads color Wheel
            command =   'load(''selected_segment'');';
            Events = newevent_command(Events,instruction_display_time,command,'clear_no'); %selected segment
            command =   'load(''colorWheelLocations1'');';
            Events = newevent_command(Events,instruction_display_time,command,'clear_no');
            command =   'load(''colorWheelLocations2'');';
            Events = newevent_command(Events,instruction_display_time,command,'clear_no');
            command =   'Screen(''DrawDots'', Parameters.window, colorWheelLocations1, 10, selected_segment'', [], 1);';
            Events = newevent_command(Events,instruction_display_time,command,'clear_yes');
            command =   'Screen(''DrawDots'', Parameters.window, colorWheelLocations2, 10, selected_segment'', [], 1);';
            Events = newevent_command(Events,instruction_display_time,command,'clear_no');
            Events = newevent_show_stimulus(Events,reward,2,locx,rewardtext_locy+y_offset,instruction_display_time,'screenshot_no','clear_no'); %no reward
            %Display red X mark
            Events = newevent_show_stimulus(Events,left_x,1,locx,locy,instruction_display_time,'screenshot_no','clear_no');
            Events = newevent_show_stimulus(Events,right_x,1,locx,locy,instruction_display_time,'screenshot_no','clear_no');
            
            if points_wheel
                command =   'load(''pointsWheelLocations'');';
                Events = newevent_command(Events,instruction_display_time,command,'clear_no');
                command =   'Screen(''DrawDots'', Parameters.window, pointsWheelLocations, 10, scorecolormatrix'', [], 1);';
                Events = newevent_command(Events,instruction_display_time,command,'clear_no');
            end
        end
    end
    
    if Trial <= Numtrials
        
        %Color Question
        for color_question = 1
            
            Trial_Export.color_probe = color_probe;
            
            %Mouse appears
            Events = newevent_mouse_cursor(Events,color_wheel_time,locx,locy,Parameters.mouse.cursorsize);
            
            %Loads color Wheel
            command =   'load(''colorWheelLocations1'');';
            Events = newevent_command(Events,color_wheel_time,command,'clear_yes');
            command =   'load(''colorWheelLocations2'');';
            Events = newevent_command(Events,color_wheel_time,command,'clear_no');
            command =   'load(''wheel360'');';
            Events = newevent_command(Events,color_wheel_time,command,'clear_no');
            command =   'Screen(''DrawDots'', Parameters.window, colorWheelLocations1, 10, fullcolormatrix'', [], 1);';
            Events = newevent_command(Events,color_wheel_time,command,'clear_yes');
            command =   'Screen(''DrawDots'', Parameters.window, colorWheelLocations2, 10, fullcolormatrix'', [], 1);';
            Events = newevent_command(Events,color_wheel_time,command,'clear_no');
            
            if points_wheel
                command =   'load(''pointsWheelLocations'');';
                Events = newevent_command(Events,color_wheel_time,command,'clear_no');
                command =   'Screen(''DrawDots'', Parameters.window, pointsWheelLocations, 10, scorecolormatrix'', [], 1);';
                Events = newevent_command(Events,color_wheel_time,command,'clear_no');
            end
            
            Events = newevent_show_stimulus(Events,30,2,locx,locy-300,color_wheel_time,'screenshot_no','clear_no');
            
            mouseresponse_color.variableInputName='ReportedColor';
            mouseresponse_color.variableInputMapping=[1:360;1:360]';
            
            %Mouse Click Windows
            mouseresponse_color.spatialwindows = buttonlocs;
            [Events,color_response] = newevent_mouse(Events,color_wheel_time,mouseresponse_color);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            color_feedback_time = color_wheel_time + .01; %CHANGEHERE% When color feedback is given
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            Events = newevent_blank(Events,color_feedback_time);
            
            %Mouse disappears after response
            Events = newevent_mouse_cursor(Events,color_feedback_time,locx,locy,0);
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        trial_end_time = color_feedback_time + .2; %CHANGEHERE% When the trial ends
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    else
        trial_end_time = total_feedback_time;
    end
    
    %Ends trial
    Events = newevent_end_trial(Events,trial_end_time);
    
elseif strcmp(Modeflag,'EndTrial');
    
    if Trial < Numtrials
        
        try
            Trial_Export.color_response = Events.windowclicked{color_response};
        catch
            Trial_Export.color_response = 0;
        end
        
        color_response = (Events.windowclicked{color_response});
        difference = color_response - color_probe;
        
        if(difference > 180)
            difference = difference - 360;
        end
        
        if(difference < -180)
            difference = difference + 360;
        end
        
        if Trial > 1
            if Trial == 2
                total_accuracy = (accuracy_percentage + round(100 - ((sqrt(difference^2))/180)*100))/2;
            elseif Trial > 2
                total_accuracy = (total_accuracy + round(100 - ((sqrt(difference^2))/180)*100))/2;
            end
            
            Trial_Export.total_accuracy = total_accuracy;
        else
            Trial_Export.total_accuracy = round(100 - ((sqrt(difference^2))/180)*100);
        end
        
        Trial_Export.color_accuracy = difference;
        
        accuracy_percentage = round(100 - ((sqrt(difference^2))/180)*100);
        
        Trial_Export.accuracy_percentage = accuracy_percentage;
    else
        Trial_Export.accuracy_percentage = 'feedback trial';
        Trial_Export.color_accuracy = 'feedback trial';
        Trial_Export.color_probe = 'feedback trial';
        Trial_Export.color_response = 'feedback trial';
        Trial_Export.total_accuracy = 'feedback trial';
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Output Descriptions%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %accuracy_percentage:
    %This is a calculation that determines how close the participant's
    %reported color is to the displayed color.
    
    %color_accuracy:
    %This outputs the distance in color space between the actual color
    %and the reported color.
    
    %color_probe & color_response:
    %These outputs are the color value of the square displayed on screen during the trial (color_probe)
    %and the color value of the color that the participant selected (color_response).
    %Colored squares line the circumference, numbered 1-360, with 1 at the rightmost edge.
    %Values of the squares increase by 1 clockwise around the circle.
    
    %total_accuracy:
    %This is the average of the total of the accuracy percentages across all trials.
    
    
    %%%NOTE%%% Because of how this blockfile runs, feedback is technically given at
    %%%%%%%%%% the start of the next trial. Therefore, a blank feedback trial is
    %%%%%%%%%% needed at the end of the last trial in order to give feedback for
    %%%%%%%%%% that trial. The output for that trial will have all output
    %%%%%%%%%% variables set to 'feedback trial.'
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
elseif strcmp(Modeflag,'EndBlock');
else
    %Something went wrong in Runblock (You should never see this error)
    error('Invalid modeflag');
end
saveblockspace
end