import os
import sys
import numpy as np
from scipy.io import netcdf as nc
from matplotlib import pyplot as plt
from matplotlib.colors import BoundaryNorm
from matplotlib.ticker import MaxNLocator

############################################################
### Author: Ryan Knox
### Modified by: Shawn Serbin
############################################################

############################################################
### open the file and read in coordinate data
############################################################

##  get and open the history file
##  change the line below to point to the file that you've made,
##  which should be a concatenation of a bunch of FATES history files into a single file

#### usage e.g. "python2.7 plot_fates_structuredvariables.py ~/scratch/CLM5FATES_1552052278_1x1PASLZ/run/all_years.nc"
filename_in = sys.argv[1]
if os.path.exists(filename_in):
    print os.path.basename(filename_in)
fin = nc.netcdf_file(filename_in)

## read the coordinate data for the various dimensions
time = fin.variables['time'][:] / 365.  ### time dimension, put in unit of years
patch_age_bins = fin.variables['fates_levage'][:]
cohort_size_bins = fin.variables['fates_levscls'][:]

## define the sizes of each dimension
ntim = len(time)
nagebins = len(patch_age_bins)
nsizebins = len(cohort_size_bins)

## because the bin edges read in define the lower edges, add a last index to each to
## represent the upper edge of the distribution (even though there isn't one, really)
patch_age_bins = np.append(patch_age_bins,patch_age_bins[nagebins-1]*1.5)
cohort_size_bins = np.append(cohort_size_bins,cohort_size_bins[nsizebins-1]*1.5)

############################################################
### read in the various variables to visualize
############################################################

# productivity and canopy structure as a function of patch age
GPP_BY_AGE = fin.variables['GPP_BY_AGE'][:]  * 86400 * 365 ## change units from per second to per year
PATCH_AREA_BY_AGE = fin.variables['PATCH_AREA_BY_AGE'][:]
CANOPY_AREA_BY_AGE = fin.variables['CANOPY_AREA_BY_AGE'][:]

# population numbers and basal area as a functino of cohort size
BA_SCLS = fin.variables['BA_SCLS'][:]
NPLANT_CANOPY_SCLS = fin.variables['NPLANT_CANOPY_SCLS'][:]
NPLANT_UNDERSTORY_SCLS = fin.variables['NPLANT_UNDERSTORY_SCLS'][:]

# growth and mortality rates as a function of plant size
DDBH_CANOPY_SCLS = fin.variables['DDBH_CANOPY_SCLS'][:]
DDBH_UNDERSTORY_SCLS = fin.variables['DDBH_UNDERSTORY_SCLS'][:]
MORTALITY_CANOPY_SCLS = fin.variables['MORTALITY_CANOPY_SCLS'][:]
MORTALITY_UNDERSTORY_SCLS = fin.variables['MORTALITY_UNDERSTORY_SCLS'][:]

# close the file
fin.close()

############################################################
### first, look at the productivity and canopy structure
############################################################

# set up the page
fig1, (f1ax0, f1ax1, f1ax2) = plt.subplots(nrows=3, figsize=(7, 7))

## set up the first plot: the fractional area of patches of a given age range
levels = np.arange(0.,1.1, 0.1)
cmap = plt.get_cmap('Blues')
norm = BoundaryNorm(levels, ncolors=cmap.N, clip=True)
im = f1ax0.pcolormesh(time, patch_age_bins, PATCH_AREA_BY_AGE[:,:,0].transpose(), cmap=cmap, norm=norm)
fig1.colorbar(im, ax=f1ax0)
f1ax0.set_title(r'Patch Area by Age (m$^2$ patch m$^{-2}$ site)')
f1ax0.set_xlabel('Time (yr)')
f1ax0.set_ylabel('Patch Age (yr)')

## set up the second plot: the canopy coverage of patches of a given age (where 1 means canopy closure)
levels = np.arange(0.,2.1, 0.1)
cmap = plt.get_cmap('Greens')
norm = BoundaryNorm(levels, ncolors=cmap.N, clip=True)
im = f1ax1.pcolormesh(time, patch_age_bins, (CANOPY_AREA_BY_AGE / PATCH_AREA_BY_AGE)[:,:,0].transpose(), cmap=cmap, norm=norm)
fig1.colorbar(im, ax=f1ax1)
f1ax1.set_title(r'Canopy Area Index by Patch Age (m$^2$ canopy m$^{-2}$ patch)')
f1ax1.set_xlabel('Time (yr)')
f1ax1.set_ylabel('Patch Age (yr)')

## set up the third plot: the GPP, conditional on patch age
levels = np.arange(0.,2500, 100)
cmap = plt.get_cmap('Greens')
norm = BoundaryNorm(levels, ncolors=cmap.N, clip=True)
im = f1ax2.pcolormesh(time, patch_age_bins, (GPP_BY_AGE )[:,:,0].transpose(), cmap=cmap, norm=norm)
fig1.colorbar(im, ax=f1ax2)
f1ax2.set_title(r'GPP by Patch Age (g C m$^{-2}$ patch yr$^{-1}$)')
f1ax2.set_xlabel('Time (yr)')
f1ax2.set_ylabel('Patch Age (yr)')

# show the plot
fig1.tight_layout()
plt.show()

############################################################
### next, look at the evolution of the plant size structure
############################################################

# set up the page
fig2, ((f2ax0, f2ax1), (f2ax2, f2ax3)) = plt.subplots(nrows=2, ncols=2, figsize=(9, 7))

