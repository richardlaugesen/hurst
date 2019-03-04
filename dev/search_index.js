var documenterSearchIndex = {"docs": [

{
    "location": "#",
    "page": "Hydro.jl Documentation",
    "title": "Hydro.jl Documentation",
    "category": "page",
    "text": ""
},

{
    "location": "#Hydro.jl-Documentation-1",
    "page": "Hydro.jl Documentation",
    "title": "Hydro.jl Documentation",
    "category": "section",
    "text": ""
},

{
    "location": "#Index-1",
    "page": "Hydro.jl Documentation",
    "title": "Index",
    "category": "section",
    "text": ""
},

{
    "location": "#Hydro.Simulation.simulate-NTuple{5,Any}",
    "page": "Hydro.jl Documentation",
    "title": "Hydro.Simulation.simulate",
    "category": "method",
    "text": "simulate(timestep_fnc, rain, pet, pars, init_state)\n\nReturns a runoff simulation by forcing a rainfall-runoff model with the rain and pet timeseries.\n\nThe rainfall-runoff model is defined by the timestep_fnc function and pars model parameters Dictionary. This function is expected to return runoff for a single timestep of rain and pet. The model will be initalised with the init_state initial state Dictionary.\n\nWill error if the rain and pet arrays are different lengths.\n\n\n\n\n\n"
},

{
    "location": "#Hydro.Simulation-1",
    "page": "Hydro.jl Documentation",
    "title": "Hydro.Simulation",
    "category": "section",
    "text": "Modules = [Hydro.Simulation]\nOrder   = [:function, :type]"
},

{
    "location": "#Hydro.Calibration.calibrate-NTuple{5,Any}",
    "page": "Hydro.jl Documentation",
    "title": "Hydro.Calibration.calibrate",
    "category": "method",
    "text": "calibrate(rain, pet, runoff, functions, opt_options)\n\nAttempts to minimise an objective function between the runoff and a simulation from a rainfall-runoff model forced by rain and pet.\n\nReturns an optimal set of parameters and the associated objective function value.\n\nWill error if the rain, pet and runoff arrays are different lengths.\n\nFunctions to define the model and parameters are defined in the functions Dictionary. Refer to example to understand meaning.\n\nfunctions[:run_model_time_step]\nfunctions[:init_state]\nfunctions[:params_from_array]\nfunctions[:objective_function]\nfunctions[:params_inverse_transform]\nfunctions[:params_range_transform]\nfunctions[:params_range_to_tuples]\nfunctions[:params_range]\n\nIf the :params_inverse_transform key is defined in the functions Dictionary then it will assume the optimisation is in transformed space and will attempt to transform and detransform paramter sets and ranges. Will error if ALL the required transformation-related Dictionary keys are not defined.\n\nCurrently uses the BlackBoxOptim.jl package for numerical optimisation and the following options may be specified in the opt_options Dictionary, detailed information can be found at BlackBoxOptim.jl options:\n\nopt_options[:method]\nopt_options[:max_iterations]\nopt_options[:max_time]\nopt_options[:trace_interval]\nopt_options[:trace_mode])\n\nA typical set of function and opt_options to run a 5 minute calibration using the GR4J model in transformed paramter space with the Nash Sutcliffe Efficiency objective function could be:\n\n# build up dictionary of model functions needed for calibration\nfunctions = Dict()\nfunctions[:run_model_time_step] = gr4j_run_step\nfunctions[:init_state] = gr4j_init_state\nfunctions[:params_from_array] = gr4j_params_from_array\nfunctions[:objective_function] = (obs, sim) -> -1 * nse(obs, sim)\nfunctions[:params_inverse_transform] = gr4j_params_trans_inv\nfunctions[:params_range_transform] = gr4j_params_range_trans\nfunctions[:params_range_to_tuples] = gr4j_params_range_to_tuples\nfunctions[:params_range] = gr4j_params_range\n\n# build up dictionary of optimiser options needed for calibration\nopt_options = Dict()\nopt_options[:max_iterations] = false\nopt_options[:max_time] = 5 * 60\nopt_options[:trace_interval] = 15\nopt_options[:trace_mode] = :verbose\nopt_options[:method] = :adaptive_de_rand_1_bin_radiuslimited\n\n# calibrate the model\nopt_pars, opt_neg_nse = calibrate(data[:rain], data[:pet], data[:runoff_obs], functions, opt_options)\nopt_nse = -1 * opt_neg_nse\n\nSee also: simulate(timestep_fnc, rain, pet, pars, init_state)\n\n\n\n\n\n"
},

{
    "location": "#Hydro.Calibration-1",
    "page": "Hydro.jl Documentation",
    "title": "Hydro.Calibration",
    "category": "section",
    "text": "Modules = [Hydro.Calibration]\nOrder   = [:function, :type]"
},

{
    "location": "#Hydro.Units.acres_to_km2-Tuple{Any}",
    "page": "Hydro.jl Documentation",
    "title": "Hydro.Units.acres_to_km2",
    "category": "method",
    "text": "acres_to_km2(a)\n\nConvert an area in acres to an area in square kilometres.\n\nSee also: km2_to_acres(a)\n\n\n\n\n\n"
},

{
    "location": "#Hydro.Units.cumecs_to_megalitres_day-Tuple{Any}",
    "page": "Hydro.jl Documentation",
    "title": "Hydro.Units.cumecs_to_megalitres_day",
    "category": "method",
    "text": "cumecs_to_megalitres_day(q)\n\nConvert cubic metres per second of streamflow q into megalitres per day of volume.\n\nSee also: megalitres_day_to_cumecs(v)\n\n\n\n\n\n"
},

{
    "location": "#Hydro.Units.km2_to_acres-Tuple{Any}",
    "page": "Hydro.jl Documentation",
    "title": "Hydro.Units.km2_to_acres",
    "category": "method",
    "text": "km2_to_acres(a)\n\nConvert an area in square kilometres to an area in acres.\n\nSee also: acres_to_km2(a)\n\n\n\n\n\n"
},

{
    "location": "#Hydro.Units.km2_to_m2-Tuple{Any}",
    "page": "Hydro.jl Documentation",
    "title": "Hydro.Units.km2_to_m2",
    "category": "method",
    "text": "km2_to_m2(a)\n\nConvert an area in square kilometres to an area in square metres.\n\nSee also: m2_to_km2(a)\n\n\n\n\n\n"
},

{
    "location": "#Hydro.Units.m2_to_km2-Tuple{Any}",
    "page": "Hydro.jl Documentation",
    "title": "Hydro.Units.m2_to_km2",
    "category": "method",
    "text": "m2_to_km2(a)\n\nConvert an area in square metres to an area in square kilometres.\n\nSee also: km2_to_m2(a)\n\n\n\n\n\n"
},

{
    "location": "#Hydro.Units.megalitres_day_to_cumecs-Tuple{Any}",
    "page": "Hydro.jl Documentation",
    "title": "Hydro.Units.megalitres_day_to_cumecs",
    "category": "method",
    "text": "megalitres_day_to_cumecs(v)\n\nConvert megalitres per day of volume v into cubic metres per second of streamflow.\n\nSee also: cumecs_to_megalitres_day(q)\n\n\n\n\n\n"
},

{
    "location": "#Hydro.Units.megalitres_to_mm_runoff-Tuple{Any,Any}",
    "page": "Hydro.jl Documentation",
    "title": "Hydro.Units.megalitres_to_mm_runoff",
    "category": "method",
    "text": "megalitres_to_mm_runoff(v, area)\n\nUse the catchment area (kilometres) to convert a volume v (megalitres) into catchment average runoff (millimetres).\n\nSee also: mm_runoff_to_megalitres(d, area)\n\n\n\n\n\n"
},

{
    "location": "#Hydro.Units.mm_runoff_to_megalitres-Tuple{Any,Any}",
    "page": "Hydro.jl Documentation",
    "title": "Hydro.Units.mm_runoff_to_megalitres",
    "category": "method",
    "text": "mm_runoff_to_megalitres(d, area)\n\nUse the catchment area (kilometres) to convert a depth d of catchment average runoff (millimetres) into volume (megalitres).\n\nSee also: megalitres_to_mm_runoff(v, area)\n\n\n\n\n\n"
},

{
    "location": "#Hydro.Units-1",
    "page": "Hydro.jl Documentation",
    "title": "Hydro.Units",
    "category": "section",
    "text": "Modules = [Hydro.Units]\nOrder   = [:function, :type]"
},

{
    "location": "#Hydro.Verification.coeff_det-Tuple{Any,Any}",
    "page": "Hydro.jl Documentation",
    "title": "Hydro.Verification.coeff_det",
    "category": "method",
    "text": "coeff_det(y, f)\n\nReturns the Coefficient of Determination between y and f. Skips missing values from either series.\n\n\n\n\n\n"
},

{
    "location": "#Hydro.Verification.kge-Tuple{Any,Any,Any}",
    "page": "Hydro.jl Documentation",
    "title": "Hydro.Verification.kge",
    "category": "method",
    "text": "kge(o, s, components)\n\nReturns the Kling-Gupta Efficiency between o and s. Skips missing values from either series.\n\nIf components is true then a Dictionary is returned containing the final KGE value (:kge) along with the individual components used to construct the KGE (:covariance, :relativevariability, :meanbias)\n\nSee also: kge(o, s)\n\n\n\n\n\n"
},

{
    "location": "#Hydro.Verification.kge-Tuple{Any,Any}",
    "page": "Hydro.jl Documentation",
    "title": "Hydro.Verification.kge",
    "category": "method",
    "text": "kge(o, s)\n\nReturns the Kling-Gupta Efficiency between o and s. Skips missing values from either series.\n\nSee also: kge(o, s, components)\n\n\n\n\n\n"
},

{
    "location": "#Hydro.Verification.mae-Tuple{Any,Any}",
    "page": "Hydro.jl Documentation",
    "title": "Hydro.Verification.mae",
    "category": "method",
    "text": "mae(o, s)\n\nReturns the Mean Absolute Error between o and s. Skips missing values from either series.\n\n\n\n\n\n"
},

{
    "location": "#Hydro.Verification.mse-Tuple{Any,Any}",
    "page": "Hydro.jl Documentation",
    "title": "Hydro.Verification.mse",
    "category": "method",
    "text": "mse(o, s)\n\nReturns the Mean Square Error between o and s. Skips missing values from either series.\n\nSee also: rmse(o, s)\n\n\n\n\n\n"
},

{
    "location": "#Hydro.Verification.nse-Tuple{Any,Any}",
    "page": "Hydro.jl Documentation",
    "title": "Hydro.Verification.nse",
    "category": "method",
    "text": "nse(obs, sim)\n\nReturns the Nash Sutcliffe Efficiency of obs and sim timeseries.\n\nSee also: coeff_det(y, f)\n\n\n\n\n\n"
},

{
    "location": "#Hydro.Verification.persistence-Tuple{Any,Any}",
    "page": "Hydro.jl Documentation",
    "title": "Hydro.Verification.persistence",
    "category": "method",
    "text": "persistence(o, s)\n\nReturns the Persistence Index between o and s. Skips missing values from either series.\n\n\n\n\n\n"
},

{
    "location": "#Hydro.Verification.rmse-Tuple{Any,Any}",
    "page": "Hydro.jl Documentation",
    "title": "Hydro.Verification.rmse",
    "category": "method",
    "text": "rmse(o, s)\n\nReturns the Root Mean Square Error between o and s.\n\nSee also: mse(o, s)\n\n\n\n\n\n"
},

{
    "location": "#Hydro.Verification-1",
    "page": "Hydro.jl Documentation",
    "title": "Hydro.Verification",
    "category": "section",
    "text": "Modules = [Hydro.Verification]\nOrder   = [:function, :type]"
},

]}
