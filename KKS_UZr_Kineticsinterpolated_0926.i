length_scale = '${units 1e-6 m}' #um
time_scale = '${units 1 s}' #sec
energy_scale = '${units 1e-12 J}' #pJ
sigma = 0.5
kappa = '${fparse (6*l*sigma)/alpha}'
double_well = '${fparse (3*alpha*sigma)/l}'
outer_radii = 0.00243
inner_radii = 0.001625

alpha = 2.2 #2.94
l = 36 #18 #30.3 #um
#interfacial_mobility = '${fparse 0.7}' #um^3/pJsec
#m_c_chem = '${fparse 0.7}'

#mpirun -n 8 /blue/michael.tonks/cj.oleary/projects/moose/modules/combined/combined-opt -i KKS_UZr_Kineticsinterpolated_0926.i

 
[Mesh] 
  coord_type = 'RZ'
  # rz_coord_axis = 'X'
  type = GeneratedMesh
  dim = 1
  nx = 800
  ny = 800
  xmin = 0
  xmax = 2430 #Fuel outer radius
  #uniform_refine = 3
  # inner radius = 1625
[]

[AuxVariables]
  [./Fglobal]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./c_u]
  [../]
[]

[BCs]
  [temperature]
    type = DirichletBC
    variable = T
    boundary = right
    value = 813
  []
[]

[Variables]
  #CoupledTemperature
  [./T]
  initial_condition = 300
  [../]
  # order parameter
  [./eta]
    order = FIRST
    family = LAGRANGE
  [../]

  # Zirconium concentration
  [./c_zr]
    order = FIRST
    family = LAGRANGE
  [../]

  # Vacancy concentration
  [./c_v]
    order = FIRST
    family = LAGRANGE
  [../]


  # chemical potential Zirconium
  [./w1]
    order = FIRST
    family = LAGRANGE
  [../]

  # chemical potential Vacancy
  [./w2]
    order = FIRST
    family = LAGRANGE
  [../]


  # Fuel solid phase Zirconium 
  [./c_zr_l]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0.225
  [../]

  # Fuel solid phase Vacancy
  [./c_v_l]
    order = FIRST
    family = LAGRANGE
    initial_condition = 1e-6
  [../]

  # Annulus phase Zirconium
  [./c_zr_s]
    order = FIRST
    family = LAGRANGE
    initial_condition = 1e-6
  [../]

  # Annulus phase Vacancy
  [./c_v_s]
    order = FIRST
    family = LAGRANGE
    initial_condition = 1
  [../]
[]

[Functions]
#LHGR
  [f_power] #linear power
   type = PiecewiseLinear
   x = '0 3600 86400 432000 864000 1296000 1728000 2160000 2592000 3024000 3456000 3888000 4320000 4752000
    5184000 5616000 6048000 6480000 6912000 7344000 7776000 8208000 8640000 9072000 9504000 9936000 10368000'
   y = '0 33439 33439 33189 33527 33527 33527 33527 33651 33651 33762 31405 31405 32099 32392 32542 32763
    33212 33212 33212 33212 33212 30507 31602 31602 31602 31130'
  []
  [f_axial_power]
    type = ConstantFunction
    value = 1
  []
  [./ic_func_eta]
    type = ParsedFunction
    expression = '0.5*(1.0-tanh((x-1625)*sqrt(${double_well})/sqrt(2*${kappa})))'
  [../]
  [./ic_func_c1]
    type = ParsedFunction
    expression = '1e-6*(0.5*(1.0-tanh((x-1625)*sqrt(${double_well})/sqrt(2*${kappa}))))^3*(6*(0.5*(1.0-tanh((x-1625)*sqrt(${double_well})/sqrt(2*${kappa}))))^2-15*(0.5*(1.0-tanh((x-1625)*sqrt(${double_well})/sqrt(2*${kappa}))))+10)+0.225*(1-(0.5*(1.0-tanh((x-1625)*sqrt(${double_well})/sqrt(2*${kappa}))))^3*(6*(0.5*(1.0-tanh((x-1625)*sqrt(${double_well})/sqrt(2*${kappa}))))^2-15*(0.5*(1.0-tanh((x-1625)*sqrt(${double_well})/sqrt(2*${kappa}))))+10))'
  [../]
  [./ic_func_c2]
    type = ParsedFunction
    expression = '1*(0.5*(1.0-tanh((x-1625)*sqrt(${double_well})/sqrt(2*${kappa}))))^3*(6*(0.5*(1.0-tanh((x-1625)*sqrt(${double_well})/sqrt(2*${kappa}))))^2-15*(0.5*(1.0-tanh((x-1625)*sqrt(${double_well})/sqrt(2*${kappa}))))+10)+1e-12*(1-(0.5*(1.0-tanh((x-1625)*sqrt(${double_well})/sqrt(2*${kappa}))))^3*(6*(0.5*(1.0-tanh((x-1625)*sqrt(${double_well})/sqrt(2*${kappa}))))^2-15*(0.5*(1.0-tanh((x-1625)*sqrt(${double_well})/sqrt(2*${kappa}))))+10))'
  [../]
