%% Initialize model using Simscape operating point

%% Configure the solver and control settings again based on the fidelity level

switch fidelity
    case VoltageSourceConverterHVDCTransEnum.Low
        Ts = 1/60; % s, fundamental sample time
        Tsc = Ts; % s, control sample time
        set_param( [ bdroot '/Solver Configuration' ],'EquationFormulation','NE_FREQUENCY_TIME_EF');
        set_param( [ bdroot '/Solver Configuration' ],'MaxNonlinIter','3');
        set_param( [ bdroot '/Solver Configuration' ],'DoDC','on');
        set_param(bdroot,'SimscapeUseOperatingPoints','off');
        set_param([ bdroot '/Control/Sending end and receiving end control' ],'modeling_fidelity','Low');
        set_param([ bdroot '/Control/Sending end and receiving end control' ],'InitUsingOP','off');
        fidelitySet = VoltageSourceConverterHVDCTransEnum.Low;

    case VoltageSourceConverterHVDCTransEnum.Medium
        Ts = 1/(fsw*10); % s, fundamental sample time
        Tsc = Ts; % s, control sample time
        set_param( [ bdroot '/Solver Configuration' ],'EquationFormulation','NE_TIME_EF');
        set_param( [ bdroot '/Solver Configuration' ],'MaxNonlinIter','3');
        set_param( [ bdroot '/Solver Configuration' ],'DoDC','on');
        set_param(bdroot,'SimscapeUseOperatingPoints','off');
        set_param([ bdroot '/Control/Sending end and receiving end control' ],'modeling_fidelity','Medium');
        set_param([ bdroot '/Control/Sending end and receiving end control' ],'InitUsingOP','off');
        fidelitySet = VoltageSourceConverterHVDCTransEnum.Medium;

    otherwise % VoltageSourceConverterHVDCTransEnum.High
        fidelity = VoltageSourceConverterHVDCTransEnum.Medium;
        Ts = 1/(fsw*10); % s, fundamental sample time
        Tsc = Ts; % s, control sample time
        set_param( [ bdroot '/Solver Configuration' ],'EquationFormulation','NE_TIME_EF');
        set_param( [ bdroot '/Solver Configuration' ],'MaxNonlinIter','3');
        set_param( [ bdroot '/Solver Configuration' ],'DoDC','on');
        set_param(bdroot,'SimscapeUseOperatingPoints','off');
        set_param([ bdroot '/Control/Sending end and receiving end control' ],'modeling_fidelity','Medium');
        set_param([ bdroot '/Control/Sending end and receiving end control' ],'InitUsingOP','off');
        fidelitySet = VoltageSourceConverterHVDCTransEnum.High;
end

%% Simulate the model and create an operating point from logged simulation data at 1 second

stopTime = 1;
sim(bdroot,[0 stopTime]);
op = simscape.op.create(simlog_VoltageSourceConverterHVDCTrans, stopTime);

%% Calculate the initial conditions used in the Control subsystem from the operating point

% DC side
sendingEndVdcpMeasRelPath = 'Sending end DC filter/Vdcp/Voltage Sensor';
opSendingEndVdcp = get(op, sendingEndVdcpMeasRelPath);
Vdcs0 = 2*opSendingEndVdcp.get("V").Value.value;
DCCurrentMeasRelPath = 'Sending end DC filter/Sensing current1/Current Sensor';
opIdc = get(op, DCCurrentMeasRelPath);
IL0 = opIdc.get("I").Value.value;
receivingEndVdcpMeasRelPath = 'Receiving end DC filter/Vdcp/Voltage Sensor';
opReceivingEndVdcp = get(op, receivingEndVdcpMeasRelPath);
Vdcr0 = 2*opReceivingEndVdcp.get("V").Value.value;

