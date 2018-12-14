using Plots

function hydrograph(rain, runoffs, runoff_labels)
    p1 = plot(
            rain,         
            seriestype=:bar,
            ylabel="Rain (mm)", 
            legend=false, 
            grid=true,
            yflip=true,
            xaxis=false)

    p2 = plot(
            runoffs, 
            xlabel="Timestep", ylabel="Runoff (mm)", 
            label=runoff_labels,
            grid=true,
            lw=1.5)

    plot(
        p1, p2,
        layout=grid(2, 1, heights=[0.3, 0.7]),
        size=(900, 700))
end
