# Author: Vaidyanathan M. Sethuraman
# Date: June-27-2025

# To generate CL&P FF with topology and initial pdb structure for each molecule
# Have to do for each molecule one-by-one or else files will be overwritten
# config.pdb/simbox.xyz and field.top should be renamed at the end as well
# Copy the pack.inp generated in the first step to a new file to avoid confusion
# I have always used rho=1 
# Keep il.ff in the same folder

molarr=('ntf2') #'c2c1im' 'fsi')
for molname in "${molarr[@]}"; do
   echo "Generating gmx files for ${molname} using CL&P forcefield and fftool"
   python3 ~/tools/fftool/fftool 1 ${molname}.zmat -r 1
   wait
   cp pack.inp pack_${molname}.inp
   ~/tools/packmol/packmol < pack_${molname}.inp
   wait
   python3 ~/tools/fftool/fftool 1 ${molname}.zmat -r 1 --mix a -gmx
   wait
   cp config.pdb ${molname}.pdb
   cp simbox.xyz ${molname}_single.xyz
   cp field.top  ${molname}.top
   wait
   rm config.pdb simbox.xyz field.top
   echo "${molname} completed..."
done 
