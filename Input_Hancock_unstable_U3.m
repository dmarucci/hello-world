%%%%%%%%%%%%%%%%%%%%%%%% EnFlo Post-Processing V1.0 %%%%%%%%%%%%%%%%%%%%%%%
clearvars; clc; close all; format long

folder_name = 'Hancock_unstable';
stability  = 'u'; % 's' (stable), 'u' (unstable), 'n' (neutral)
file_name = 'unstableU3';
subplot_title = 'Hancock, Zhang, Hayden (2013) - Unstable U3'; %if not specified is automatically generated
profile_type = 'v'; %'v' (vertical), 'l' (lateral)
V_components = 'UW'; %'UW', 'UV', 'UVW'  N.B. with 'UVW' the three components of velocity will be plotted assuming that they are in the same rows

find_profiles = 0; %Scan the results file to find all the profiles (to be improved)
plot_all = 0; %Scan the results file and plot all the profiles (to be improved)
export_data_spectra = 0; %Print data about spectra_points on the Command window
spectra_points = [91 86 82 80]; %Rows in the results file corresponding to the desired points

pos_1V = [ 91 102 113 124 135 146 ]; %Vertical profiles starting row
pos_2V = [ 101 112 123 134 145 156 ]; %Vertical profiles ending row
pos_1L = [  ]; %Lateral profiles starting row
pos_2L = [  ]; %Lateral profiles ending row

jump = 0; %If mismatch between results file rows and imported rows appears

%% %%%%%%%%%%%%%%%%%%%%%%%%%%% Profiles data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Basic information
U_ref = [1.5]; %Reference speed [m/s] for plots only*
u_s = [0.055]*U_ref; %Friction velocity [ms^-1]*
z0 = 0.10*10^-3; %Aerodynamic roughness lenght [m]
g = 9.81; %Acceleratin due to gravity [ms^-2]
k = 0.40; %Von Karman constant

% Monin-Obukhov similitude (for stable, unstable case only)
Theory_data = 1; %When multiple profile data exist, select which profile you are referring
height = [1.4]; %ABL height [m]
Delta_T = [-17.7]; % Temperature difference between free-stream value and floor [k]*
T_floor = [45]+273.15; %Absolute temperature of the floor [K]*
wt0 = [0.062]; %Kinematic surface heat flux [ms^-1K]*wt1 = 0.062 wt0 = 0.047
z0t = 0.0016e-03; %Thermal roughness lenght [m]
T_b = 45+273.15; %Absolute temperature near the surface [K] (for L0 w_sm only)
L_0 = [-0.956]; %Monin-Obhukov Length [m]*
% *If different values for different profiles are required, specify each value in the vector

%Reference velocity profile neutral (if stable, unstable only)
u_sn = 0.045*U_ref; %Reference Friction velocity neutral [ms^-1]
z0n = 0.12*10^-3; %Reference Aerodynamic roughness lenght neutral [m]

%% %%%%%%%%%%%%%%%%% Friction velocity calculation %%%%%%%%%%%%%%%%%%%%%%%%
u_s_calculation = 0; %Enable friction velocity calculation (possible with export_data_spectra, too)
u_s_method = 0; %1 for method1, 2 for method2, 0 for both
us_pos1 = 1; %Starting point in the u_s calculation
us_pos2 = 5; %Ending point in the u_s calculation
us_man_inp = 0; %Activate if you want to insert a different starting/ending point for each profile
us_pos1t = [us_pos1 us_pos1 us_pos1]; %If a different starting point for each profile is required modify here
us_pos2t = [us_pos2 us_pos2 us_pos2]; %If a different ending point for each profile is required modify here
%N.B. if you select 0 in us_pos1t the corrispondent profile is not considered in the u_s calculation
%%%%%%%%%% Vertical kinematic heat flux at the surface calculation %%%%%%%%
wt0_calculation = 0;  %(possible with export_data_spectra, too)
wt0_method = 0; %1 for method1, 2 for method2, 0 for both
wt_pos1 = 1; %Starting point
wt_pos2 = 7; %Ending point
wt_man_inp = 0; 
wt_pos1t = [wt_pos1 wt_pos1 wt_pos1]; 
wt_pos2t = [wt_pos2 wt_pos2 wt_pos2];