[]

[ICs]
  [./eta]
    variable = eta
    type = FunctionIC
    function = ic_func_eta
  [../]
  [./c1]
    variable = c_zr
    type = FunctionIC
    function = ic_func_c1
  [../]
  [./c2]
    variable = c_v
    type = FunctionIC
    function = ic_func_c2
  [../]
[]

[Materials]
 #[fuel_thermal_conductivity]
   # type = UPuZrThermal
    #temperature = T
    #X_Zr = 0.225
   # X_Pu = 0
    #thcond_model = lanl
    #porosity = porosity
    #spheat_model = savage
    #outputs = exodus
  #[]

  [coeff_aa1]
    type = DerivativeParsedMaterial
    property_name = 'aa1'
    coupled_variables = 'c_zr'
    expression = '(17.5 * (1-2.23*c_zr)/(1+1.61*c_zr))'
    outputs = exodus
  []

  [coeff_aa2]
    type = DerivativeParsedMaterial
    property_name = 'aa2'
    coupled_variables = 'c_zr'
    expression = '(0.0154 * (1+0.061*c_zr)/(1+1.61*c_zr))'
    outputs = exodus
  []

  [zr_specific_heat]
    type = DerivativeParsedMaterial
    property_name = 'cp_zr'
    coupled_variables = 'T'
    expression = '(164.812818966 + 0.623108738*T - 0.000982894*T^2 + 0.000000550*T^3)'
    outputs = exodus
  []

  [u_specific_heat]
    type = DerivativeParsedMaterial
    property_name = 'cp_u'
    coupled_variables = 'T'
    expression = '(121.4650125626 - 0.0974672888*T + 0.0002986755*T^2 - 0.0000001184*T^3)'
    outputs = exodus
  []

  [fission_rate]
    type = DerivativeParsedMaterial
    functor_names = 'f_axial_power f_power'
    functor_symbols = 'fa fp'
    property_name = 'fission_rate_uzr'
    expression = '((fa*fp)/(3.14*(${outer_radii}^2-${inner_radii}^2)*3.2e-11))'
    outputs = exodus
  []

  [fuel_thermal_conductivity]
    type = DerivativeParsedMaterial
    property_name = 'thermal_conductivity'
    coupled_variables = 'T c_zr'
    material_property_names = 'aa1 aa2'
    constant_names = 'aa3'
    constant_expressions = '9.38e-6'
    expression = '(aa1 + (aa2)*T + (aa3)*T^2)'
    outputs = exodus
  []

  [fuel_specific_heat]
    type = DerivativeParsedMaterial
    property_name = 'specific_heat'
    coupled_variables = 'T c_zr'
    material_property_names = 'cp_zr cp_u'
    expression = '(cp_zr*c_zr + cp_u*(1-c_zr))' # J/kg*K
    outputs = exodus
  []

  [./h_eta]
    type = SwitchingFunctionMaterial
    h_order = HIGH
    eta = eta
    outputs = exodus
  [../]

  [./h_fuel]
  type = DerivativeParsedMaterial
  property_name = 'h_fuel'
  material_property_names = 'h'
  expression = '(1-h)'
  outputs = exodus
  [../]

  # [fuel_gaseous_swelling] ###NOT---NEEDED### right now
  #   type = UPuZrGaseousEigenstrain
  #   fission_rate = fission_rate
  #   temperature = T
  #   anisotropic_factor = 0.5
  #   bubble_number_density = 5e17
  #   interconnection_initiating_porosity = 0.28
  #   interconnection_terminating_porosity = 0.3
  #   eigenstrain_name = fuel_gaseous_strain
  #   outputs = exodus
  #   output_properties = 'gas_swelling porosity interconnectivity'
  # []
  
