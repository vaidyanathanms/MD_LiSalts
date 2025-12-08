#!/bin/bash

#SBATCH -A chem
#SBATCH -p burst
#SBATCH -t 00:10:00
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -c 36
#SBATCH --mem=2G
#SBATCH -J pLiFSI_TFMSPyr
#SBATCH -o outdir/out.%J
#SBATCH -e outdir/err.%J

module load openmpi
module load python
module load gromacs/2024.1-mpi-omp

cd $SLURM_SUBMIT_DIR

echo "begin job.."
echo $PWD

mkdir -p initdir
mkdir -p outdir

# generate structure
~/tools/packmol/packmol < make_mixture.inp
wait

# editconf box
srun gmx_mpi editconf -f lifsi_tfmspyr.pdb -bt cubic -box 5.2 5.2 5.2 -o main.pdb
wait

# make tpr file
srun gmx_mpi grompp -f minim.mdp -p topol.top -c main.pdb -o enermin.tpr
wait

cp *.pdb initdir/
