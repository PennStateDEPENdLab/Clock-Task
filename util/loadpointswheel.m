%Loads points wheel
command = 'scorecolormatrix=csvread(''scorecolormatrix.csv'');';
Events = newevent_command(Events,points_time,command,'clear_no');
command =   'load(''pointsWheelLocations'');';
Events = newevent_command(Events,points_time,command,'clear_no');
command =   'Screen(''DrawDots'', Parameters.window, pointsWheelLocations1, 10, scorecolormatrix'', [], 1);';
Events = newevent_command(Events,points_time,command,'clear_no');
command =   'Screen(''DrawDots'', Parameters.window, pointsWheelLocations2, 10, scorecolormatrix'', [], 1);';
Events = newevent_command(Events,points_time,command,'clear_no');

command = 'scorecolormatrix2=csvread(''scorecolormatrix2.csv'');';
Events = newevent_command(Events,points_time,command,'clear_no');
command =   'Screen(''DrawDots'', Parameters.window, pointsWheel2Locations1, 10, scorecolormatrix2'', [], 1);';
Events = newevent_command(Events,points_time,command,'clear_no');
command =   'Screen(''DrawDots'', Parameters.window, pointsWheel2Locations2, 10, scorecolormatrix2'', [], 1);';
Events = newevent_command(Events,points_time,command,'clear_no');

% command = 'eval(firstpoint1 = pointsWheelLocations1(:,1)';
% Events = newevent_command(Events,points_time,command,'clear_no');
% command = 'eval(firstpoint2 = pointsWheelLocations2(:,2)';
% Events = newevent_command(Events,points_time,command,'clear_no');
% command = 'eval(firstcolor = scorecolormatrix(360,:)';
% Events = newevent_command(Events,points_time,command,'clear_no');

command = 'try;firstslotcolor = csvread(''firstslotcolor.csv'');end';
Events = newevent_command(Events,points_time,command,'clear_no');
command = 'try;firstslotcolor2 = csvread(''firstslotcolor2.csv'');end';
Events = newevent_command(Events,points_time,command,'clear_no');
command =   'Screen(''DrawDots'', Parameters.window, firstpoint1, 6, firstslotcolor'', [], 1);';
Events = newevent_command(Events,points_time,command,'clear_no');
command =   'Screen(''DrawDots'', Parameters.window, firstpoint2, 6, firstslotcolor'', [], 1);';
Events = newevent_command(Events,points_time,command,'clear_no');
command =   'Screen(''DrawDots'', Parameters.window, firstpoint3, 6.5, firstslotcolor2'', [], 1);';
Events = newevent_command(Events,points_time,command,'clear_no');
command =   'Screen(''DrawDots'', Parameters.window, firstpoint4, 6.5, firstslotcolor2'', [], 1);';
Events = newevent_command(Events,points_time,command,'clear_no');

command = 'scorecolormatrix3 = scorecolormatrix;';
Events = newevent_command(Events,points_time,command,'clear_no');
command = 'csvwrite(''scorecolormatrix3.csv'',scorecolormatrix3);';
Events = newevent_command(Events,points_time,command,'clear_no');
command = 'scorecolormatrix4 = scorecolormatrix2;';
Events = newevent_command(Events,points_time,command,'clear_no');
command = 'csvwrite(''scorecolormatrix4.csv'',scorecolormatrix4);';
Events = newevent_command(Events,points_time,command,'clear_no');

command = 'firstslotcolor3 = firstslotcolor;';
Events = newevent_command(Events,points_time,command,'clear_no');
command = 'firstslotcolor4 = firstslotcolor2;';
Events = newevent_command(Events,points_time,command,'clear_no');
command = 'csvwrite(''firstslotcolor3.csv'',firstslotcolor3)';
Events = newevent_command(Events,points_time,command,'clear_no');
command = 'csvwrite(''firstslotcolor4.csv'',firstslotcolor4)';
Events = newevent_command(Events,points_time,command,'clear_no');

