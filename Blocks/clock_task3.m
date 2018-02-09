function [Events Parameters Stimuli_sets Block_Export Trial_Export  Numtrials]=clock_task2(Parameters, Stimuli_sets, Trial, Blocknum, Modeflag, ...
    Events,Block_Export,Trial_Export,Demodata)
load('blockvars');addpath(genpath('util'));

%Paradigm coded by Michael R Hess, February '18

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Parameters%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Trial Parameters% (Not all. For the rest, scroll down to "The Experiment Display" section.)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%CHANGEHERE% %Total number of trials
Numtrials = 50 + 1; %Because of the way this block file runs, set Numtrials equal to the amount of trials you want and then add 1

test_mode=1; %test mode deactivates instructions atm
load_points_wheel = 1; %load the points wheel?
type = 3; %paradigm type: 1 = probabilities average(40-60%), 2 = uneven, 3 = gold mine(one:75%,rest:40%)

%Create segmented wheel
num_segments = 12; %number of segments
seg_colors{1} = [0 105 255]; %colors of segments
seg_colors{2} = seg_colors{1};
add_wheel_borders = 1;

%Selects a random color
shuffled_colors = randperm(360);
color_probe = shuffled_colors(1);

%Timing variables
%When the instructions will be displayed from the start of the experiment (Trial 1)
instruction_display_time = 0;

%CHANGEHERE% %When the color wheel and color question will appear on pre-surprise trials (after retention)
seg_wheel_time = instruction_display_time + 2;

%CHANGEHERE% %How long the total accuracy score will display on screen at the end of the trials
total_feedback_time = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set up Stimuli

[seg_values scorecolormatrix change_spot num_wheel_boxes] = segment_wheel(num_segments,seg_colors,add_wheel_borders);
% save('scorecolormatrix','scorecolormatrix');
csvwrite('scorecolormatrix.csv',scorecolormatrix);
save('seg_values','seg_values');
% save('segment_score','segment_score');
% segment_score_name = 'segment_score';
% save('segment_score_name','segment_score');

%Enables mouse
Parameters.mouse.enabled = 1;

%Color Wheel 1 (Outer)
colorWheelRadius1 = 260; %radius of color wheel
%Cartesian Conversion
colorWheelLocations1 = [cosd(1:num_wheel_boxes).*colorWheelRadius1 + Parameters.centerx; ...
    sind(1:num_wheel_boxes).*colorWheelRadius1 + Parameters.centery];

%Color Wheel 2 (Inner)
colorWheelRadius2 = 252; %radius of color wheel
%Cartesian Conversion
colorWheelLocations2 = [cosd(1:num_wheel_boxes).*colorWheelRadius2 + Parameters.centerx; ...
    sind(1:num_wheel_boxes).*colorWheelRadius2 + Parameters.centery];

%Points Wheel 1 (Inner)
pointsWheelRadius1 = colorWheelRadius1 + 40; %radius of color wheel
%Cartesian Conversion
pointsWheelLocations1 = [cosd(1:num_wheel_boxes).*pointsWheelRadius1 + Parameters.centerx; ...
    sind(1:num_wheel_boxes).*pointsWheelRadius1 + Parameters.centery];

pointswheel1_endnotch = [cosd(360).*pointsWheelRadius1 + Parameters.centerx; ...
    sind(360).*pointsWheelRadius1 + Parameters.centery];

%Points Wheel (Outer)
pointsWheelRadius2 = pointsWheelRadius1 + 8; %radius of color wheel
%Cartesian Conversion
pointsWheelLocations2 = [cosd(1:num_wheel_boxes).*pointsWheelRadius2 + Parameters.centerx; ...
    sind(1:num_wheel_boxes).*pointsWheelRadius2 + Parameters.centery];

pointswheel2_endnotch = [cosd(360).*pointsWheelRadius2 + Parameters.centerx; ...
    sind(360).*pointsWheelRadius2 + Parameters.centery];

%Location Wheel
locationWheelRadius = 258; %radius of color wheel
%Cartesian Conversion
locationWheelLocations = [cosd(1:num_wheel_boxes).*locationWheelRadius + Parameters.centerx; ...
    sind(1:num_wheel_boxes).*locationWheelRadius + Parameters.centery];