#  [fission_rate]
#     type = UPuZrFissionRate
#     X_Pu_function = 0
#     initial_X_Zr = 0.225
#     X_Zr = 0.225
#     rod_linear_power = f_power
#     axial_power_profile = f_axial_power
#     pellet_radius = 0.00243
#     pellet_inner_radius = 0.001625
#     outputs = exodus
#   []



  [density_constant]
    type = GenericConstantMaterial
    prop_names = 'density'
    prop_values = 15808 #units of um3
    outputs = exodus
  []
  [density]
    type = DerivativeParsedMaterial
    property_name = density_matrix
    material_property_names = 'h_fuel'
    expression = '15808*(${length_scale})^3*(h_fuel) + 1*(${length_scale})^3*(1-h_fuel)' #Units in kg/um3
    outputs = exodus
  []
  [./thermalconductivity_interpolated]
    type = ParsedMaterial
    property_name = solid_thermalcond
    material_property_names = 'thermal_conductivity h_fuel'
    expression = '(((thermal_conductivity)*(${length_scale}*${time_scale}))/(${energy_scale}))*(h_fuel) + 1e-2*((${length_scale}*${time_scale})/(${energy_scale}))*(1-h_fuel)'
    outputs = exodus      
  [../]

  #SpcificHeat_interpolated
  [./SpecificHeat_interpolated]
    type = DerivativeParsedMaterial
    property_name = solid_specificheat
    material_property_names = 'specific_heat h_fuel'
    expression = '(specific_heat/(${energy_scale}))*(h_fuel) + (0.0005/(${energy_scale}))*(1-h_fuel)'
    outputs = exodus      
  [../]

  #Heatgeneration_interpolated
  [./Heatgeneration_interpolated]
    type = DerivativeParsedMaterial
    property_name = solid_heatgeneration
    material_property_names = 'h_fuel fission_rate_uzr'
    expression = 'fission_rate_uzr*3.2e-11*(((${length_scale})^3*${time_scale})/(${energy_scale}))*(h_fuel) + 
    0*(((${length_scale})^3*${time_scale})/(${energy_scale}))*(1-h_fuel)'
    outputs = exodus      
  [../]  

#Zirconium mobility
  #[./M_zr]
  #type = DerivativeParsedMaterial
  #property_name = M_Zr
  #coupled_variables = 'T'
  #material_property_names = 'D_zr'
  #constant_names = R
  #constant_expressions = '8.314*10^12'
  #expression = '(D_zr/(R*T))'
  #derivative_order = 2
  #outputs = exodus
  #[]

  [./M_zr]
    type = DerivativeParsedMaterial
    property_name = M_Zr
    coupled_variables = 'c_zr_l'
    material_property_names = 'D_zr d2f:=D[fl,c_zr_l,c_zr_l]'
    expression = 'D_zr/d2f'
    outputs = exodus
  [../]
