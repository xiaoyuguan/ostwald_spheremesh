[Mesh]
  type = FileMesh
   file = sphere_mesh.e
[]

[Modules]
  [./PhaseField]
    [./Conserved]
      [./c]
        args = 'eta_1 eta_2 eta_3 eta_4'
        free_energy = f_chem
        kappa = kappa_c
        mobility = M
        solve_type = REVERSE_SPLIT
      [../]
    [../]
    [./Nonconserved]
      [./eta_1]
        args = 'c eta_2 eta_3 eta_4'
        free_energy = f_chem
        kappa = kappa_c
        mobility = L
      [../]
      [./eta_2]
        args = 'c eta_1 eta_3 eta_4'
        free_energy = f_chem
        kappa = kappa_c
        mobility = L
      [../]
      [./eta_3]
        args = 'c eta_1 eta_2 eta_4'
        free_energy = f_chem
        kappa = kappa_c
        mobility = L
      [../]
      [./eta_4]
        args = 'c eta_1 eta_2 eta_3'
        free_energy = f_chem
        kappa = kappa_c
        mobility = L
      [../]
    [../]
  [../]
[]

[ICs]
  [./concentrationIC]
    type = FunctionIC
    function = cIC
    variable = c
  [../]
  [./eta_1IC]
    type = FunctionIC
    function = eta_1IC
    variable = eta_1
  [../]
  [./eta_2IC]
    type = FunctionIC
    function = eta_2IC
    variable = eta_2
  [../]
  [./eta_3IC]
    type = FunctionIC
    function = eta_3IC
    variable = eta_3
  [../]
  [./eta_4IC]
    type = FunctionIC
    function = eta_4IC
    variable = eta_4
  [../]
[]

[Functions]
  [./theta]
    type = ParsedFunction
    vars = 'r'
    vals = '100'
    value = acos(z/r)
  [../]
  [./phi]
    type = ParsedFunction
    value = atan(y/x)
  [../]
  [./eta_1IC]
    type =   ParsedFunction
    vars = 'epsl_eta_sphere i theta phi psi'
    vals = '0.1 1 theta phi 1.5'
    value = 'epsl_eta_sphere*(cos(theta*i-4)*cos((0.7+i)*phi)
            +cos((11+i)*theta)*cos((11+i)*phi)
            +psi*(cos((4.6+0.1*i)*theta+(4.05+0.1*i)*phi)
            *cos((3.1+0.1*i)*theta-(0.4+0.1*i)*phi))^2)^2'
  [../]
  [./eta_2IC]
    type = ParsedFunction
    vars = 'epsl_eta_sphere i theta phi psi'
    vals = '0.1 2 theta phi 1.5'
    value = 'epsl_eta_sphere*(cos(theta*i-4)*cos((0.7+i)*phi)
            +cos((11+i)*theta)*cos((11+i)*phi)
            +psi*(cos((4.6+0.1*i)*theta+(4.05+0.1*i)*phi)
            *cos((3.1+0.1*i)*theta-(0.4+0.1*i)*phi))^2)^2'
  [../]
  [./eta_3IC]
    type = ParsedFunction
    vars = 'epsl_eta_sphere i theta phi psi'
    vals = '0.1 3 theta phi 1.5'
    value = 'epsl_eta_sphere*(cos(theta*i-4)*cos((0.7+i)*phi)
            +cos((11+i)*theta)*cos((11+i)*phi)
            +psi*(cos((4.6+0.1*i)*theta+(4.05+0.1*i)*phi)
            *cos((3.1+0.1*i)*theta-(0.4+0.1*i)*phi))^2)^2'
  [../]
  [./eta_4IC]
    type = ParsedFunction
    vars = 'epsl_eta_sphere i theta phi psi'
    vals = '0.1 4 theta phi 1.5'
    value = 'epsl_eta_sphere*(cos(theta*i-4)*cos((0.7+i)*phi)
            +cos((11+i)*theta)*cos((11+i)*phi)
            +psi*(cos((4.6+0.1*i)*theta+(4.05+0.1*i)*phi)
            *cos((3.1+0.1*i)*theta-(0.4+0.1*i)*phi))^2)^2'
  [../]
  [./cIC]
    type = ParsedFunction
    vars = 'c0 epsl_sphere theta phi'
    vals = '0.5 0.05 theta phi'
    value = 'c0+epsl_sphere*(cos(8*theta)*cos(15*phi)+(cos(12*theta)*cos(10*phi))^2
            +cos(2.5*theta-1.5*phi)*cos(7*theta-2*phi))'
  [../]