%Used for mouse clicks on color wheel
for i = 1:num_wheel_boxes
    buttonlocs{i} = [locationWheelLocations(1,i),locationWheelLocations(2,i),12];
end

%Set up the bot's segment choices
bot_choices = randperm(num_wheel_boxes);

save('colorWheelLocations1','colorWheelLocations1');
save('colorWheelLocations2','colorWheelLocations2');
save('pointsWheelLocations1','pointsWheelLocations1');
save('pointsWheelLocations2','pointsWheelLocations2');
save('pointswheel1_endnotch','pointswheel1_endnotch');
save('pointswheel2_endnotch','pointswheel2_endnotch');
% ,'seg_values','change_spot');

if strcmp(Modeflag,'InitializeBlock')
    clear Stimuli_sets
    
    locx = Parameters.centerx;
    locy = Parameters.centery;
    
    border_offset = 8;
    
    %Color Wheel 1 Border
    cwb1 = 800;
    stimstruct = CreateStimStruct('shape');
    stimstruct.stimuli = {'FrameOval'};
    stimstruct.xdim = colorWheelRadius1*2+border_offset;
    stimstruct.ydim = colorWheelRadius1*2+border_offset;
    stimstruct.color = [0 0 0];
    Stimuli_sets(cwb1) = Preparestimuli(Parameters,stimstruct);
    
    %Color Wheel 2 Border
    cwb2 = 801;
    stimstruct = CreateStimStruct('shape');
    stimstruct.stimuli = {'FrameOval'};
    stimstruct.xdim = colorWheelRadius2*2-border_offset;
    stimstruct.ydim = colorWheelRadius2*2-border_offset;
    stimstruct.color = [0 0 0];
    Stimuli_sets(cwb2) = Preparestimuli(Parameters,stimstruct);
    
    %Points Wheel 1 Border
    pwb1 = 802;
    stimstruct = CreateStimStruct('shape');
    stimstruct.stimuli = {'FrameOval'};
    stimstruct.xdim = pointsWheelRadius1*2-border_offset;
    stimstruct.ydim = pointsWheelRadius1*2-border_offset;
    stimstruct.color = [0 0 0];
    Stimuli_sets(pwb1) = Preparestimuli(Parameters,stimstruct);
    
    %Points Wheel 2 Border
    stimstruct = CreateStimStruct('shape');
    for i = 1:2
        pwb2 = 803;
        stimstruct.stimuli = {'FrameOval'};
        stimstruct.xdim = pointsWheelRadius2*2+border_offset;
        stimstruct.ydim = pointsWheelRadius2*2+border_offset;
        stimstruct.color = [0 0 0];
        stimstruct.stimsize = 1;
        if i==2;stimstruct.stimsize = 1.01;end
        Stimuli_sets(pwb2+i-1) = Preparestimuli(Parameters,stimstruct);
    end
    
    %Bot button
    bot_but = 1010;
    stimstruct = CreateStimStruct('shape');
    stimstruct.stimuli = {'FillRect'};
    button_x = 300;
    button_y = 200;
    stimstruct.xdim = button_x;
    stimstruct.ydim = button_y;
    button_color = 225;
    stimstruct.color = [button_color button_color button_color];
    Stimuli_sets(bot_but) = Preparestimuli(Parameters,stimstruct);
    
    %Bot button frame
    bot_but_frame = 1011;
    stimstruct = CreateStimStruct('shape');
    stimstruct.stimuli = {'FrameRect'};
    stimstruct.xdim = button_x;
    stimstruct.ydim = button_y;
    button_color = 0;
    stimstruct.color = [button_color button_color button_color];
    Stimuli_sets(bot_but_frame) = Preparestimuli(Parameters,stimstruct);
    
    %Bot button text
    bot_but_text = 1110; %click here
    stimstruct = CreateStimStruct('text');
    stimstruct.stimuli = {'Click here','to continue'};
    stimstruct.stimsize = 22;
    Stimuli_sets(bot_but_text) = Preparestimuli(Parameters,stimstruct);
    
    %Whose turn
    whose_turn = 1111; %turn
    stimstruct = CreateStimStruct('text');
    stimstruct.stimuli = {'Computer''s turn!','Your Turn!'};
    stimstruct.stimsize = 52;
    Stimuli_sets(whose_turn) = Preparestimuli(Parameters,stimstruct);
    
    %Load face pics
    face_stims = 1;
    face_dir = dir('Stimuli/faces');
    stimstruct = CreateStimStruct('image');
    for f = 3:length(face_dir)
        stimstruct.stimuli{f-2} = sprintf('faces/%s',face_dir(f).name);
    end
    Stimuli_sets(face_stims) = Preparestimuli(Parameters,stimstruct);
    
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
        stimstruct.linewidth = 10;
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
    stimstruct.stimuli = {'On each trial, you will see a "points wheel".','Your task is to click on different parts of this points wheel in','order to figure out which section is more likely to award you more points.','Press any button once you''re ready to begin.'};
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
    setupwheelblocks;
    
    rand_faces = randperm(length(face_dir)-2);
    
    if type == 1
        probs = [0.4 0.47 0.54 0.6]; %non-gold mine
    elseif type == 3 %gold mine
        probs = [0.4 0.4 0.4 0.75];
    end
    %     probs = [1 1 1 1]; %TESTING%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
    %% Set up other experiment parameters
    
    if Trial == 1
        seg_wheel_time = instruction_display_time + .01;
    end
    
    if Trial > 3
        string_trial = num2str(Trial-2);
    else
        string_trial = num2str(Trial);
    end
    
    if Trial > 10 && mod(string_trial(1),2)
        bot_mode = 0;
    else
        bot_mode = 1;
    end
    
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
    mouseresponse_seg = CreateResponseStruct;
    
    %Responsestruct
    responsestruct = CreateResponseStruct;
    responsestruct.x = locx;
    responsestruct.y = locy;
    
    %% Instruction Display (before practice trials) %%
    if Trial == 1
        
        if ~test_mode
            Events = newevent_mouse_cursor(Events,0,locx,locy,0);
            Events = newevent_show_stimulus(Events,31,1,locx,locy-100,instruction_display_time,'screenshot_no','clear_yes');
            Events = newevent_show_stimulus(Events,31,2,locx,locy,instruction_display_time,'screenshot_no','clear_no');
            Events = newevent_show_stimulus(Events,31,3,locx,locy+100,instruction_display_time,'screenshot_no','clear_no');
            responsestruct.allowedchars = 0;
            Events = newevent_keyboard(Events,instruction_display_time,responsestruct);
        end
        segment_score = zeros(num_segments,2);
        
    else
        %% Feedback %%
        
        if Trial > 2
            segment_score = csvread('segment_score')
        end
        
        y_offset = 100;
        rewardtext_locy = locy - 400;
        token_locy = locy - 100;
        
        %Find prob of click space
        selected_prob = wheel_probs(segment_response);
        
        %Find selected segment of the wheel
        show_selected_segment;
        
        win = 0;
        
        chance = rand(1);
        if chance <= selected_prob
            win = 1;
            
            %Wheel borders
            Events = newevent_show_stimulus(Events,cwb1,1,locx,locy,instruction_display_time,'screenshot_no','clear_yes');
            Events = newevent_show_stimulus(Events,cwb2,1,locx,locy,instruction_display_time,'screenshot_no','clear_no');
            Events = newevent_show_stimulus(Events,pwb1,1,locx,locy,instruction_display_time,'screenshot_no','clear_no');
            Events = newevent_show_stimulus(Events,pwb2,1,locx,locy,instruction_display_time,'screenshot_no','clear_no');
            Events = newevent_show_stimulus(Events,pwb2+1,1,locx,locy,instruction_display_time,'screenshot_no','clear_no');
            
            %Loads segmented wheel
            command =   'load(''selected_segment'');';
            Events = newevent_command(Events,instruction_display_time,command,'clear_no'); %selected segment
            command =   'load(''colorWheelLocations1'');';
            Events = newevent_command(Events,instruction_display_time,command,'clear_no');
            command =   'load(''colorWheelLocations2'');';
            Events = newevent_command(Events,instruction_display_time,command,'clear_no');
            command =   'Screen(''DrawDots'', Parameters.window, colorWheelLocations1, 10, selected_segment'', [], 1);';
            Events = newevent_command(Events,instruction_display_time,command,'clear_no');
            command =   'Screen(''DrawDots'', Parameters.window, colorWheelLocations2, 10, selected_segment'', [], 1);';
            Events = newevent_command(Events,instruction_display_time,command,'clear_no');
            
            %Loads points wheel
            if load_points_wheel
                points_time = instruction_display_time;
                loadpointswheel
            end
            
            %             load('segment_score');
            %                        before_add= segment_score(selected_row,2)
            %Add a point to the selected segment
            segment_score(selected_row,1) = segment_score(selected_row,1) + 1;
            %             segment_score(selected_row,2)
            segment_score(selected_row,2) = segment_score(selected_row,2) + 1;
            %                         save('segment_score','segment_score');
            %Add to the counter of how many times this segment was selected
            
            %             segment_score(selected_row,2) = segment_score(selected_row,2) + 1;
            %                        after_add= segment_score(selected_row,2)
            %             sca;keyboard
            score = score + 1;
            % score = segment_score(selected_row,2) + 1;
            % save('segment_score','segment_score');
            %             save('pointsWheelLocations','pointsWheelLocations1','pointsWheelLocations2','seg_values','change_spot','segment_response','win','selected_row','add','score');
            %             load('scorecolormatrix');
            scorecolormatrix=csvread('scorecolormatrix.csv');
            [add] = show_score(segment_score,add,scorecolormatrix,win,seg_values,segment_response,change_spot,Trial);
            
            for spin = 1:10
                spin_time = spin*2*.1;
                reward_time = instruction_display_time+spin_time;
                
                if Trial == 1
                    seg_wheel_time = reward_time + 3;
                elseif Trial == 2
                    seg_wheel_time = reward_time + 2;
                else
                    seg_wheel_time = reward_time + 1;
                end
                
                %Wheel borders
                Events = newevent_show_stimulus(Events,cwb1,1,locx,locy,reward_time,'screenshot_no','clear_yes');
                Events = newevent_show_stimulus(Events,cwb2,1,locx,locy,reward_time,'screenshot_no','clear_no');
                Events = newevent_show_stimulus(Events,pwb1,1,locx,locy,reward_time,'screenshot_no','clear_no');
                Events = newevent_show_stimulus(Events,pwb2,1,locx,locy,reward_time,'screenshot_no','clear_no');
                Events = newevent_show_stimulus(Events,pwb2+1,1,locx,locy,reward_time,'screenshot_no','clear_no');
                
                %Loads segmented wheel
                command =   'load(''selected_segment'');';
                Events = newevent_command(Events,reward_time,command,'clear_no'); %selected segment
                command =   'load(''colorWheelLocations1'');';
                Events = newevent_command(Events,reward_time,command,'clear_no');
                command =   'load(''colorWheelLocations2'');';
                Events = newevent_command(Events,reward_time,command,'clear_no');
                command =   'Screen(''DrawDots'', Parameters.window, colorWheelLocations1, 10, selected_segment'', [], 1);';
                Events = newevent_command(Events,reward_time,command,'clear_no');
                command =   'Screen(''DrawDots'', Parameters.window, colorWheelLocations2, 10, selected_segment'', [], 1);';
                Events = newevent_command(Events,reward_time,command,'clear_no');
                
                
                if score < 2
                    Events = newevent_show_stimulus(Events,reward,1,locx,rewardtext_locy+y_offset-100,reward_time,'screenshot_no','clear_no'); %"you won a token!'
                else
                    Events = newevent_show_stimulus(Events,reward,3,locx,rewardtext_locy+y_offset-100,reward_time,'screenshot_no','clear_no'); %"you won ANOTHER token!"
                end
                
                if load_points_wheel
                    points_time = reward_time;
                    loadpointswheel
                end
                
                %Spinning token
                if spin < 5
                    Events = newevent_show_stimulus(Events,token,spin,locx,token_locy+y_offset,reward_time,'screenshot_no','clear_no');
                elseif spin == 5 || spin == 10
                    Events = newevent_show_stimulus(Events,token,1,locx,token_locy+y_offset,reward_time,'screenshot_no','clear_no');
                else
                    Events = newevent_show_stimulus(Events,token,spin-5,locx,token_locy+y_offset,reward_time,'screenshot_no','clear_no');
                end
                
            end
            
            %Didn't win a token :'(
        else
            %Add to the counter of how many times this segment was selected
            %             load('segment_score');
            segment_score(selected_row,2) = segment_score(selected_row,2) + 1
            %                         save('segment_score','segment_score');
            %             save('pointsWheelLocations','pointsWheelLocations1','pointsWheelLocations2','seg_values','change_spot','segment_response','segment_score');
            %             load('scorecolormatrix');
            scorecolormatrix=csvread('scorecolormatrix.csv');
            [add] = show_score(segment_score,add,scorecolormatrix,win,seg_values,segment_response,change_spot,Trial);
            
            %Wheel borders
            Events = newevent_show_stimulus(Events,cwb1,1,locx,locy,instruction_display_time,'screenshot_no','clear_yes');
            Events = newevent_show_stimulus(Events,cwb2,1,locx,locy,instruction_display_time,'screenshot_no','clear_no');
            Events = newevent_show_stimulus(Events,pwb1,1,locx,locy,instruction_display_time,'screenshot_no','clear_no');
            Events = newevent_show_stimulus(Events,pwb2,1,locx,locy,instruction_display_time,'screenshot_no','clear_no');
            Events = newevent_show_stimulus(Events,pwb2+1,1,locx,locy,instruction_display_time,'screenshot_no','clear_no');
            
            %Loads segmented wheel
            command =   'load(''selected_segment'');';
            Events = newevent_command(Events,instruction_display_time,command,'clear_no'); %selected segment
            command =   'load(''colorWheelLocations1'');';
            Events = newevent_command(Events,instruction_display_time,command,'clear_no');
            command =   'load(''colorWheelLocations2'');';
            Events = newevent_command(Events,instruction_display_time,command,'clear_no');
            command =   'Screen(''DrawDots'', Parameters.window, colorWheelLocations1, 10, selected_segment'', [], 1);';
            Events = newevent_command(Events,instruction_display_time,command,'clear_no');
            command =   'Screen(''DrawDots'', Parameters.window, colorWheelLocations2, 10, selected_segment'', [], 1);';
            Events = newevent_command(Events,instruction_display_time,command,'clear_no');
            
            %Loads points wheel
            if load_points_wheel
                points_time = instruction_display_time;
                loadpointswheel
            end
            
            %"No reward" test
            Events = newevent_show_stimulus(Events,reward,2,locx,rewardtext_locy+y_offset-100,instruction_display_time,'screenshot_no','clear_no');
            
            %Display red X mark
            Events = newevent_show_stimulus(Events,left_x,1,locx,locy,instruction_display_time,'screenshot_no','clear_no');
            Events = newevent_show_stimulus(Events,right_x,1,locx,locy,instruction_display_time,'screenshot_no','clear_no');
            
        end
    end
    
    %% Pariticipant response display %%
    
    if Trial <= Numtrials
        
        if bot_mode
            %Show cursor
            Events = newevent_mouse_cursor(Events,seg_wheel_time,locx,locy,0);
            %Mouse Parameters
            bot_response = CreateResponseStruct;
            Events = newevent_show_stimulus(Events,bot_but,1,locx,locy,seg_wheel_time,'screenshot_no','clear_yes');
            Events = newevent_show_stimulus(Events,bot_but_frame,1,locx,locy,seg_wheel_time,'screenshot_no','clear_no');
            %text
            Events = newevent_show_stimulus(Events,whose_turn,1,locx,locy-400,seg_wheel_time,'screenshot_no','clear_no');
            Events = newevent_show_stimulus(Events,bot_but_text,1,locx,locy-25,seg_wheel_time,'screenshot_no','clear_no');
            Events = newevent_show_stimulus(Events,bot_but_text,2,locx,locy+25,seg_wheel_time,'screenshot_no','clear_no');
            %Mouse Click Windows
            bot_buttonlocs{1}=[locx,locy,300];
            bot_response.spatialwindows = bot_buttonlocs;
            %                                 Events = newevent_show_stimulus(Events,fill_wheel,1,locx,locy,seg_wheel_time,'screenshot_no','clear_no'); %selected segment
            [Events bot_button_click] = newevent_mouse(Events,seg_wheel_time,bot_response);
            clear_screen = 'clear_no';
        else
            clear_screen = 'clear_yes';
        end
        
        Trial_Export.color_probe = color_probe;
        
        %Mouse appears
        Events = newevent_mouse_cursor(Events,seg_wheel_time,locx,locy,Parameters.mouse.cursorsize);
        
        %Wheel borders
        Events = newevent_show_stimulus(Events,cwb1,1,locx,locy,seg_wheel_time,'screenshot_no',clear_screen);
        Events = newevent_show_stimulus(Events,cwb2,1,locx,locy,seg_wheel_time,'screenshot_no','clear_no');
        Events = newevent_show_stimulus(Events,pwb1,1,locx,locy,seg_wheel_time,'screenshot_no','clear_no');
        Events = newevent_show_stimulus(Events,pwb2,1,locx,locy,seg_wheel_time,'screenshot_no','clear_no');
        Events = newevent_show_stimulus(Events,pwb2+1,1,locx,locy,seg_wheel_time,'screenshot_no','clear_no');
        
        %Loads segmented wheel
        command =   'load(''colorWheelLocations1'');';
        Events = newevent_command(Events,seg_wheel_time,command,'clear_no');
        command =   'load(''colorWheelLocations2'');';
        Events = newevent_command(Events,seg_wheel_time,command,'clear_no');
        command =   'load(''wheel360'');';
        Events = newevent_command(Events,seg_wheel_time,command,'clear_no');
        command =   'Screen(''DrawDots'', Parameters.window, colorWheelLocations1, 10, fullcolormatrix'', [], 1);';
        Events = newevent_command(Events,seg_wheel_time,command,'clear_no');
        command =   'Screen(''DrawDots'', Parameters.window, colorWheelLocations2, 10, fullcolormatrix'', [], 1);';
        Events = newevent_command(Events,seg_wheel_time,command,'clear_no');
        
        if load_points_wheel
            points_time = seg_wheel_time;
            loadpointswheel
        end
        
        if ~bot_mode
            %Mouse Click Windows
            mouseresponse_seg.variableInputName='ReportedColor';
            mouseresponse_seg.variableInputMapping=[1:360;1:360]';
            mouseresponse_seg.spatialwindows = buttonlocs;
            %                                 Events = newevent_show_stimulus(Events,fill_wheel,1,locx,locy,seg_wheel_time,'screenshot_no','clear_no'); %selected segment
            [Events,segment_response] = newevent_mouse(Events,seg_wheel_time,mouseresponse_seg);
            Events = newevent_show_stimulus(Events,whose_turn,2,locx,locy-400,seg_wheel_time,'screenshot_no','clear_no'); %your turn!
        end
        trial_end_time = seg_wheel_time + .01; %when the trial ends
    else
        trial_end_time = total_feedback_time;
    end
    
    %% Ends trial
    Events = newevent_end_trial(Events,trial_end_time);
    
elseif strcmp(Modeflag,'EndTrial')
    %% Record output data in structure & save in .MAT file
    if Trial < Numtrials
        
        try
            Trial_Export.segment_response = Events.windowclicked{segment_response};
        catch
            Trial_Export.segment_response = 0;
        end
        
        if ~bot_mode
            segment_response = (Events.windowclicked{segment_response});
        else
            segment_response = bot_choices(Trial);
        end
        difference = segment_response - color_probe;
        
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
        Trial_Export.segment_response = 'feedback trial';
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
    
    %color_probe & segment_response:
    %These outputs are the color value of the square displayed on screen during the trial (color_probe)
    %and the color value of the color that the participant selected (segment_response).
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
    
elseif strcmp(Modeflag,'EndBlock')
else
    %Something went wrong in Runblock (You should never see this error)
    error('Invalid modeflag');
end
saveblockspace
end