%%%%%%%%%%%%%%%%% Aerodynamic roughness length calculation %%%%%%%%%%%%%%%%
z0_calculation = 0;
z0_pos1 = 1; %Starting point
z0_pos2 = 5; %Ending point
z0_man_inp = 0;
z0_pos1t = [z0_pos1 z0_pos1 z0_pos1 0 z0_pos1 z0_pos1]; 
z0_pos2t = [z0_pos2 z0_pos2 z0_pos2 z0_pos2 z0_pos2 z0_pos2];

%%%%%%%%%%%%%%%%%%% Thermal roughness length calculation %%%%%%%%%%%%%%%%%%
z0t_calculation = 0;
z0t_pos1 = 1; %Starting point
z0t_pos2 = 5; %Ending point
z0t_man_inp = 0; 
z0t_pos1t = [z0t_pos1 z0t_pos1 z0t_pos1];
z0t_pos2t = [z0t_pos2 z0t_pos2 z0t_pos2];

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%% GRAPHS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Saved_plots = 0; %Activate saved graphs configuration
%graphs_conf_filename = 'Hancock_et_al2013_graphs';
graphs_conf_filename = 'Ohya_and_Uchida2004_graphs';

plot_U = [1 1 0 0 0 1]; %1.Exp, 2.Theory 3.MO(SU)LogFit(N) 4.NeutralRef(SU) 5.PowerFit** 6.OhyaE1(U)
plot_T = [2 1 0 1 1]; %1.Exp, 2.Theory 3.MO(SU) 4.InletT 5.OhyaE1(U)
plot_u2 = [1 1 0 0 0 0 0 1]; %1.Exp 2.Theory 3.MO(U) 4.Hancock(U) 5.Nieuwstadt(S) 6.Arya(N) 7.Caughey(SU) 8.OhyaS4-E1(SU)
plot_u1 = [0 0 0 0 1 1 0 0 0]; %1.Exp 2.Theory 3.ESDU(4)* 4.u'/U 5.M-O(U) 6.Hancock(U~4) 7.Nieuwstadt(S~4) 8.Arya(N) 9.Caughey(S~4)
plot_v2_w2 = [1 1 0 0 0 0 0 1]; %1.Exp 2.Theory 3.MO(SU) 4.Hancock(U) 5.Nieuwstadt(S) 6.Arya(N) 7.Caughey(SU) 8.OhyaS4-E1(SU)
plot_v1_w1 = [0 0 0 0 1 1 0 0 0]; %1.Exp 2.Theory 3.ESDU(4)*, 4.v(w)'/U 5.MO(SU) 6.Hancock(U~4) 7.Nieuwstadt(S) 8.Arya(N) 9.Caughey(S~4~v)
plot_t2 = [1 1 0 0 0 0 1]; %1.Exp 2.Theory 3.MO(SU) 4.Hancock(U) 5.Nieuwstadt(S) 6.Caughey(SU) 7.OhyaS4-E1(SU)
plot_t1 = [0 0 1 1 0 0]; %1.Exp 2.Theory 3.MO(SU) 4.Hancock(U) 5.Nieuwstadt(S) 6.Caughey(S)
plot_uv_uw = [1 1 0 0 0 0 0 0 1]; %1.Exp 2.Theory(uw) 3.- 4.uv(w)/u'(v')w' 5.M-O(S4U) 6.Nieuwstadt(S~4) 7.ESDU(4)*(?) 8.Caughey(S~4~uv) 9.OhyaE1(U~4~uv)
plot_ut = [0 0 0 0 0 0]; %1.Exp 2.Theory 3.- 4.ut/u't' 5.M-O(S4) 6.Caughey(S~4)
plot_wt = [1 1 0 0 0 0 0 0 1]; %1.Exp 2.Theory 3.- 4.wt/w't' 5.M-O(SU) 6.Hancock(U~4) 7.Nieuwstadt(S~4) 8.Caughey(SU~4) 9.OhyaE1(U~4)
plot_Ri = [0 0 1]; %1.Exp 2.Theory 3.MO(SU)
    Ri_lim = [-5 0.5]; %Ri limits
