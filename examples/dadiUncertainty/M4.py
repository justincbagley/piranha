#!/usr/bin/env python

###  Long run for M4  ###

import matplotlib
matplotlib.use('PDF')
import dadi
import pylab
import matplotlib.pyplot as plt
import numpy as np
from numpy import array
from dadi import Misc,Spectrum,Numerics,PhiManip,Integration

## Read in the spectrum from easySFS and define sample sizes
data = dadi.Spectrum.from_file('LP-core-periphery_1per.sfs')
ns=data.sample_sizes

## Set grid space to explore the parameters
pts_1 = [200,220,240]

def SGFSC(params, ns, pts):
	nuLa, nuL, nuC, nuP, mA, mLP, mPL, T1, T2 = params
	"""
	3-population model with speciation with gene flow (symmetric ancestral migration), followed 
	by secondary contact (asymmetric migration) only between SWWP periphery and LP. Similar
	to M5 (SGF2SC).

	nuLa: Ancestral population size for pop 1, LP.
	nuL:  Current size of LP population, after split.
	nuC:  Current size of SWWP core population-lineage.
	nuP:  Current size of SWWP periphery population-lineage.
	mA:   Symmetric migration parameter, for ancestral migration during initial split.
	mLP:  Migration from SWWP periphery to LP.
	mPL:  Migration from LP to SWWP periphery.
	T1:   Divergence time for split between SWWP and LP species, defines interval between T1 and T2.
	T2:   Divergence time for split between SWWP lineages, defines interval between T2 and present.
	nuS:  Ancestral size for SWWP, a sum of current core and periphery sizes.
	ns:   Size of fs to generate.
	pts:  Number of points to use in grid for evaluation.
	"""
	xx = dadi.Numerics.default_grid(pts)
	phi = dadi.PhiManip.phi_1D(xx)
	phi = dadi.PhiManip.phi_1D_to_2D(xx,phi)
	nuS = nuC+nuP
	phi = dadi.Integration.two_pops(phi,xx,T1,nu1=nuLa,nu2=nuS,m12=mA,m21=mA)
	phi = dadi.PhiManip.phi_2D_to_3D_split_2(xx,phi)
	phi = dadi.Integration.three_pops(phi,xx,T2,nu1=nuL,nu2=nuC,nu3=nuP,m12=0,m21=0,m13=mLP,m31=mPL,m23=0,m32=0) ##
	fs = dadi.Spectrum.from_phi(phi,ns,(xx,xx,xx))
	return fs

func = SGFSC

## Setting parameter bounds and starting values
upper_bound = [1e2,1e2,1e2,1e2,15,15,15,0.035,0.01]
lower_bound = [1e-3,1e-3,1e-3,1e-3,1,1,1,0.000035,0.000035]
p0 = array([0.5,0.5,0.5,0.5,5,5,5,0.00175,0.00175])

## Run BFGS optimizer
p0 = dadi.Misc.perturb_params(p0, fold=1, upper_bound=upper_bound,lower_bound=lower_bound)
func_ex = dadi.Numerics.make_extrap_log_func(func)
popt = dadi.Inference.optimize_log(p0, data, func_ex, pts_1,lower_bound=lower_bound,upper_bound=upper_bound,verbose=len(p0), maxiter=25)

print('Best-fit parameters: {0}'.format(popt))

## Find the SFS based on the model and the optmized paramters
model = func_ex(popt, ns, pts_1)
ll_model = dadi.Inference.ll_multinom(model, data)
print('Maximum log composite likelihood: {0}'.format(ll_model))

theta = dadi.Inference.optimal_sfs_scaling(model, data)
print('Optimal value of theta: {0}'.format(theta))

## 3-D plotting
dadi.Plotting.plot_3d_comp_multinom(model, data, vmin=1, resid_range=3,pop_ids = ('LP','core','periphery'))
plt.savefig('M4_SGFSC_longRun.pdf')
