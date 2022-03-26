import pandas as pd
import matplotlib.pyplot as plt
import cmdstanpy
import arviz as az
import os
import iqplot
import numpy as np
import holoviews as hv
hv.extension('bokeh')
cmdstanpy.set_cmdstan_path('C:\\Users\\User\\Documents\\.cmdstan\\cmdstan-2.29.1')
import bokeh.io
bokeh.io.output_notebook()


# write model
# I'm not sure about beta parameters
os.chdir('E:\ALI\processing project\Bayesian_inference')
stan_code="""data {
  int<lower=0> N;
  real<lower=0> y[N];
}



parameters {
  real<lower=0> l;
  real theta_;
  real<lower=0> sigma;
  real<lower=0> zigma;
  real<lower=0, upper=1> w;
}


transformed parameters {
  real mu = log(l);;
}


model {
  theta_ ~ beta(1, 15);
  w ~ uniform(0,1);
  l ~ exponential(theta_);
  sigma ~ normal(0.0, 3.0);
  zigma ~ normal(0.0, 3.0);
  
  for (y_val in y) {
    target += log_mix(
      w,
      lognormal_lpdf(y_val | mu, sigma),
      lognormal_lpdf(y_val | 0.69314718, zigma)
    );
  }
}"""
with open("Barcode2.stan", "w") as f:
    f.write(stan_code)
sm = cmdstanpy.CmdStanModel(stan_file='Barcode2.stan')
# set the data set
df = pd.read_excel(os.path.join('E:\ALI\processing project\Bayesian_inference', 'Bayesian_data .xlsx'),header=None)
data = dict(N=len(df), y=df[0].values)
plt.hist(x=df[0].values,bins=14)

# markov chains
samples = sm.sample(
    data=data,
    chains=4,
    iter_sampling=1000
)
samples = az.from_cmdstanpy(posterior=samples)
# convert markov chains to dataframes
df_mcmc = samples.posterior.to_dataframe()

az.plot_density(
    samples, backend="bokeh", backend_kwargs=dict(frame_width=200, frame_height=150)
)

# ecdf plot
plots = [
    iqplot.ecdf(df_mcmc, q=param, plot_height=200, plot_width=250)
    for param in ["l","mu"]
]
bokeh.io.show(bokeh.layouts.gridplot(plots, ncols=2))

# pdf plot as histogram
plots = [
    iqplot.histogram(df_mcmc, q=param, plot_height=200, plot_width=250, rug=False)
    for param in ["l","mu"]
]
bokeh.io.show(bokeh.layouts.gridplot(plots, ncols=2))