plot_Rif = [0 0 1 0]; %1.Exp 2.Theory 3.MO(SU) 4.Rif/Ri
    Rif_lim = [-5 10]; %Rif limits
plot_NBV = [0 0 1]; %1.Exp(S) 2.Nz/U 3.Nh/U
    NBV_lim = [0 10]; %NBV limits
plot_gradU = [0 0 0 0 0]; %1.Exp 2.Theory 3.MO(SU4) 4.fi_m 5.K_m
plot_gradT = [2 0 0 0 0]; %1.Exp 2.Theory 3.MO(SU4) 4.fi_h 5.K_h
plot_ER = [0 0 1]; %1.Exp(U) 2.Theory 3.MO(U)

plot_AllGraphs_Exp = 0; %Bypass the previous selection and plot all the experimental graphs
plot_AllGraphs_ExpTheory = 0; %Plot all the experimental and theoretical graphs
disable_AllGraphs_ex2 = 1; %Disable the plotting of all the graphs except those ones marked with 2
fav_order_ON = 0; %If you want to modify the order of graph in the multiplot
fav_order = {'U','T','u2','v2_w2','t2','uv_uw','wt'}; %Specify the personalised order of graphs

double_thermistor = 0; % 0 = Off, 1 = add only points above, 2 = add all points
double_thermistor_disp = 0.5; %second thermistor displacement [m]
w_Hsf = 1.0; % scaling factor for plot_w2(1) with Hancock version selected

pl_ON = 0; %Activate personalized legend
pl = {'x = 12500 mm (S)','x = 13950 mm (S)','x = 15400 mm (S)','x = 12500 mm (N)'}; %Personalized legend

%% Saving
subPlot = 0; %Save a multiplot image (PDF or EPS only)
save_graphs = 0; %Generate a series of single images (multiple format available)

% Graphs axis limit (first digit activates limit, second and third digit define the range)
z_ax = [0 0 0.9]; % for vertical profiles
y_ax = [0 -1000 1000]; % for lateral profiles
U_ax = [1 0 1.4]; 
T_ax = [0 -0.2 1];
u2_ax = [1 0.01 10];
u1_ax = [0 0 0.15];
v2_w2_ax = [1 0.01 10];
v1_w1_ax = [0 0 0.15];
t2_ax = [1 0.1 100];
t1_ax = [0 0 1];
uv_uw_ax = [1 -0.6 0.2];
ut_ax = [0 -0.05 4];
wt_ax = [1 -0.6 1.2];
Ri_ax = [0 0 0.5];
Rif_ax = [0 0 1];
NBV_ax = [0 0 0.5];
gradU_ax = [0 -1 6]*10^-3;
gradT_ax = [0 -0.5 2]*10^-3;
ER_ax = [1 0 1.1];
disable_all_limits = 0; %if true disable the limits previously defined (except y, z)

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%% ESDU options* %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
V10r = 5; %Reference velocity at 10 m high full scale (verified range: 10 - 40 m/s)
ESDU_corr_on = 1; %Activate correction for speed V10r different from 20 m/s
z0_ESDU = [0.1 0.001]; %ESDU Aerodynamic roughness lenght [m] (possible more than one)
ESDU_z_max_full = 0.85*200; %[m] Maximum height in full scale for the ESDU computation (max. 300 m)
ESDU_z_max_model = 0.85; %[m] Maximum height in model scale for ESDU plotting

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%% Arya options* %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
V10r_Arya = 5; %Reference velocity
z0_Arya = [0.3]; %Aerodynamic roughness lenght [m]
Arya_z_max_full = 200;%(u_s/U_ref*V10r_Arya/(6*0.0001)); %[m] Maximum height in full scale for the computation
Arya_z_max_model = 0.8; %[m] Maximum height in model scale for plotting

%% %%%%%%%%%%%%%%%%%%%%%%%%% P ower Fit mean U** %%%%%%%%%%%%%%%%%%%%%%%%%%%
U_refp = 0.6905;% Value of U/U_ref at the height z_refp
z_refp = 0.160; % reference height [m]
alphap = 0.50; %power law coefficient

addpath('Scripts')
Caller