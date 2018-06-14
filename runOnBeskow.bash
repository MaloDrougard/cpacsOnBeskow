#!/bin/bash -l
# the -l above is required to get the full environment with modules

# run validation job on beskow, Malo 2018

# The allocation to be charged
#SBATCH -A 2018-3-192

# The job name
#SBATCH -J validation

# Allocation time
#SBATCH -t 20:00:00

# Number of nodes
#SBATCH --nodes=16
# Number of MPI processes per node (the following is actually the default)
#SBATCH --ntasks-per-node=32

#SBATCH -e error_file.err.%J
#SBATCH -o out_file.o.%J

#SBATCH --mail-type=ALL

# Enable shared libraries, which you need as /bin/bash is dynamically linked)

# Load the su2 module
#module swap PrgEnv-cray PrgEnv-gnu
#module add su2/5.0.0



export SU2_RUN="/pdc/vol/su2/5.0.0/GNU/bin"
export PATH=$PATH:$SU2_RUN
export PYTHONPATH=$PYTHONPATH:$SU2_RUN



echo "-------------------------------------------------------------------------"
echo "VALIDATE FUNCTIONS: script started  `date`          "
echo "-------------------------------------------------------------------------"
echo " "

coresN=512 	# should be a multiple of 32
inputCfg="$(ls input*.cfg)"	# retriev the su configuration files

#case
p="d"	 # should be the same as in cpacsToSu2.bash !
l="0 5 10 15"	# should be the same as in cpacsToSu2.bash !

workD="$(pwd)"

for i in $l
do
  
  caseD="$workD/Results/$p$i"
 
  for c in $inputCfg
  do 
    
    # create sub case directory   
    subCase=${c%.*}
    subCase=${subCase#input-}
    subCaseD="$caseD/$subCase"
       
    mkdir $subCaseD
    
    # prepare and configure file	    
    cp $workD/$c $subCaseD/
    sed -i "s/MESH_FILENAME = .*/MESH_FILENAME = $p$i.su2/" $subCaseD/$c	# change input file in su2 config 
    eval cp $caseD/$p$i.su2 $subCaseD/        
    
    
    cd $subCaseD
      
    eval suOut="su2Cmd.out"	  
    eval suErr="su2Cmd.err"	  
    
    echo "start case: $p$i cfg: $c dir: $subCaseD"
    startDate=$(date +%s)	
    aprun -n $coresN -N 32 SU2_CFD $c > $suOut 2> $suErr 
    endDate=$(date +%s)
    
    processTime=$(($endDate - $startDate))
   	  	  
    startDate=$(date +%s)	
    cp restart_flow.dat solution_flow.dat 	
    aprun -n 1 SU2_SOL $c >> $suOut 2>> $suErr	   
    endDate=$(date +%s)
    
    postProcessTime=$(($endDate - $startDate))
    
    echo "end: processTime: $processTime postProcessTime: $postProcessTime"
    eval processTime${i}=$processTime
    eval postProcessTime${i}=$postProcessTime
    
    cd $workD
  
  done
  
done


echo "-------------------------------------------------------------------------" 
echo "SUMARY: #case;  #inputFile; #timeSU2 ; #timePost" 
echo "-------------------------------------------------------------------------" 


for i in $l
do  
  
  for c in $inputCfg
  do 
    eval temp=\${processTime${i}}
    eval temp2=\${postProcessTime${i}}
    echo "$p$i;$c;$temp;$temp2"
  done
done





echo "-------------------------------------------------------------------------"
echo "VALIDATE FUNCTIONS:   end `date`          "
echo "-------------------------------------------------------------------------"
echo " "