[]

[AuxVariables]
  [./f_density]   # Local energy density (eV/mol)
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./precipitate_indicator]
  [../]
[]

[AuxKernels]
  # Calculates the energy density by combining the local and gradient energies
  [./f_density]   # (eV/mol/nm^2)
    type = TotalFreeEnergy
    variable = f_density
    f_name = 'f_chem'
    kappa_names = 'kappa_c'
    interfacial_vars = c
    execute_on = 'initial TIMESTEP_END'
  [../]
  [./precipitate_indicator]
    type = ParsedAux
    variable = precipitate_indicator
    args = c
    function = if(c>0.4,1.0,0)
    execute_on = 'initial TIMESTEP_END'
  [../]
[]

[Materials]
  #[./coefficient]                  # Gradient energy coefficient (eV nm^2/mol)
    #type = GenericFunctionMaterial
    #prop_names = 'kappa_c'
    #prop_values = '5e-16*6.24150934e+18*1e-9/7.1e-6'
                  # kappa_c *eV_J*nm_m^2* d
    #prop_values = '2'
  #[../]
  [./constants]
    type = GenericConstantMaterial
    prop_names = 'M L kappa_c kappa_eta'
    prop_values = '5.0 5.0 3.0 3.0'
  [../]
  [./f_chem]           # Local free energy function (eV/mol)
    type = DerivativeParsedMaterial
    f_name = f_chem
    args = 'c eta_1 eta_2 eta_3 eta_4'
    constant_names = 'roh ca cb w alpha'
    constant_expressions = '1.41421356 0.3 0.7 1 5'
    function = 'roh*roh*(c-ca)^2*(1-eta_1^3*(6*eta_1^2-15*eta_1+10)-eta_2^3*(6*eta_2^2-15*eta_2+10)-eta_3^3*(6*eta_3^2-15*eta_3+10)-eta_4^3*(6*eta_4^2-15*eta_4+10))
                +roh*roh*(cb-c)^2*(eta_1^3*(6*eta_1^2-15*eta_1+10)+eta_2^3*(6*eta_2^2-15*eta_2+10)+eta_3^3*(6*eta_3^2-15*eta_3+10)+eta_4^3*(6*eta_4^2-15*eta_4+10))
                +w*((eta_1^2*(1-eta_1)^2+eta_2^2*(1-eta_2)^2+eta_3^2*(1-eta_3)^2+eta_4^2*(1-eta_4)^2)
                +alpha*2*(eta_1^2*eta_2^2+eta_1^2*eta_3^2+eta_1^2*eta_4^2+eta_2^2*eta_3^2+eta_2^2*eta_4^2+eta_3^2*eta_4^2))'
    derivative_order = 2
  [../]
[]

[Postprocessors]
  [./total_energy]          # Total free energy at each timestep
    type = ElementIntegralVariablePostprocessor
    variable = f_density
    execute_on = 'initial timestep_end'
  [../]
  [./volume_fraction]      # Fraction of surface devoted to precipitates
    type = ElementAverageValue
    variable = precipitate_indicator
    execute_on = 'initial timestep_end'
  [../]
  [./max_concentration]
    type = ElementExtremeValue
    variable = c
    value_type = max
    execute_on = 'initial timestep_end'
  [../]
  [./min_concentration]
    type = ElementExtremeValue
    variable = c
    value_type = min
    execute_on = 'initial timestep_end'
  [../]
  [./dt]
    type = TimestepSize
  [../]
[]

[Executioner]
  type = Transient
  solve_type = NEWTON
  #nl_abs_tol = 1e-11
  nl_rel_tol = 1e-08
  end_time = 1e+6
  #petsc_options_iname = '-pc_type -ksp_type'
  #petsc_options_value = 'bjacobi  gmres'
  # petsc_options_iname = '-pc_type -pc_hypre_type'
  # petsc_options_value = 'hypre  boomeramg'
   petsc_options_iname = '-pc_type -sub_pc_type'
   petsc_options_value = 'asm lu'
  [./TimeStepper]
    type = IterationAdaptiveDT
    dt = 0.01
    cutback_factor = 0.7
    growth_factor = 1.1
    optimal_iterations = 6
  [../]
  [./Adaptivity]
    max_h_level = 1
    initial_adaptivity = 1
    refine_fraction = 0.9
    coarsen_fraction = 0.1
  [../]
[]

[Outputs]
  exodus = true
  csv = true
[]
