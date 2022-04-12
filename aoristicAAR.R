library(aoristAAR)

# creating test data
my_settlements <- data.frame(
  start = c(-3800, -3750, -3500, -4000, -3800, -3800, -3550, -3750, -3800),
  end   = c(-3700, -3400, -3300, -3300, -3500, -3300, -3525, -3650, -3700),
  type = c("hillfort", "hillfort", "hillfort", "hillfort", "hillfort",
           "coastal settlement", "coastal settlement", "coastal settlement", "coastal settlement"),
  size = c(">2ha", "<2ha", ">2ha", ">2ha", "<2ha", ">2ha", "<2ha", ">2ha", "<2ha")
)
# counting number of occurences
method_number_time_series <- aorist(
  my_settlements,
  from = "start", to = "end",
  method = "number"
)
plot(method_number_time_series, type = "l")


# normalisation methods
method_weight_time_series <- aorist(
  my_settlements,
  from = "start", to = "end",
  method = "weight"
)
method_period_correction_time_series <- aorist(
  my_settlements,
  from = "start", to = "end",
  method = "period_correction"
)

plot(method_weight_time_series, type = "l", col = "blue", xlim = c(-4100, -3200))
lines(method_period_correction_time_series, type = "l", col = "red", lty = 2)
legend(
  -4100, 0.05, legend = c("weight", "period_correction"),
  col = c("blue", "red"), lty = 1:2, cex = 0.8
)

# splitting time series by additional variables
splitted_time_series <- aorist(
  my_settlements,
  from = "start", to = "end",
  split_vars = c("type"),
  method = "period_correction"
)

hamlets <- splitted_time_series[splitted_time_series$type == "coastal settlement", c(1,2)]
hillforts <- splitted_time_series[splitted_time_series$type == "hillfort", c(1,2)]

plot(hamlets, type = "l", col = "darkgreen", xlim = c(-4100, -3200))
lines(method_period_correction_time_series, type = "l", col = "orange", lty = 2)
legend(
  -4100, 0.04, legend = c("hamlets", "hillforts"),
  col = c("darkgreen", "orange"), lty = 1, cex = 0.8
)
