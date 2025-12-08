#!/bin/bash

#SBATCH -A chem
#SBATCH -p burst
#SBATCH -t 03:00:00
#SBATCH -N 1                    # 1 nodes
#SBATCH --ntasks-per-node=1     # 1 tasks/node
#SBATCH -c 8                    # 8 cores/task
#SBATCH --mem=0
#SBATCH -J 1mLiFSI_TFMSPyr 
#SBATCH -o rdfall_tfmspyr/rdfout.%J
#SBATCH -e rdfall_tfmspyr/rdferr.%J

# Load modules
module reset
module load intel mkl fftw hwloc cmake

# Export gcc path and num_threads
export LD_LIBRARY_PATH=/sw/cades-open/gcc/12.2.0/lib64:$LD_LIBRARY_PATH
export OMP_NUM_THREADS=${SLURM_CPUS_PER_TASK}

# Initializing jobs
cd $SLURM_SUBMIT_DIR
echo "begin job @start time: ${date}"
echo $PWD

# Run command
gmx="${HOME}/gromacs-2024.5/install/bin/gmx_mpi "


# Make output directory
inpdir='rdfinps'
outdir='rdfall_tfmspyr'
mkdir -p ${outdir}

# Create RDF files
echo "Run rdf-Li-all"

srun ${gmx} rdf -f traj_npt_main.trr -s npt_main.tpr -o ${outdir}/rdf_Li_all.xvg -cn ${outdir}/nrdf_Li_all.xvg -b 40000 -e 48000 -rmpbc yes -ref -sf ${inpdir}/refLi.txt -sel -sf ${inpdir}/rdfsel_all.txt
wait

echo "Run rdf-OFSI-all"
srun ${gmx} rdf -f traj_npt_main.trr -s npt_main.tpr -o ${outdir}/rdf_OFSI_all.xvg -cn ${outdir}/nrdf_OFSI_all.xvg -b 40000 -e 48000 -rmpbc yes -ref -sf ${inpdir}/refOFSI.txt -sel  -sf ${inpdir}/rdfsel_all.txt
wait

echo "Run rdf-FFSI-all"
srun ${gmx} rdf -f traj_npt_main.trr -s npt_main.tpr -o ${outdir}/rdf_FFSI_all.xvg -cn ${outdir}/nrdf_FFSI_all.xvg -b 40000 -e 48000 -rmpbc yes -ref -sf ${inpdir}/refFFSI.txt -sel  -sf ${inpdir}/rdfsel_all.txt
wait

echo "Run rdf-NFSI-all"
srun ${gmx} rdf -f traj_npt_main.trr -s npt_main.tpr -o ${outdir}/rdf_NFSI_all.xvg -cn ${outdir}/nrdf_NFSI_all.xvg -b 40000 -e 48000 -rmpbc yes -ref -sf ${inpdir}/refNFSI.txt -sel  -sf ${inpdir}/rdfsel_all.txt
wait

echo "All RDF calculations completed"
echo "move files to ${outdir}"
mv rdferr* ${outdir}
mv rdfout* ${outdir}
cp rdf*txt ${outdir}
