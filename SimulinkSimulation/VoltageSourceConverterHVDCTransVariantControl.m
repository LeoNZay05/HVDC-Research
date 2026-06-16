%% Model different levels of detail


%% Define simulation fidelity and corresponding parameters

fidelity = VoltageSourceConverterHVDCTransmissionEnum.Low;

switch fidelity
    case VoltageSourceConverterHVDCTransmissionEnum.Low % Low: Frequency-and-time simulation mode, Average-value VSC
        Ts = 1/60; % s, fundamental sample time
        Tsc = Ts; % s, control sample time
        set_param( [ bdroot '/Solver Configuration' ],'EquationFormulation','NE_FREQUENCY_TIME_EF');
        set_param( [ bdroot '/Solver Configuration' ],'MaxNonlinIter','3');
        set_param( [ bdroot '/Solver Configuration' ],'DoDC','on');
        set_param([ bdroot '/Control/Sending end and receiving end control' ],'modeling_fidelity','Low');
        set_param([ bdroot '/Control/Sending end and receiving end control' ],'InitUsingOP','off');
        set_param(bdroot,'SimscapeUseOperatingPoints','off');
        
    case VoltageSourceConverterHVDCTransmissionEnum.Medium % Medium: Time simulation mode, Average-value VSC
        Ts = 1/(fsw*10); % s, fundamental sample time
        Tsc = Ts; % s, control sample time
        set_param( [ bdroot '/Solver Configuration' ],'EquationFormulation','NE_TIME_EF');
        set_param( [ bdroot '/Solver Configuration' ],'MaxNonlinIter','3');
        set_param( [ bdroot '/Solver Configuration' ],'DoDC','on');
        set_param([ bdroot '/Control/Sending end and receiving end control' ],'modeling_fidelity','Medium');
        set_param([ bdroot '/Control/Sending end and receiving end control' ],'InitUsingOP','off');
        set_param(bdroot,'SimscapeUseOperatingPoints','off');

    otherwise % High: Time simulation mode, Switching VSC
        Ts = 1/(fsw*100); % s, fundamental sample time
        Tsc = 10*Ts; % s, control sample time
        set_param( [ bdroot '/Solver Configuration' ],'EquationFormulation','NE_TIME_EF');
        set_param( [ bdroot '/Solver Configuration' ],'MaxNonlinIter','4');
        set_param( [ bdroot '/Solver Configuration' ],'DoDC','off');
        set_param([ bdroot '/Control/Sending end and receiving end control' ],'modeling_fidelity','High');
        set_param([ bdroot '/Control/Sending end and receiving end control' ],'InitUsingOP','off');
        set_param(bdroot,'SimscapeUseOperatingPoints','off');
end