## set up the first plot: evolution of basal area of plants of a given size
levels = np.arange(0.,50, 1)
cmap = plt.get_cmap('Greens')
norm = BoundaryNorm(levels, ncolors=cmap.N, clip=True)
im = f2ax0.pcolormesh(time, cohort_size_bins, BA_SCLS[:,:,0].transpose(), cmap=cmap, norm=norm)
fig2.colorbar(im, ax=f2ax0)
f2ax0.set_title(r'Basal Area by Size (m$^2$ ha$^{-1}$)')
f2ax0.set_xlabel('Time (yr)')
f2ax0.set_ylabel('Cohort Size (cm)')

## set up the second plot: evolution of the population density of plants of a given size
# sum the canopy and understory plants to get size distribution of all plants
levels = np.array([0.1,0.3,1.,3.,10.,30., 100.,300.,1000., 3000., 10000.]) # do a pseudo-log scale here
cmap = plt.get_cmap('Greens')
norm = BoundaryNorm(levels, ncolors=cmap.N, clip=True)
im = f2ax1.pcolormesh(time, cohort_size_bins, (NPLANT_CANOPY_SCLS + NPLANT_UNDERSTORY_SCLS)[:,:,0].transpose(), cmap=cmap, norm=norm)
fig2.colorbar(im, ax=f2ax1)
f2ax1.set_title(r'# of plants by size (n ha$^{-1}$)')
f2ax1.set_xlabel('Time (yr)')
f2ax1.set_ylabel('Cohort Size (cm)')

## set up the third plot: evolution of the population density of canopy plants of a given size
# use same levels & colorbar as second plot above
im = f2ax2.pcolormesh(time, cohort_size_bins, (NPLANT_CANOPY_SCLS)[:,:,0].transpose(), cmap=cmap, norm=norm)
fig2.colorbar(im, ax=f2ax2)
f2ax2.set_title(r'# canopy plants by size (n ha$^{-1}$)')
f2ax2.set_xlabel('Time (yr)')
f2ax2.set_ylabel('Cohort Size (cm)')

## set up the fourth plot: evolution of the population density of understory plants of a given size
# use same levels & colorbar as second plot above
im = f2ax3.pcolormesh(time, cohort_size_bins, (NPLANT_UNDERSTORY_SCLS)[:,:,0].transpose(), cmap=cmap, norm=norm)
fig2.colorbar(im, ax=f2ax3)
f2ax3.set_title(r'# understory plants by size (n ha$^{-1}$)')
f2ax3.set_xlabel('Time (yr)')
f2ax3.set_ylabel('Cohort Size (cm)')

# show the plot
fig2.tight_layout()
plt.show()



############################################################
### next, look at the growth and mortality rates
### for all of these rates, you need to divide the rate by the population
### size in post-processing to get meaningful units
############################################################

# set up the page
fig3, ((f3ax0, f3ax1), (f3ax2, f3ax3)) = plt.subplots(nrows=2, ncols=2, figsize=(9, 7))

## set up the first plot: growth rate (in diameter increment) in the canopy
levels = np.arange(0.,1.5, 0.05)
cmap = plt.get_cmap('Greens')
norm = BoundaryNorm(levels, ncolors=cmap.N, clip=True)
im = f3ax0.pcolormesh(time, cohort_size_bins, (DDBH_CANOPY_SCLS / NPLANT_CANOPY_SCLS)[:,:,0].transpose(), cmap=cmap, norm=norm)
fig3.colorbar(im, ax=f3ax0)
f3ax0.set_title(r'Growth rate of canopy plants (cm DBH yr$^{-1}$)')
f3ax0.set_xlabel('Time (yr)')
f3ax0.set_ylabel('Cohort Size (cm)')

## set up the second plot: growth rate in the understory, units as above
levels = np.arange(0.,0.15, 0.005)
cmap = plt.get_cmap('Greens')
norm = BoundaryNorm(levels, ncolors=cmap.N, clip=True)
im = f3ax1.pcolormesh(time, cohort_size_bins, (DDBH_UNDERSTORY_SCLS / NPLANT_UNDERSTORY_SCLS)[:,:,0].transpose(), cmap=cmap, norm=norm)
fig3.colorbar(im, ax=f3ax1)
f3ax1.set_title(r'Growth rate of understory plants (cm yr$^{-1}$)')
f3ax1.set_xlabel('Time (yr)')
f3ax1.set_ylabel('Cohort Size (cm)')

## set up the third plot: mortality rate in the canopy, in units of fraction of trees per year of a given size class and canopy position
levels = np.arange(0.,0.1, 0.01)
cmap = plt.get_cmap('Reds')
norm = BoundaryNorm(levels, ncolors=cmap.N, clip=True)
im = f3ax2.pcolormesh(time, cohort_size_bins, (MORTALITY_CANOPY_SCLS / NPLANT_CANOPY_SCLS)[:,:,0].transpose(), cmap=cmap, norm=norm)
fig3.colorbar(im, ax=f3ax2)
f3ax2.set_title(r'Mortality rate of canopy plants (yr$^{-1}$)')
f3ax2.set_xlabel('Time (yr)')
f3ax2.set_ylabel('Cohort Size (cm)')

## set up the fourth plot: mortality rate in the understory, units as above
levels = np.arange(0.,1.0, 0.1)
cmap = plt.get_cmap('Reds')
norm = BoundaryNorm(levels, ncolors=cmap.N, clip=True)
im = f3ax3.pcolormesh(time, cohort_size_bins, (MORTALITY_UNDERSTORY_SCLS / NPLANT_UNDERSTORY_SCLS)[:,:,0].transpose(), cmap=cmap, norm=norm)
fig3.colorbar(im, ax=f3ax3)
f3ax3.set_title(r'Mortality rate of understory plants (yr$^{-1}$)')
f3ax3.set_xlabel('Time (yr)')
f3ax3.set_ylabel('Cohort Size (cm)')

# show the plot
fig3.tight_layout()
plt.show()