% Sending end
sendingEndVIMeas1RelPath = 'Sending end vi1/Current and Voltage Sensor (Three-Phase)';
opSendingEndGridVI = get(op, sendingEndVIMeas1RelPath);
Vabcgs0 = opSendingEndGridVI.get("V_output").Value.value; % pu, initial three-phase AC grid voltage
Vmags0 = sqrt(sum(Vabcgs0.^2)*2/3); % pu, initial three-phase AC voltage magnitude
Vphases0 = asin(Vabcgs0(1)/Vmags0); % rad, initial phase angle of Phase-A voltage
Vdgs0 = Vmags0; % pu, d-axis grid voltage
Vqgs0 = 0; % pu, q-axis grid voltage
Iabcgs0 = opSendingEndGridVI.get("I_output").Value.value; % pu, initial three-phase AC grid current
abc2dgs0 = (2/3)*[sin(Vphases0) sin(Vphases0-2*pi/3) sin(Vphases0+2*pi/3)];
abc2qgs0 = (2/3)*[cos(Vphases0) cos(Vphases0-2*pi/3) cos(Vphases0+2*pi/3)];
Idgs0 = abc2dgs0*Iabcgs0'; % pu, d-axis grid current
Iqgs0 = abc2qgs0*Iabcgs0'; % pu, q-axis grid current
sendingEndVIMeas2RelPath = 'Sending end vi2/Current and Voltage Sensor (Three-Phase)';
opSendingEndReactorVI = get(op, sendingEndVIMeas2RelPath);
Iabcrs0 = opSendingEndReactorVI.get("I_output").Value.value; % pu, initial three-phase reactor current
abc2drs0 = (2/3)*[sin(-pi/6+Vphases0) sin(-pi/6+Vphases0-2*pi/3) sin(-pi/6+Vphases0+2*pi/3)];
abc2qrs0 = (2/3)*[cos(-pi/6+Vphases0) cos(-pi/6+Vphases0-2*pi/3) cos(-pi/6+Vphases0+2*pi/3)];
Ids0 = abc2drs0*Iabcrs0'; % pu, d-axis grid reactor current
Iqs0 = abc2qrs0*Iabcrs0'; % pu, q-axis grid reactor current
sendingEndVSCRelPath = 'Sending end Converter/Average-value VSC/Average-value VSC';
opSendingEndVSC = get(op, sendingEndVSCRelPath);
ModWaves0 = opSendingEndVSC.get("ModWave").Value.value;
Vabcs0 = ModWaves0*(Vdcs0/Vbase)/2; % pu, three-phase converter voltage
Vds0 = abc2drs0*Vabcs0'; % pu, d-axis converter voltage
Vqs0 = abc2qrs0*Vabcs0'; % pu, q-axis converter voltage
Id_PIs0 = (Vdgs0+Iqgs0*Lt+Iqs0*Lr) - Vds0; % pu, d-axis current PI initial state
Iq_PIs0 = -(Idgs0*Lt+Ids0*Lr) - Vqs0; % pu, q-axis current PI initial state
if strcmp(fidelity, 'Medium')
    P_PIs0 = Idgs0; % pu, active power PI initial state
    Q_PIs0 = Iqgs0; % pu, reactive power PI initial state
else
    A = Vds0+Ids0*Rr-Vdgs0-Iqs0*Lr;
    B = Vqs0+Iqs0*Rr+Ids0*Lr;
    P_PIs0 = -(A*Rt+B*Lt)/(Rt^2+Lt^2); % pu, active power PI initial state
    Q_PIs0 = (A*Lt-B*Rt)/(Rt^2+Lt^2); % pu, reactive power PI initial state
end

% receiving end
receivingEndVIMeas1RelPath = 'Receiving end vi1/Current and Voltage Sensor (Three-Phase)';
opReceivingEndGridVI = get(op, receivingEndVIMeas1RelPath);
Vabcgr0 = opReceivingEndGridVI.get("V_output").Value.value; % pu, initial three-phase AC grid voltage
Vmagr0 = sqrt(sum(Vabcgr0.^2)*2/3); % pu, initial three-phase AC voltage magnitude
Vphaser0 = asin(Vabcgr0(1)/Vmagr0); % rad, initial phase angle of Phase-A voltage
Vdgr0 = Vmagr0; % pu, d-axis grid voltage
Vqgr0 = 0; % pu, q-axis grid voltage
Iabcgr0 = opReceivingEndGridVI.get("I_output").Value.value; % pu, initial three-phase AC grid current
abc2dgr0 = (2/3)*[sin(Vphaser0) sin(Vphaser0-2*pi/3) sin(Vphaser0+2*pi/3)];
abc2qgr0 = (2/3)*[cos(Vphaser0) cos(Vphaser0-2*pi/3) cos(Vphaser0+2*pi/3)];
Idgr0 = abc2dgr0*Iabcgr0'; % pu, d-axis grid current
Iqgr0 = abc2qgr0*Iabcgr0'; % pu, q-axis grid current
receivingEndVIMeas2RelPath = 'Receiving end vi2/Current and Voltage Sensor (Three-Phase)';
opReceivingEndVIMeas2RelPathEndReactorVI = get(op, receivingEndVIMeas2RelPath);
Iabcrr0 = opReceivingEndVIMeas2RelPathEndReactorVI.get("I_output").Value.value; % pu, initial three-phase reactor current
abc2drr0 = (2/3)*[sin(-pi/6+Vphaser0) sin(-pi/6+Vphaser0-2*pi/3) sin(-pi/6+Vphaser0+2*pi/3)];
abc2qrr0 = (2/3)*[cos(-pi/6+Vphaser0) cos(-pi/6+Vphaser0-2*pi/3) cos(-pi/6+Vphaser0+2*pi/3)];
Idr0 = abc2drr0*Iabcrr0'; % pu, d-axis grid reactor current
Iqr0 = abc2qrr0*Iabcrr0'; % pu, q-axis grid reactor current
receivingEndVSCRelPath = 'Receiving end Converter/Average-value VSC/Average-value VSC';
opReceivingEndVSC = get(op, receivingEndVSCRelPath);
ModWaver0 = opReceivingEndVSC.get("ModWave").Value.value;
Vabcr0 = ModWaver0*(Vdcr0/Vbase)/2; % pu, three-phase converter voltage
Vdr0 = abc2drr0*Vabcr0'; % pu, d-axis converter voltage
Vqr0 = abc2qrr0*Vabcr0'; % pu, q-axis converter voltage
Id_PIr0 = (Vdgr0+Iqgr0*Lt+Iqr0*Lr) - Vdr0; % pu, d-axis current PI initial state
Iq_PIr0 = -(Idgr0*Lt+Idr0*Lr) - Vqr0; % pu, q-axis current PI initial state
if strcmp(fidelity, 'Medium')
    P_PIr0 = Idgr0; % pu, active power PI initial state
    Q_PIr0 = Iqgr0; % pu, reactive power PI initial state
