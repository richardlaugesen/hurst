var documenterSearchIndex = {"docs": [

{
    "location": "#",
    "page": "Hurst Documentation",
    "title": "Hurst Documentation",
    "category": "page",
    "text": ""
},

{
    "location": "#Hurst-Documentation-1",
    "page": "Hurst Documentation",
    "title": "Hurst Documentation",
    "category": "section",
    "text": ""
},

{
    "location": "#Index-1",
    "page": "Hurst Documentation",
    "title": "Index",
    "category": "section",
    "text": ""
},

{
    "location": "#Hurst.GR4J.gr4j_init_state-Tuple{Any}",
    "page": "Hurst Documentation",
    "title": "Hurst.GR4J.gr4j_init_state",
    "category": "method",
    "text": "gr4j_init_state(pars)\n\nReturn a Dictionary containing an initial state for GR4J model. Uses a standard method derived from a set of model parmaters, pars.\n\nThe pars argument should have keys defined by the gr4j_params_from_array(arr) function.\n\nEssential input for the first call to gr4j_run_step function to ensure the unit hydrograph arrays are initialised to the correct size and ordinates are specified correctly.\n\nSee also: gr4j_params_from_array(arr), gr4j_run_step(rain, pet, state, pars)\n\n\n\n\n\n"
},

{
    "location": "#Hurst.GR4J.gr4j_params_default-Tuple{}",
    "page": "Hurst Documentation",
    "title": "Hurst.GR4J.gr4j_params_default",
    "category": "method",
    "text": "gr4j_params_default()\n\nReturns a Dictionary containing a reasonable set of GR4J parameter vaues with keys defined by the gr4j_params_from_array(arr) function and ready to be used by the gr4j_run_step function.\n\nSee also: gr4j_params_from_array(arr), gr4j_run_step(rain, pet, state, pars)\n\n\n\n\n\n"
},

{
    "location": "#Hurst.GR4J.gr4j_params_from_array-Tuple{Any}",
    "page": "Hurst Documentation",
    "title": "Hurst.GR4J.gr4j_params_from_array",
    "category": "method",
    "text": "gr4j_params_from_array(arr)\n\nReturns a Dictionary containing a parameter set ready to be used by the gr4j_run_step function.\n\nSets the value of the :x1, :x2, :x3 and :x4 keys to the 1st, 2nd, 3rd and 4th index values of the arr array.\n\nIntentionally does not check if these parameter values are within any acceptable range.\n\nSee also: gr4j_params_to_array(pars), gr4j_params_range(), gr4j_run_step(rain, pet, state, pars)\n\n\n\n\n\n"
},

{
    "location": "#Hurst.GR4J.gr4j_params_random-Tuple{Any}",
    "page": "Hurst Documentation",
    "title": "Hurst.GR4J.gr4j_params_random",
    "category": "method",
    "text": "gr4j_params_random(prange)\n\nReturns a Dictionary containing a random set of GR4J parameter vaues selected with a uniform sampler within the parameter ranges specified by prange.\n\nThe prange argument should be a Dictionary with keys defined by the gr4j_params_range() function.\n\nThis set of random parameters has keys defined by the gr4j_params_from_array(arr) function and is ready to be used by the gr4j_run_step function.\n\nSee also: gr4j_params_from_array(arr), gr4j_run_step(rain, pet, state, pars), gr4j_params_range()\n\n\n\n\n\n"
},

{
    "location": "#Hurst.GR4J.gr4j_params_range-Tuple{}",
    "page": "Hurst Documentation",
    "title": "Hurst.GR4J.gr4j_params_range",
    "category": "method",
    "text": "gr4j_params_range()\n\nReturns a Dictionary with reasonable ranges for GR4J parameter vaues.\n\nThese are used in the model calibration and random parameter sampling functions.\n\nSee also: gr4j_params_from_array(arr), gr4j_run_step(rain, pet, state, pars), gr4j_params_random(prange)\n\n\n\n\n\n"
},

{
    "location": "#Hurst.GR4J.gr4j_params_range_to_tuples-Tuple{Any}",
    "page": "Hurst Documentation",
    "title": "Hurst.GR4J.gr4j_params_range_to_tuples",
    "category": "method",
    "text": "gr4j_params_range_to_tuples(prange)\n\nReturns an array of tuples containing the GR4J parameter ranges provided in the prange Dictionary argument. This Dictionary should contain the keys defined by the gr4j_params_range function.\n\nSee also: gr4j_params_range()\n\n\n\n\n\n"
},

{
    "location": "#Hurst.GR4J.gr4j_params_range_trans-Tuple{Any}",
    "page": "Hurst Documentation",
    "title": "Hurst.GR4J.gr4j_params_range_trans",
    "category": "method",
    "text": "gr4j_params_range_trans(prange)\n\nReturns a Dictionary with reasonable ranges for GR4J parameter vaues which have been transformed using the method defined in the gr4j_param_trans function.\n\nSee also: gr4j_params_range(), gr4j_run_step(rain, pet, state, pars), gr4j_params_random(prange)\n\n\n\n\n\n"
},

{
    "location": "#Hurst.GR4J.gr4j_params_to_array-Tuple{Any}",
    "page": "Hurst Documentation",
    "title": "Hurst.GR4J.gr4j_params_to_array",
    "category": "method",
    "text": "gr4j_params_to_array(pars)\n\nReturns an array containing GR4J parameter vaues from a parameter Dictionary with keys defined by the gr4j_params_from_array(arr) function.\n\nSets the 1st, 2nd, 3rd and 4th index values of the returned array to the value of the :x1, :x2, :x3 and :x4 keys in the pars Dictionary.\n\nIntentionally does not check if these parameter values are within any acceptable range.\n\nSee also: gr4j_params_from_array(arr), gr4j_params_range()\n\n\n\n\n\n"
},

{
    "location": "#Hurst.GR4J.gr4j_params_trans-Tuple{Any}",
    "page": "Hurst Documentation",
    "title": "Hurst.GR4J.gr4j_params_trans",
    "category": "method",
    "text": "gr4j_params_trans(pars)\n\nReturns a set of GR4J parameters which has been transformed using standard practice for a more uniform parameter search space to calibrate within.\n\nThe pars Dictionary should correspond to the that generated by the gr4j_params_from_array function.\n\nSee also: gr4j_params_trans_inv(pars), gr4j_params_from_array(arr)\n\n\n\n\n\n"
},

{
    "location": "#Hurst.GR4J.gr4j_params_trans_inv-Tuple{Any}",
    "page": "Hurst Documentation",
    "title": "Hurst.GR4J.gr4j_params_trans_inv",
    "category": "method",
    "text": "gr4j_params_trans_inv(pars)\n\nReturns a set of transformed GR4J parameters pars which have been back-transformed. The back-transformation performed is the inverse of the transformations used in the function gr4j_params_trans.\n\nThe pars Dictionary should correspond to the that generated by the gr4j_params_from_array function.\n\nSee also: gr4j_params_trans(pars), gr4j_params_from_array(arr)\n\n\n\n\n\n"
},

{
    "location": "#Hurst.GR4J.gr4j_run_step-NTuple{4,Any}",
    "page": "Hurst Documentation",
    "title": "Hurst.GR4J.gr4j_run_step",
    "category": "method",
    "text": "gr4j_run_step(rain, pet, state, pars)\n\nRun a single time-step of the GR4J model. Model is forced by the rain and pet (floats) supplied and uses the state for initial conditions. Model parameters used are provided in the pars argument.\n\nThe pars argument should have keys defined by the gr4j_params_from_array(arr) function and the state with keys defined by gr4j_init_state(pars).\n\nThe function then returns the runoff and an updated state. This updated state is typically used as the input state for the next time-step in a time-series simulation.\n\nSee also: gr4j_init_state(pars), gr4j_params_from_array(arr)\n\n\n\n\n\n"
},

{
    "location": "#Hurst.GR4J.create_uh_ordinates-Tuple{Any,Any,Any}",
    "page": "Hurst Documentation",
    "title": "Hurst.GR4J.create_uh_ordinates",
    "category": "method",
    "text": "create_uh_ordinates(variant, size, x4)\n\nReturns an Array of size elements containing the GR4J unit hydrograph ordinates for either of the two variant parameterised by the x4 parameter.\n\nUses the s_curve function to determine the ordinate values and is used by the gr4j_init_state function to create an initial state for GR4J, specifically defining the unit hydrograph ordinate values used when updating the unit hydrographs each time-step in the gr4j_run_step function.\n\nSee also: s_curve(variant, scale, x), gr4j_init_state(pars), gr4j_run_step(rain, pet, state, pars)\n\n\n\n\n\n"
},

{
    "location": "#Hurst.GR4J.gr4j_param_trans-Tuple{Any,Any}",
    "page": "Hurst Documentation",
    "title": "Hurst.GR4J.gr4j_param_trans",
    "category": "method",
    "text": "gr4j_param_trans(param, value)\n\nReturns the value of a single GR4J parameter which has been transformed using standard practice for a more uniform parameter search space to calibrate within.\n\nThe param Symbol should correspond to a key in the Dictionary returned by the gr4j_params_from_array function.\n\nSee also: gr4j_param_trans_inv(param, value), gr4j_params_from_array(arr), gr4j_params_trans(pars)\n\n\n\n\n\n"
},

{
    "location": "#Hurst.GR4J.gr4j_param_trans_inv-Tuple{Any,Any}",
    "page": "Hurst Documentation",
    "title": "Hurst.GR4J.gr4j_param_trans_inv",
    "category": "method",
    "text": "gr4j_param_trans_inv(param, value)\n\nReturns a single transformed GR4J parameter value which has been back-transformed. The back-transformation performed is the inverse of the transformations defined in the function gr4j_param_trans.\n\nThe param Symbol should correspond to a key in the Dictionary returned by the gr4j_params_from_array function.\n\nSee also: [gr4j_param_trans(param, value), [gr4jparamsfromarray(arr)](@ref), [gr4jparam_trans(param, value)`](@ref)\n\n\n\n\n\n"
},

{
    "location": "#Hurst.GR4J.s_curve-Tuple{Any,Any,Any}",
    "page": "Hurst Documentation",
    "title": "Hurst.GR4J.s_curve",
    "category": "method",
    "text": "s_curve(variant, scale, x)\n\nReturns the value at location x of a variant of an s-curve function parameterised with a scale.\n\nIs used to define the values of the GR4J unit hydrograph ordinates in the function create_uh_ordinates.\n\nSee also: create_uh_ordinates(variant, size, x4), gr4j_run_step(rain, pet, state, pars)\n\n\n\n\n\n"
},

{
    "location": "#Hurst.GR4J.update_uh-Tuple{Any,Any,Any}",
    "page": "Hurst Documentation",
    "title": "Hurst.GR4J.update_uh",
    "category": "method",
    "text": "update_uh(uh, volume, ordinates)\n\nReturns an updated unit hydrograph Array after incrementing the uh and convoluting with the ordinates and volume.\n\nThe ordinates are defined by the create_uh_ordinates function.\n\nUsed by the gr4j_run_step function when updating the model state, specifically the two GR4J unit hydrographs.\n\nSee also: create_uh_ordinates(variant, size, x4), gr4j_run_step(rain, pet, state, pars)\n\n\n\n\n\n"
},

{
    "location": "#Hurst.GR4J-1",
    "page": "Hurst Documentation",
    "title": "Hurst.GR4J",
    "category": "section",
    "text": "Modules = [Hurst.GR4J]\nOrder   = [:function, :type]"
},

{
    "location": "#Hurst.OSTP.ostp_init_state-Tuple{Any}",
    "page": "Hurst Documentation",
    "title": "Hurst.OSTP.ostp_init_state",
    "category": "method",
    "text": "ostp_init_state(pars)\n\nReturn a Dictionary containing an initial state for ostp model. Uses a standard method derived from a set of model parmaters, pars.\n\nThe pars argument should have keys defined by the ostp_params_from_array(arr) function.\n\nSee also: ostp_params_from_array(arr), ostp_run_step(rain, pet, state, pars)\n\n\n\n\n\n"
},

{
    "location": "#Hurst.OSTP.ostp_params_default-Tuple{}",
    "page": "Hurst Documentation",
    "title": "Hurst.OSTP.ostp_params_default",
    "category": "method",
    "text": "ostp_params_default()\n\nReturns a Dictionary containing a reasonable set of ostp parameter vaues with keys defined by the ostp_params_from_array(arr) function and ready to be used by the ostp_run_step function.\n\nSee also: ostp_params_from_array(arr), ostp_run_step(rain, pet, state, pars)\n\n\n\n\n\n"
},

{
    "location": "#Hurst.OSTP.ostp_params_from_array-Tuple{Any}",
    "page": "Hurst Documentation",
    "title": "Hurst.OSTP.ostp_params_from_array",
    "category": "method",
    "text": "ostp_params_from_array(arr)\n\nReturns a Dictionary containing a parameter set ready to be used by the ostp_run_step function.\n\nSets the value of the :capacity, :loss keys to the 1st and 2nd index values of the arr array.\n\nIntentionally does not check if these parameter values are within any acceptable range.\n\nSee also: ostp_params_to_array(pars), ostp_params_range(), ostp_run_step(rain, pet, state, pars)\n\n\n\n\n\n"
},

{
    "location": "#Hurst.OSTP.ostp_params_random-Tuple{Any}",
    "page": "Hurst Documentation",
    "title": "Hurst.OSTP.ostp_params_random",
    "category": "method",
    "text": "ostp_params_random(prange)\n\nReturns a Dictionary containing a random set of ostp parameter vaues selected with a uniform sampler within the parameter ranges specified by prange.\n\nThe prange argument should be a Dictionary with keys defined by the ostp_params_range() function.\n\nThis set of random parameters has keys defined by the ostp_params_from_array(arr) function and is ready to be used by the ostp_run_step function.\n\nSee also: ostp_params_from_array(arr), ostp_run_step(rain, pet, state, pars), ostp_params_range()\n\n\n\n\n\n"
},

{
    "location": "#Hurst.OSTP.ostp_params_range-Tuple{}",
    "page": "Hurst Documentation",
    "title": "Hurst.OSTP.ostp_params_range",
    "category": "method",
    "text": "ostp_params_range()\n\nReturns a Dictionary with reasonable ranges for ostp parameter vaues.\n\nThese are used in the model calibration and random parameter sampling functions.\n\nSee also: ostp_params_from_array(arr), ostp_run_step(rain, pet, state, pars), ostp_params_random(prange)\n\n\n\n\n\n"
},

{
    "location": "#Hurst.OSTP.ostp_params_range_to_tuples-Tuple{Any}",
    "page": "Hurst Documentation",
    "title": "Hurst.OSTP.ostp_params_range_to_tuples",
    "category": "method",
    "text": "ostp_params_range_to_tuples(prange)\n\nReturns an array of tuples containing the ostp parameter ranges provided in the prange Dictionary argument. This Dictionary should contain the keys defined by the ostp_params_range function.\n\nSee also: ostp_params_range()\n\n\n\n\n\n"
},

{
    "location": "#Hurst.OSTP.ostp_params_to_array-Tuple{Any}",
    "page": "Hurst Documentation",
    "title": "Hurst.OSTP.ostp_params_to_array",
    "category": "method",
    "text": "ostp_params_to_array(pars)\n\nReturns an array containing ostp parameter vaues from a parameter Dictionary with keys defined by the ostp_params_from_array(arr) function.\n\nSets the 1st and 2nd index values of the returned array to the value of the :capacity and :loss keys in the pars Dictionary.\n\nIntentionally does not check if these parameter values are within any acceptable range.\n\nSee also: ostp_params_from_array(arr), ostp_params_range()\n\n\n\n\n\n"
},

{
    "location": "#Hurst.OSTP.ostp_run_step-NTuple{4,Any}",
    "page": "Hurst Documentation",
    "title": "Hurst.OSTP.ostp_run_step",
    "category": "method",
    "text": "ostp_run_step(rain, pet, state, pars)\n\nRun a single time-step of the ostp model. ostp a simple one storage, two parameter model used for educational purposes. To outline basic concepts in conceptual rainfall-runoff models and how to implement a rainfall-runoff model within Hurst. Please do not use it for actual water resource modelling!\n\nThe model is forced by the rain and pet (floats) supplied and uses the state for initial conditions. Model parameters used are provided in the pars argument.\n\nThe pars argument should have keys defined by the ostp_params_from_array(arr) function and the state with keys defined by ostp_init_state(pars).\n\nThe function then returns the runoff and an updated state. This updated state is typically used as the input state for the next time-step in a time-series simulation.\n\nSee also: ostp_init_state(pars), ostp_params_from_array(arr)\n\n\n\n\n\n"
},

{
    "location": "#Hurst.OSTP-1",
    "page": "Hurst Documentation",
    "title": "Hurst.OSTP",
    "category": "section",
    "text": "Modules = [Hurst.OSTP]\nOrder   = [:function, :type]"
},

{
    "location": "#Hurst.Simulation.simulate-NTuple{5,Any}",
    "page": "Hurst Documentation",
    "title": "Hurst.Simulation.simulate",
    "category": "method",
    "text": "simulate(timestep_fnc, rain, pet, pars, init_state)\n\nReturns a runoff simulation by forcing a rainfall-runoff model with the rain and pet timeseries.\n\nThe rainfall-runoff model is defined by the timestep_fnc function and pars model parameters Dictionary. This function is expected to return runoff for a single timestep of rain and pet. The model will be initalised with the init_state initial state Dictionary.\n\nWill error if the rain and pet arrays are different lengths.\n\n\n\n\n\n"
},

{
    "location": "#Hurst.Simulation-1",
    "page": "Hurst Documentation",
    "title": "Hurst.Simulation",
    "category": "section",
    "text": "Modules = [Hurst.Simulation]\nOrder   = [:function, :type]"
},

{
    "location": "#Hurst.Calibration.calibrate-NTuple{5,Any}",
    "page": "Hurst Documentation",
    "title": "Hurst.Calibration.calibrate",
    "category": "method",
    "text": "calibrate(rain, pet, runoff, functions, opt_options)\n\nAttempts to minimise an objective function between the runoff and a simulation from a rainfall-runoff model forced by rain and pet.\n\nReturns an optimal set of parameters and the associated objective function value.\n\nWill error if the rain, pet and runoff arrays are different lengths.\n\nFunctions to define the model and parameters are defined in the functions Dictionary. Refer to example to understand meaning.\n\nfunctions[:run_model_time_step]\nfunctions[:init_state]\nfunctions[:params_from_array]\nfunctions[:objective_function]\nfunctions[:params_inverse_transform]\nfunctions[:params_range_transform]\nfunctions[:params_range_to_tuples]\nfunctions[:params_range]\n\nIf the :params_inverse_transform key is defined in the functions Dictionary then it will assume the optimisation is in transformed space and will attempt to transform and detransform paramter sets and ranges. Will error if ALL the required transformation-related Dictionary keys are not defined.\n\nCurrently uses the BlackBoxOptim.jl package for numerical optimisation and the following options may be specified in the opt_options Dictionary, detailed information can be found at BlackBoxOptim.jl options:\n\nopt_options[:method]\nopt_options[:max_iterations]\nopt_options[:max_time]\nopt_options[:trace_interval]\nopt_options[:trace_mode])\n\nA typical set of function and opt_options to run a 5 minute calibration using the GR4J model in transformed paramter space with the Nash Sutcliffe Efficiency objective function could be:\n\n# build up dictionary of model functions needed for calibration\nfunctions = Dict()\nfunctions[:run_model_time_step] = gr4j_run_step\nfunctions[:init_state] = gr4j_init_state\nfunctions[:params_from_array] = gr4j_params_from_array\nfunctions[:objective_function] = (obs, sim) -> -1 * nse(obs, sim)\nfunctions[:params_inverse_transform] = gr4j_params_trans_inv\nfunctions[:params_range_transform] = gr4j_params_range_trans\nfunctions[:params_range_to_tuples] = gr4j_params_range_to_tuples\nfunctions[:params_range] = gr4j_params_range\n\n# build up dictionary of optimiser options needed for calibration\nopt_options = Dict()\nopt_options[:max_iterations] = false\nopt_options[:max_time] = 5 * 60\nopt_options[:trace_interval] = 15\nopt_options[:trace_mode] = :verbose\nopt_options[:method] = :adaptive_de_rand_1_bin_radiuslimited\n\n# calibrate the model\nopt_pars, opt_neg_nse = calibrate(data[:rain], data[:pet], data[:runoff_obs], functions, opt_options)\nopt_nse = -1 * opt_neg_nse\n\nSee also: simulate(timestep_fnc, rain, pet, pars, init_state)\n\n\n\n\n\n"
},

{
    "location": "#Hurst.Calibration-1",
    "page": "Hurst Documentation",
    "title": "Hurst.Calibration",
    "category": "section",
    "text": "Modules = [Hurst.Calibration]\nOrder   = [:function, :type]"
},

{
    "location": "#Hurst.Transformations.boxcox-Tuple{Any,Any,Any}",
    "page": "Hurst Documentation",
    "title": "Hurst.Transformations.boxcox",
    "category": "method",
    "text": "boxcox(y, λ, ν)\n\nTwo param box-cox transform. (Wikipedia)\n\nBox, G. E. P., and D. R. Cox (1964), An analysis of transformations, J. R. Stat. Soc., Ser. B, 26, 296–311.\n\nSee also: boxcox_inverse(z, λ, ν)\n\n\n\n\n\n"
},

{
    "location": "#Hurst.Transformations.boxcox-Tuple{Any,Any}",
    "page": "Hurst Documentation",
    "title": "Hurst.Transformations.boxcox",
    "category": "method",
    "text": "boxcox(y, λ)\n\nOne param box-cox transform. (Wikipedia)\n\nBox, G. E. P., and D. R. Cox (1964), An analysis of transformations, J. R. Stat. Soc., Ser. B, 26, 296–311.\n\nSee also: boxcox_inverse(z, λ)\n\n\n\n\n\n"
},

{
    "location": "#Hurst.Transformations.boxcox_inverse-Tuple{Any,Any,Any}",
    "page": "Hurst Documentation",
    "title": "Hurst.Transformations.boxcox_inverse",
    "category": "method",
    "text": "boxcox_inverse(z, λ, ν)\n\nInverse of the two param box-cox transform. (Wikipedia)\n\nBox, G. E. P., and D. R. Cox (1964), An analysis of transformations, J. R. Stat. Soc., Ser. B, 26, 296–311.\n\nSee also: boxcox(y, λ, ν)\n\n\n\n\n\n"
},

{
    "location": "#Hurst.Transformations.boxcox_inverse-Tuple{Any,Any}",
    "page": "Hurst Documentation",
    "title": "Hurst.Transformations.boxcox_inverse",
    "category": "method",
    "text": "boxcox_inverse(z, λ)\n\nInverse of the one param box-cox transform. (Wikipedia)\n\nBox, G. E. P., and D. R. Cox (1964), An analysis of transformations, J. R. Stat. Soc., Ser. B, 26, 296–311.\n\nSee also: boxcox(y, λ)\n\n\n\n\n\n"
},

{
    "location": "#Hurst.Transformations.log_sinh-Tuple{Any,Any,Any}",
    "page": "Hurst Documentation",
    "title": "Hurst.Transformations.log_sinh",
    "category": "method",
    "text": "log_sinh(y, a, b)\n\nLog-sinh transform.\n\nWang, Q. J., D. L. Shrestha, D. E. Robertson, and P. Pokhrel (2012b), A log-sinh transformation for data normalization and variance stabiliza- tion, Water Resour. Res., 48, W05514, doi:10.1029/2011WR010973.\n\nSee also: log_sinh_inverse(z, a, b)\n\n\n\n\n\n"
},

{
    "location": "#Hurst.Transformations.log_sinh_inverse-Tuple{Any,Any,Any}",
    "page": "Hurst Documentation",
    "title": "Hurst.Transformations.log_sinh_inverse",
    "category": "method",
    "text": "log_sinh_inverse(z, a, b)\n\nInverse of the log-sinh transform.\n\nWang, Q. J., D. L. Shrestha, D. E. Robertson, and P. Pokhrel (2012b), A log-sinh transformation for data normalization and variance stabiliza- tion, Water Resour. Res., 48, W05514, doi:10.1029/2011WR010973.\n\nSee also: log_sinh(y, a, b)\n\n\n\n\n\n"
},

{
    "location": "#Hurst.Transformations.log_trans-Tuple{Any,Any}",
    "page": "Hurst Documentation",
    "title": "Hurst.Transformations.log_trans",
    "category": "method",
    "text": "log_trans(y, offset)\n\nLog transform with offset. (Wikipedia)\n\nSee also: log_trans_inverse(z, offset)\n\n\n\n\n\n"
},

{
    "location": "#Hurst.Transformations.log_trans-Tuple{Any}",
    "page": "Hurst Documentation",
    "title": "Hurst.Transformations.log_trans",
    "category": "method",
    "text": "log_trans(y)\n\nLog transform with no offset. (Wikipedia)\n\nSee also: log_trans_inverse(z)\n\n\n\n\n\n"
},

{
    "location": "#Hurst.Transformations.log_trans_inverse-Tuple{Any,Any}",
    "page": "Hurst Documentation",
    "title": "Hurst.Transformations.log_trans_inverse",
    "category": "method",
    "text": "log_trans_inverse(z, offset)\n\nInverse log transform with offset. (Wikipedia)\n\nSee also: log_trans(y, offset)\n\n\n\n\n\n"
},

{
    "location": "#Hurst.Transformations.log_trans_inverse-Tuple{Any}",
    "page": "Hurst Documentation",
    "title": "Hurst.Transformations.log_trans_inverse",
    "category": "method",
    "text": "log_trans_inverse(z)\n\nInverse log transform with no offset. (Wikipedia)\n\nSee also: log_trans(y)\n\n\n\n\n\n"
},

{
    "location": "#Hurst.Transformations-1",
    "page": "Hurst Documentation",
    "title": "Hurst.Transformations",
    "category": "section",
    "text": "Modules = [Hurst.Transformations]\nOrder   = [:function, :type]"
},

{
    "location": "#Hurst.Visualisations.hydrograph-Tuple{Any,Any,Any}",
    "page": "Hurst Documentation",
    "title": "Hurst.Visualisations.hydrograph",
    "category": "method",
    "text": "hydrograph(rain, runoffs, runoff_labels)\n\nGenerates a simple combined hydrograph and hyetograph figure.\n\nMultiple traces of runoff may be plotted by passing an array of arrays for runoff and associated runoff_labels.\n\nDatetime tick marks are not plotted, only timesteps.\n\n\n\n\n\n"
},

{
    "location": "#Hurst.Visualisations.hyscatter-NTuple{5,Any}",
    "page": "Hurst Documentation",
    "title": "Hurst.Visualisations.hyscatter",
    "category": "method",
    "text": "hyscatter(obs, sim, sim_labels)\n\nGenerates a simple scatter plot of simulation series sims against an observation series obs.\n\nMultiple scatters may be plotted by passing an array of arrays for sims and associated sim_labels.\n\nInclude a plot title, series sim_labels, and measurement units for the axis.\n\n\n\n\n\n"
},

{
    "location": "#Hurst.Visualisations-1",
    "page": "Hurst Documentation",
    "title": "Hurst.Visualisations",
    "category": "section",
    "text": "Modules = [Hurst.Visualisations]\nOrder   = [:function, :type]"
},

{
    "location": "#Hurst.Units.acres_to_km2-Tuple{Any}",
    "page": "Hurst Documentation",
    "title": "Hurst.Units.acres_to_km2",
    "category": "method",
    "text": "acres_to_km2(a)\n\nConvert an area in acres to an area in square kilometres.\n\nSee also: km2_to_acres(a)\n\n\n\n\n\n"
},

{
    "location": "#Hurst.Units.cumecs_to_megalitres_day-Tuple{Any}",
    "page": "Hurst Documentation",
    "title": "Hurst.Units.cumecs_to_megalitres_day",
    "category": "method",
    "text": "cumecs_to_megalitres_day(q)\n\nConvert cubic metres per second of streamflow q into megalitres per day of volume.\n\nSee also: megalitres_day_to_cumecs(v)\n\n\n\n\n\n"
},

{
    "location": "#Hurst.Units.km2_to_acres-Tuple{Any}",
    "page": "Hurst Documentation",
    "title": "Hurst.Units.km2_to_acres",
    "category": "method",
    "text": "km2_to_acres(a)\n\nConvert an area in square kilometres to an area in acres.\n\nSee also: acres_to_km2(a)\n\n\n\n\n\n"
},

{
    "location": "#Hurst.Units.km2_to_m2-Tuple{Any}",
    "page": "Hurst Documentation",
    "title": "Hurst.Units.km2_to_m2",
    "category": "method",
    "text": "km2_to_m2(a)\n\nConvert an area in square kilometres to an area in square metres.\n\nSee also: m2_to_km2(a)\n\n\n\n\n\n"
},

{
    "location": "#Hurst.Units.m2_to_km2-Tuple{Any}",
    "page": "Hurst Documentation",
    "title": "Hurst.Units.m2_to_km2",
    "category": "method",
    "text": "m2_to_km2(a)\n\nConvert an area in square metres to an area in square kilometres.\n\nSee also: km2_to_m2(a)\n\n\n\n\n\n"
},

{
    "location": "#Hurst.Units.megalitres_day_to_cumecs-Tuple{Any}",
    "page": "Hurst Documentation",
    "title": "Hurst.Units.megalitres_day_to_cumecs",
    "category": "method",
    "text": "megalitres_day_to_cumecs(v)\n\nConvert megalitres per day of volume v into cubic metres per second of streamflow.\n\nSee also: cumecs_to_megalitres_day(q)\n\n\n\n\n\n"
},

{
    "location": "#Hurst.Units.megalitres_to_mm_runoff-Tuple{Any,Any}",
    "page": "Hurst Documentation",
    "title": "Hurst.Units.megalitres_to_mm_runoff",
    "category": "method",
    "text": "megalitres_to_mm_runoff(v, area)\n\nUse the catchment area (kilometres) to convert a volume v (megalitres) into catchment average runoff (millimetres).\n\nSee also: mm_runoff_to_megalitres(d, area)\n\n\n\n\n\n"
},

{
    "location": "#Hurst.Units.mm_runoff_to_megalitres-Tuple{Any,Any}",
    "page": "Hurst Documentation",
    "title": "Hurst.Units.mm_runoff_to_megalitres",
    "category": "method",
    "text": "mm_runoff_to_megalitres(d, area)\n\nUse the catchment area (kilometres) to convert a depth d of catchment average runoff (millimetres) into volume (megalitres).\n\nSee also: megalitres_to_mm_runoff(v, area)\n\n\n\n\n\n"
},

{
    "location": "#Hurst.Units-1",
    "page": "Hurst Documentation",
    "title": "Hurst.Units",
    "category": "section",
    "text": "Modules = [Hurst.Units]\nOrder   = [:function, :type]"
},

{
    "location": "#Hurst.Verification.coeff_det-Tuple{Any,Any}",
    "page": "Hurst Documentation",
    "title": "Hurst.Verification.coeff_det",
    "category": "method",
    "text": "coeff_det(y, f)\n\nReturns the Coefficient of Determination between y and f. Skips missing values from either series.\n\n\n\n\n\n"
},

{
    "location": "#Hurst.Verification.kge-Tuple{Any,Any,Any}",
    "page": "Hurst Documentation",
    "title": "Hurst.Verification.kge",
    "category": "method",
    "text": "kge(o, s, components)\n\nReturns the Kling-Gupta Efficiency between o and s. Skips missing values from either series.\n\nIf components is true then a Dictionary is returned containing the final KGE value (:kge) along with the individual components used to construct the KGE (:covariance, :relativevariability, :meanbias)\n\nSee also: kge(o, s)\n\n\n\n\n\n"
},

{
    "location": "#Hurst.Verification.kge-Tuple{Any,Any}",
    "page": "Hurst Documentation",
    "title": "Hurst.Verification.kge",
    "category": "method",
    "text": "kge(o, s)\n\nReturns the Kling-Gupta Efficiency between o and s. Skips missing values from either series.\n\nSee also: kge(o, s, components)\n\n\n\n\n\n"
},

{
    "location": "#Hurst.Verification.mae-Tuple{Any,Any}",
    "page": "Hurst Documentation",
    "title": "Hurst.Verification.mae",
    "category": "method",
    "text": "mae(o, s)\n\nReturns the Mean Absolute Error between o and s. Skips missing values from either series.\n\n\n\n\n\n"
},

{
    "location": "#Hurst.Verification.mse-Tuple{Any,Any}",
    "page": "Hurst Documentation",
    "title": "Hurst.Verification.mse",
    "category": "method",
    "text": "mse(o, s)\n\nReturns the Mean Square Error between o and s. Skips missing values from either series.\n\nSee also: rmse(o, s)\n\n\n\n\n\n"
},

{
    "location": "#Hurst.Verification.nse-Tuple{Any,Any}",
    "page": "Hurst Documentation",
    "title": "Hurst.Verification.nse",
    "category": "method",
    "text": "nse(obs, sim)\n\nReturns the Nash Sutcliffe Efficiency of obs and sim timeseries.\n\nSee also: coeff_det(y, f)\n\n\n\n\n\n"
},

{
    "location": "#Hurst.Verification.persistence-Tuple{Any,Any}",
    "page": "Hurst Documentation",
    "title": "Hurst.Verification.persistence",
    "category": "method",
    "text": "persistence(o, s)\n\nReturns the Persistence Index between o and s. Skips missing values from either series.\n\n\n\n\n\n"
},

{
    "location": "#Hurst.Verification.rmse-Tuple{Any,Any}",
    "page": "Hurst Documentation",
    "title": "Hurst.Verification.rmse",
    "category": "method",
    "text": "rmse(o, s)\n\nReturns the Root Mean Square Error between o and s.\n\nSee also: mse(o, s)\n\n\n\n\n\n"
},

{
    "location": "#Hurst.Verification-1",
    "page": "Hurst Documentation",
    "title": "Hurst.Verification",
    "category": "section",
    "text": "Modules = [Hurst.Verification]\nOrder   = [:function, :type]"
},

{
    "location": "#Hurst.Value.confusion-NTuple{4,Any}",
    "page": "Hurst Documentation",
    "title": "Hurst.Value.confusion",
    "category": "method",
    "text": "confusion(hits, misses, false_alarms, quiets)\n\nReturns a Dict containing fields of a confusion matrix with the various common names used for each combination of the 2x2 grid.\n\nSee also: confusion_scaled(hits, misses, false_alarms, quiets)\n\n\n\n\n\n"
},

{
    "location": "#Hurst.Value.confusion_scaled-NTuple{4,Any}",
    "page": "Hurst Documentation",
    "title": "Hurst.Value.confusion_scaled",
    "category": "method",
    "text": "confusion_scaled(hits, misses, false_alarms, quiets)\n\nReturns a Dict containing fields of a confusion matrix with the various common names used for each combination of the 2x2 grid scaled to be relative to the number of events and non-events (hits + misses + false_alarms + quiets).\n\nSee also: confusion(hits, misses, false_alarms, quiets)\n\n\n\n\n\n"
},

{
    "location": "#Hurst.Value.cost_loss-Tuple{Any,Any,Any}",
    "page": "Hurst Documentation",
    "title": "Hurst.Value.cost_loss",
    "category": "method",
    "text": "cost_loss(costs, losses, scaled_conf, method=\"verkade\")\n\nReturns the relative economic value of a forecast system using a the cost-loss model using the cost-loss ratio (costs, losses) and confusion matrix scaled by the total events and non-events scaled_conf.\n\nTwo methods are implemented (Verkade 2011 and Roulin 2007) which may be selected with the method argument (default is Verkade).\n\nVerkade, J. S., and M. G. F. Werner. “Estimating the Benefits of Single Value and Probability Forecasting for Flood Warning.” Hydrology and Earth System Sciences 15, no. 12 (December 20, 2011): 3751–65. https://doi.org/10.5194/hess-15-3751-2011.\n\nRoulin, E. “Skill and Relative Economic Value of Medium-Range Hydrological Ensemble Predictions.” Hydrology and Earth System Sciences 11, no. 2 (2007): 725–37. https://doi.org/10.5194/hess-11-725-2007.\n\nSee also: confusion_scaled(hits, misses, false_alarms, quiets), cost_loss_roulin(costs, losses, scaled_conf), cost_loss_verkade(costs, losses, scaled_conf)\n\n\n\n\n\n"
},

{
    "location": "#Hurst.Value.cost_loss_roulin-Tuple{Any,Any,Any}",
    "page": "Hurst Documentation",
    "title": "Hurst.Value.cost_loss_roulin",
    "category": "method",
    "text": "cost_loss_roulin(costs, losses, scaled_conf)\n\nReturns the relative economic value of a forecast system using a the cost-loss model using the cost-loss ratio (costs, losses) and confusion matrix scaled by the total events and non-events scaled_conf.\n\nRoulin, E. “Skill and Relative Economic Value of Medium-Range Hydrological Ensemble Predictions.” Hydrology and Earth System Sciences 11, no. 2 (2007): 725–37. https://doi.org/10.5194/hess-11-725-2007.\n\nSee also: confusion_scaled(hits, misses, false_alarms, quiets), cost_loss(costs, losses, scaled_conf, method), cost_loss_verkade(costs, losses, scaled_conf)\n\n\n\n\n\n"
},

{
    "location": "#Hurst.Value.cost_loss_verkade-Tuple{Any,Any,Any}",
    "page": "Hurst Documentation",
    "title": "Hurst.Value.cost_loss_verkade",
    "category": "method",
    "text": "cost_loss_verkade(costs, losses, scaled_conf)\n\nReturns the relative economic value of a forecast system using a the cost-loss model using the cost-loss ratio (costs, losses) and confusion matrix scaled by the total events and non-events scaled_conf.\n\nVerkade, J. S., and M. G. F. Werner. “Estimating the Benefits of Single Value and Probability Forecasting for Flood Warning.” Hydrology and Earth System Sciences 15, no. 12 (December 20, 2011): 3751–65. https://doi.org/10.5194/hess-15-3751-2011.\n\nSee also: confusion_scaled(hits, misses, false_alarms, quiets), cost_loss(costs, losses, scaled_conf, method), cost_loss_roulin(costs, losses, scaled_conf)\n\n\n\n\n\n"
},

{
    "location": "#Hurst.Value.kuipers_score-Tuple{Any}",
    "page": "Hurst Documentation",
    "title": "Hurst.Value.kuipers_score",
    "category": "method",
    "text": "kuipers_score(scaled_conf)\n\nReturns the Kuipers Score using the elements of the scaled_conf contingency table.\n\nRichardson, D. S. “Skill and Relative Economic Value of the ECMWF Ensemble Prediction System.” Quarterly Journal of the Royal Meteorological Society 126, no. 563 (January 2000): 649–67. https://doi.org/10.1256/smsqj.56312.\n\nSee also: confusion_scaled, cost_loss\n\n\n\n\n\n"
},

{
    "location": "#Hurst.Value-1",
    "page": "Hurst Documentation",
    "title": "Hurst.Value",
    "category": "section",
    "text": "Modules = [Hurst.Value]\nOrder   = [:function, :type]"
},

]}