#Effective mobility of Zr
  [./M_Zr_eff]
    type = DerivativeParsedMaterial
    property_name = M_Zr_eff
    coupled_variables = 'c_zr_l'
    material_property_names = 'D_zr_eff d2f:=D[fl,c_zr_l,c_zr_l]'
    expression = 'D_zr_eff/d2f'
    outputs = exodus
  [../]

#Effective Diffusivity of Zr
  [./D_zr_eff]
  type = DerivativeParsedMaterial
  property_name = D_zr_eff
  material_property_names = 'D_zr h_fuel'
  expression = 'D_zr*h_fuel + 0.5*D_zr*(1-h_fuel)'
  outputs = exodus
  []
#Diffusivity of Zr in gamma phase
  [./D_zr]
  type = DerivativeParsedMaterial
  property_name = D_zr
  coupled_variables = 'T'
  material_property_names = 'Q D0'
  constant_names = 'R'
  constant_expressions = '8.314e12'
  expression = 'D0*exp(-(Q)/(R*T))'
  outputs = exodus
  []
#Diffusivityprefactor
  [./D_zr_o]
  type = DerivativeParsedMaterial
  property_name = D0
  coupled_variables = 'c_zr_l'
  #constant_names = X_Zr
  #constant_expressions = '0.225'
  #expression = '(exp(-6.15 - 18.5*c_zr + 21*(c_zr)^2))*(${time_scale}/(${length_scale})^2)'
  expression = '(exp(-6.15 - 18.5*c_zr_l + 21*(c_zr_l)^2))*(${time_scale}/(${length_scale})^2)'
  outputs = exodus
  []
#Activationenergy
  [./Q]
  type = DerivativeParsedMaterial
  property_name = Q
  coupled_variables = 'c_zr_l'
  #constant_names = X_Zr
  #constant_expressions = '0.225'
  expression = '(128 - 107*c_zr_l + 174*(c_zr_l)^2)*(1000/(${energy_scale}))'
  outputs = exodus
  []

#Effective diffusivity of vacancies
  [./D_v_eff]
  type = DerivativeParsedMaterial
  property_name = D_v_eff
  material_property_names = 'D_zr h_fuel'
  expression = '1.5*D_zr*h_fuel + 2*D_zr*(1-h_fuel)'
  outputs = exodus
  []
#Effective mobility of vacancies
  [./M_v_eff]
    type = DerivativeParsedMaterial
    property_name = M_vac_eff
    coupled_variables = 'c_v_l'
    material_property_names = 'D_v_eff d2f:=D[fl,c_v_l,c_v_l]'
    expression = 'D_v_eff/d2f'
    outputs = exodus
  [../]  


  #thermalmobility
  [./D_temp]
  type = DerivativeParsedMaterial
  property_name = D_temperature
  coupled_variables = 'T eta c_zr c_v'
  material_property_names = 'D_zr_eff'
  expression = '-((D_zr_eff*6*c_zr*(1-c_zr-c_v)*(1-eta))/(T^2))'
  outputs = exodus      
  [../]
  [./D_temp_vac]
  type = DerivativeParsedMaterial
  property_name = D_temperature_vac
  coupled_variables = 'T eta c_zr c_v'
  material_property_names = 'D_zr_eff'
  expression = '((D_zr_eff*6*c_zr*(1-c_zr-c_v)*(1-eta))/(T^2))'
  outputs = exodus 
  [../]
  #could not replace the Q*/R properly, but did add in the concentration & diffusion dependence
  #testing testing

  # Free energy of the liquid
  [./fl]
    type = DerivativeParsedMaterial
    property_name = fl
    coupled_variables = 'c_zr_l c_v_l'
    expression = '(0.225-c_zr_l)^2+30*(0-c_v_l)^2+(1-c_zr_l-c_v_l-0.775)^2'
    #expression = '(0.225-c_zr_l)^2+(1e-6-c_v_l)^2+(1-c_zr_l-c_v_l-0.775)^2'
  [../]

  # Free energy of the solid
  [./fs]
    type = DerivativeParsedMaterial
    property_name = fs
    coupled_variables = 'c_zr_s c_v_s'
    expression = '100*(0-c_zr_s)^2+30*(1-c_v_s)^2+30*(1-c_zr_s-c_v_s-0)^2'
    #expression = '(0-c_zr_s)^2+(1-c_v_s)^2+(1-c_zr_s-c_v_s-0)^2'
  [../]

  # h(eta)

  # g(eta)
  [./g_eta]
    type = BarrierFunctionMaterial
    g_order = SIMPLE
    eta = eta
  [../]
