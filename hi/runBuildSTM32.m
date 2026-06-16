function runBuildSTM32()
diary('runBuildSTM32_out.txt'); diary on;
mdl = 'STM32InverterCtrl';
ok = struct('build',false,'update',false,'codegen',false);
try
    buildSTM32Inverter(pwd);
    ok.build = true;
    fprintf('STEP1 build OK\n');
catch e
    fprintf('STEP1 build FAIL: %s\n', e.message);
    diary off; return;
end

% --- validate the model (compile/update diagram) ---
try
    load_system(mdl);
    set_param(mdl,'SimulationCommand','update');
    ok.update = true;
    fprintf('STEP2 update-diagram OK (model compiles, all types resolve)\n');
catch e
    fprintf('STEP2 update-diagram FAIL: %s\n', e.message);
end

% --- verify C code generation (no board / no cross-compile needed) ---
try
    set_param(mdl,'GenCodeOnly','on');
    slbuild(mdl);
    ok.codegen = true;
    fprintf('STEP3 codegen OK\n');
catch e
    fprintf('STEP3 codegen FAIL: %s\n', e.message);
end

% report key settings + generated artifacts
try
    fprintf('--- config ---\n');
    fprintf(' HardwareBoard = %s\n', get_param(mdl,'HardwareBoard'));
    fprintf(' SystemTargetFile = %s\n', get_param(mdl,'SystemTargetFile'));
    fprintf(' Solver = %s  FixedStep = %s\n', get_param(mdl,'Solver'), get_param(mdl,'FixedStep'));
catch e, fprintf('cfg err %s\n', e.message); end

d = dir(fullfile(pwd, [mdl '_ert_rtw'], '*.c'));
fprintf('--- generated .c files (%d) ---\n', numel(d));
for i=1:numel(d), fprintf('  %s\n', d(i).name); end

fprintf('RESULT build=%d update=%d codegen=%d\n', ok.build, ok.update, ok.codegen);
diary off;
end
