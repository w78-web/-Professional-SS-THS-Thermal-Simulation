function SelfSustainingCooling()
% SS-THS RESEARCH PROTOTYPE v7.0 (Final Academic Edition)
% Integrated PMU Boost Logic & Right-Side Identification
clear; clc; close all;

% --- 1. REALISTIC PHYSICS PARAMETERS ---
% These values are based on real-world Thermoelectric properties
data.T_chip = 25; 
data.battery_v = 0;       % Initial battery charge state
data.alpha_module = 0.025; % Combined Seebeck Coeff for a 127-junction module (V/K)
data.T_sky = 25;          % Standard ambient/sink temperature

% --- 2. GUI SETUP ---
hFig = figure('Name','SS-THS: Integrated Energy Harvesting System','Color',[0.02, 0.02, 0.02], ...
    'Position', [50, 50, 1300, 800]);

% Thermal Control (Input Heat from the IC)
uicontrol('Style','text','Position', [450, 40, 300, 25], ...
    'String', 'IC CHIP THERMAL LOAD (°C)', ...
    'FontSize', 11, 'FontWeight', 'bold', 'ForegroundColor', 'w', 'BackgroundColor', [0.02, 0.02, 0.02]);

hSlider = uicontrol('Style','slider', 'Min', 25, 'Max', 150, 'Value', 25, ...
    'Position', [350, 15, 500, 20]);

% --- 3. LIVE ANIMATION LOOP ---
while ishandle(hFig)
    % Update Input from User
    data.T_chip = get(hSlider, 'Value');
    dT = data.T_chip - data.T_sky;
    
    % PHYSICS: Raw Seebeck Generation
    V_raw = data.alpha_module * (dT/10); % Practical mV scale
    
    % PMU LOGIC: Boost tiny mV to 4.2V charging rail
    if V_raw > 0.05
        % Using a saturation function to mimic a Boost Converter (like LTC3108)
        V_system = 4.2 * (1 - exp(-V_raw * 5)); 
        charge_rate = V_system * 0.015;
    else
        V_system = 0;
        charge_rate = 0;
    end
    data.battery_v = min(100, data.battery_v + charge_rate);
    
    % --- LHS: 3D SCHEMATIC ASSEMBLY ---
    subplot('Position', [0.05, 0.15, 0.60, 0.8]); cla; hold on; view(30, 25); axis off;
    axis([-5 25 -2 15 0 12]); 
    set(gca, 'Color', [0.04, 0.04, 0.04]);
    title('MECHANICAL STACK & ENERGY ROUTING', 'Color', 'w', 'FontSize', 15);

    % Color transition for the Silicon IC
    ic_col = [min(1, data.T_chip/140), 0.1, 0.1];
    
    % LAYER 1: SILICON IC (The Foundation)
    draw_layer(0,0,0, 10,10,1.2, ic_col);
    text(12, 5, 0.6, '\leftarrow LAYER 1: SILICON IC CHIP', 'Color', 'r', 'FontSize', 10, 'FontWeight', 'bold');

    % LAYER 2: TEG MATERIAL (The Collector)
    draw_layer(0,0,1.5, 10,10,0.8, [0.85, 0.7, 0]);
    text(12, 5, 1.9, '\leftarrow LAYER 2: TEG HARVESTER', 'Color', [0.85, 0.7, 0], 'FontSize', 10, 'FontWeight', 'bold');

    % LAYER 3: NANOWIRE PUMP (The Bridge)
    draw_layer(0,0,2.6, 10,10,2.5, [0.4, 0.4, 0.45]);
    text(12, 5, 3.8, '\leftarrow LAYER 3: EPP NANOWIRE PUMP', 'Color', [0.7, 0.7, 0.7], 'FontSize', 10, 'FontWeight', 'bold');

    % LAYER 4: EMISSIVE SKIN (The Sink)
    draw_layer(0,0,5.2, 10,10,0.4, [0, 0.45, 0.9]);
    text(12, 5, 5.4, '\leftarrow LAYER 4: RADIATIVE SKIN', 'Color', [0, 0.6, 1], 'FontSize', 10, 'FontWeight', 'bold');
    
    % WIRING: From TEG (Layer 2) to Battery Side
    plot3([10, 11, 11], [5, 5, 5], [1.9, 1.9, 9], 'y', 'LineWidth', 4); % Positive
    plot3([10, 11.5, 11.5], [4, 4, 4], [1.9, 1.9, 8.5], 'w', 'LineWidth', 2); % Negative
    text(11, 5, 10, 'DC HARVEST BUS', 'Color', 'y', 'FontWeight', 'bold', 'HorizontalAlignment', 'center');

    % --- RHS: ANALYTICS & BATTERY ---
    subplot('Position', [0.70, 0.2, 0.25, 0.7]); cla; hold on; axis([0 10 0 100]);
    set(gca, 'Color', [0.02, 0.02, 0.02], 'XTick', [], 'YTick', []);
    
    % Battery Unit
    rectangle('Position', [3, 15, 4, 70], 'EdgeColor', 'w', 'LineWidth', 2, 'Curvature', 0.1); 
    rectangle('Position', [3.3, 17, 3.4, data.battery_v*0.66], 'FaceColor', [0, 0.8, 0.3], 'EdgeColor', 'none'); 
    
    % Real-Time Data Table
    text(0, 95, 'SYSTEM DIAGNOSTICS:', 'Color', 'c', 'FontSize', 11, 'FontWeight', 'bold');
    text(0, 85, sprintf('IC Temp: %0.1f C', data.T_chip), 'Color', 'w', 'FontSize', 10);
    text(0, 75, sprintf('Raw TEG: %0.3f V', V_raw), 'Color', [0.85, 0.7, 0], 'FontSize', 10);
    text(0, 65, sprintf('PMU Boost: %0.2f V', V_system), 'Color', 'y', 'FontSize', 15, 'FontWeight', 'bold');
    
    if V_system > 3.0
        text(0, 50, 'STATUS: CHARGING', 'Color', 'g', 'FontSize', 9, 'FontWeight', 'bold');
    end
    
    text(3.5, 10, sprintf('%d%%', round(data.battery_v)), 'Color', 'g', 'FontSize', 12, 'FontWeight', 'bold');
    
    drawnow;
end

    % --- LAYER ENGINE ---
    function draw_layer(x,y,z,w,d,h, col)
        v = [x y z; x+w y z; x+w y+d z; x y+d z; x y z+h; x+w y z+h; x+w y+d z+h; x y+d z+h];
        f = [1 2 6 5; 2 3 7 6; 3 4 8 7; 4 1 5 8; 1 2 3 4; 5 6 7 8];
        patch('Vertices', v, 'Faces', f, 'FaceColor', col, 'FaceAlpha', 0.85, 'EdgeColor', [0.3 0.3 0.3]);
    end
end