[]

[Kernels]

  # enforce c1 = (1-h(eta))*c1l + h(eta)*c1s
  [./PhaseConc1]
    type = KKSPhaseConcentration
    ca       = c_zr_l
    variable = c_zr_s
    c        = c_zr
    eta      = eta
  [../]

  # enforce c2 = (1-h(eta))*c2l + h(eta)*c2s
  [./PhaseConc2]
    type = KKSPhaseConcentration
    ca       = c_v_l
    variable = c_v_s
    c        = c_v
    eta      = eta
  [../]

  # enforce pointwise equality of chemical potentials
  [./ChemPotSolute1]
    type = KKSPhaseChemicalPotential
    variable = c_zr_l
    cb       = c_zr_s
    fa_name  = fl
    fb_name  = fs
    args_a   = 'c_v_l'
    args_b   = 'c_v_s'
  [../]
  [./ChemPotSolute2]
    type = KKSPhaseChemicalPotential
    variable = c_v_l
    cb       = c_v_s
    fa_name  = fl
    fb_name  = fs
    args_a   = 'c_zr_l'
    args_b   = 'c_zr_s'

  [../]

  #
  # Cahn-Hilliard Equations
  #
  [./CHBulk1]
    type = KKSSplitCHCRes
    variable = c_zr
    ca       = c_zr_l
    fa_name  = fl
    w        = w1
    args_a   = 'c_v_l'
  [../]
  [./CHBulk2]
    type = KKSSplitCHCRes
    variable = c_v
    ca       = c_v_l
    fa_name  = fl
    w        = w2
    args_a   = 'c_zr_l'
  [../]

  [./dc1dt]
    type = CoupledTimeDerivative
    variable = w1
    v = c_zr
  [../]
  [./dc2dt]
    type = CoupledTimeDerivative
    variable = w2
    v = c_v
  [../]

  [./w1kernel]
    type = SplitCHWRes
    mob_name = M_Zr_eff #mobility of Zirconium
    variable = w1
  [../]
  [./w2kernel]
    type = SplitCHWRes
    mob_name = M_vac_eff #${m_c_chem}
    variable = w2
  [../]

  #thermomigration term added using Matdiffusion

  [./thermomigration]
    type = MatDiffusion
    variable = w1
    diffusivity = D_temperature
    v = 'T'
  [../]

  [./thermomigrationvac]
    type = MatDiffusion
    variable = w2
    diffusivity = D_temperature_vac
    v = 'T'
  [../]

  #
  # Allen-Cahn Equation
  #
  [./ACBulkF]
    type = KKSACBulkF
    variable = eta
    fa_name  = fl
    fb_name  = fs
    mob_name = M_Zr #${interfacial_mobility}
    w        = ${double_well} #0.108
    coupled_variables = 'c_zr_l c_zr_s c_v_l c_v_s'
  [../]
  [./ACBulkC1]
    type = KKSACBulkC
    variable = eta
    ca       = c_zr_l
    mob_name = M_Zr #${interfacial_mobility}
    cb       = c_zr_s
    fa_name  = fl
    coupled_variables     = 'c_v_l'
  [../]
  [./ACBulkC2]
    type = KKSACBulkC
    variable = eta
    ca       = c_v_l
    cb       = c_v_s
    mob_name = M_Zr #${interfacial_mobility}
    fa_name  = fl
    coupled_variables     = 'c_zr_l'
  [../]
  [./ACInterface]
    type = ACInterface
    variable = eta
    coupled_variables = 'c_zr_l'
    kappa_name = ${kappa}
    mob_name = M_Zr #${interfacial_mobility}
  [../]
  [./detadt]
    type = TimeDerivative
    variable = eta
  [../]

  #CoupledHeatConductionSolve
   [heat_dt]
    type = HeatConductionTimeDerivative
    variable = T
    specific_heat = solid_specificheat
    density_name = density_matrix
  []
  [heat_conduction]
    type = HeatConduction
    variable = T
    thermal_conductivity = solid_thermalcond #thermal_conductivity #1 
  []

  [masked_heatsource]
    type = MaskedBodyForce
    variable = T
    mask = solid_heatgeneration
    coupled_variables = 'eta'
  []