else
    A = Vdr0+Idr0*Rr-Vdgr0-Iqr0*Lr;
    B = Vqr0+Iqr0*Rr+Idr0*Lr;
    P_PIr0 = -(A*Rt+B*Lt)/(Rt^2+Lt^2); % pu, active power PI initial state
    Q_PIr0 = (A*Lt-B*Rt)/(Rt^2+Lt^2); % pu, reactive power PI initial state
end

set_param(bdroot,'SimscapeUseOperatingPoints','on');
set_param(bdroot,'SimscapeOperatingPoint','op');
set_param( [ bdroot '/Solver Configuration' ],'DoDC','off');

if fidelitySet == VoltageSourceConverterHVDCTransEnum.High
    fidelity = VoltageSourceConverterHVDCTransEnum.High;
    Ts = 1/(fsw*100); % s, fundamental sample time
    Tsc = 10*Ts; % s, control sample time
    set_param( [ bdroot '/Solver Configuration' ],'EquationFormulation','NE_TIME_EF');
    set_param( [ bdroot '/Solver Configuration' ],'MaxNonlinIter','4');
    set_param([ bdroot '/Control/Sending end and receiving end control' ],'modeling_fidelity','High');
end

set_param([ bdroot '/Control/Sending end and receiving end control' ],'InitUsingOP','on');
set_param([ bdroot '/Control/Sending end and receiving end control' ],'Vabcgs0',['[' num2str(Vabcgs0) ']']);
set_param([ bdroot '/Control/Sending end and receiving end control' ],'Vphases0',num2str(Vphases0));
set_param([ bdroot '/Control/Sending end and receiving end control' ],'Vdqgs0',['[' num2str([Vdgs0 Vqgs0]) ']']);
set_param([ bdroot '/Control/Sending end and receiving end control' ],'Iabcgs0',['[' num2str(Iabcgs0) ']']);
set_param([ bdroot '/Control/Sending end and receiving end control' ],'Idqgs0',['[' num2str([Idgs0 Iqgs0]) ']']);
set_param([ bdroot '/Control/Sending end and receiving end control' ],'Iabcrs0',['[' num2str(Iabcrs0) ']']);
set_param([ bdroot '/Control/Sending end and receiving end control' ],'Idqs0',['[' num2str([Ids0 Iqs0]) ']']);
set_param([ bdroot '/Control/Sending end and receiving end control' ],'P_PIs0',num2str(P_PIs0));
set_param([ bdroot '/Control/Sending end and receiving end control' ],'Q_PIs0',num2str(Q_PIs0));
set_param([ bdroot '/Control/Sending end and receiving end control' ],'Id_PIs0',num2str(Id_PIs0));
set_param([ bdroot '/Control/Sending end and receiving end control' ],'Iq_PIs0',num2str(Iq_PIs0));
set_param([ bdroot '/Control/Sending end and receiving end control' ],'Vdcs0',num2str(Vdcs0));
set_param([ bdroot '/Control/Sending end and receiving end control' ],'IL0',num2str(IL0));

set_param([ bdroot '/Control/Sending end and receiving end control' ],'Vabcgr0',['[' num2str(Vabcgr0) ']']);
set_param([ bdroot '/Control/Sending end and receiving end control' ],'Vphaser0',num2str(Vphaser0));
set_param([ bdroot '/Control/Sending end and receiving end control' ],'Vdqgr0',['[' num2str([Vdgr0 Vqgr0]) ']']);
set_param([ bdroot '/Control/Sending end and receiving end control' ],'Iabcgr0',['[' num2str(Iabcgr0) ']']);
set_param([ bdroot '/Control/Sending end and receiving end control' ],'Idqgr0',['[' num2str([Idgr0 Iqgr0]) ']']);
set_param([ bdroot '/Control/Sending end and receiving end control' ],'Iabcrr0',['[' num2str(Iabcrr0) ']']);
set_param([ bdroot '/Control/Sending end and receiving end control' ],'Idqr0',['[' num2str([Idr0 Iqr0]) ']']);
set_param([ bdroot '/Control/Sending end and receiving end control' ],'P_PIr0',num2str(P_PIr0));
set_param([ bdroot '/Control/Sending end and receiving end control' ],'Q_PIr0',num2str(Q_PIr0));
set_param([ bdroot '/Control/Sending end and receiving end control' ],'Id_PIr0',num2str(Id_PIr0));
set_param([ bdroot '/Control/Sending end and receiving end control' ],'Iq_PIr0',num2str(Iq_PIr0));
set_param([ bdroot '/Control/Sending end and receiving end control' ],'Vdcr0',num2str(Vdcr0));