[]

[AuxKernels]
  [./GlobalFreeEnergy]
    variable = Fglobal
    type = KKSGlobalFreeEnergy
    fa_name = fl
    fb_name = fs
    w = ${double_well} #0.108
  [../]
  #[Temperature_const]
    #type = ConstantAux
    #variable = T
    #value = 900
  #[]
  [c3]
    type = ParsedAux
    variable = c_u
    coupled_variables = 'c_zr c_v'
    expression = '1 - c_zr - c_v'
  []
[]

[Debug]
  # show_var_residual = true
  show_var_residual_norms = true
[]


#[Executioner]
  #type = Transient
  #solve_type = 'PJFNK'
  #line_search = bt

  #petsc_options_iname = '-pc_type -sub_pc_type -sub_pc_factor_shift_type'
  #petsc_options_value = 'asm      ilu          nonzero'

  #petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
  #petsc_options_value = 'lu superlu_dist'

  #l_max_its = 15
  #l_tol = 1e-6
  #nl_max_its = 15
  #nl_rel_tol = 1e-8
  #nl_abs_tol = 1e-10

  #num_steps = 5000 #50 #Run it for 5000 and use adaptive dT....(use dT = 0.1) Iteration Adaptive dT (Do the same for RZ_varname file
  #dt = 0.0001
  #[TimeStepper]
    #type = IterationAdaptiveDT 
    #dt = 0.1
  #[]
#[]

[Executioner]
type = Transient
solve_type = PJFNK
#petsc_options_iname = '-pc_type -ksp_gmres_restart -sub_pc_type -pc_asm_overlap'
#petsc_options_value = 'asm      31                  lu           1'
petsc_options_iname = '-pc_type -pc_factor_shift_type'
petsc_options_value = 'lu nonzero'
l_max_its = 100
l_tol = 1e-4
nl_max_its = 15
nl_rel_tol = 1e-8
nl_abs_tol = 1e-9
automatic_scaling = true
#steady_state_detection = true
#steady_state_tolerance = 1e-6#1e-8
#compute_scaling_once = false
end_time = 1.0368e7
[./TimeStepper]
type = IterationAdaptiveDT
growth_factor = 1.2
cutback_factor = 0.5
optimal_iterations = 7
dt = 1e-4 #1
[]
[]

[Postprocessors]
  [Area_annulus]
    type = ElementIntegralVariablePostprocessor
    variable = eta
    outputs = csv
  []
[]


#
# Precondition using handcoded off-diagonal terms
#
[Preconditioning]
  [./full]
    type = SMP
    full = true
  [../]
[]

[Outputs]
  exodus = true
  csv = true
  file_base = /blue/michael.tonks/cj.oleary/uzr/outputs/KKSUZr_output0926
[]
