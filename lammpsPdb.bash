# This Program turn standart .lampstrj first timestep 
# into .pdb files.

#-------------READ ME----------------------
# You need to execute this program in the same
# directory than your dump .lammpstrj file.
#
# Remember of use -> dump_modify group-id sort id
# in your lammps input
#
# When you execute this code, type in this format:
# $ bash lammpsPdb.bash > anyName.pdb
# It guarantees that:
# ">": the output will goes to a file
# "anyName.pdb": the file is in .pdb format
#
# Modify the directory information according with your
# need and your dump file name.
#-------------------------------------------

# The code steps (if you are interested in learn bash):
# 1) Take the number of atoms and boxsize;
# 2) Identify the atom type;
# 3) Take the positions noting the atom type;
# 4) Write the format:
# 	4.1) First line with CRYST1 with box size.
# 		example: CRYST1 10 10 10 20 20 20 P 1 1
# 		Cube of edges of lengh 10
# 	4.2) Next lines with the standart format, 
# 	atoms type, atoms number and  positions.
# 	4.3) Last line: END
# 
# P.S.: when you fill the needy parts delete the 
#       squared brakes too

# Declarations.
declare -a types
declare -a aPos
declare -a sizeBox

# First we take the first timestep info

# 1)Take the number of atoms and box size (change filename)
nAtoms=$(grep -B 1 "BOX BOUNDS" ./dump-production.lammpstrj | head -n 1);
sizeBox=($(grep -A 4 "BOX BOUNDS" ./dump-production.lammpstrj | head -n 4 | tail -n 3 | awk '{printf $1"\t"; printf $2"\t"}')); #Change to something positive

# 1.1) Separating the sizeBox coordinates
xMinus=$(python -c "print float('${sizeBox[0]}')");
xPlus=$(python -c "print float('${sizeBox[3]}')");
yMinus=$(python -c "print float('${sizeBox[1]}')");
yPlus=$(python -c "print float('${sizeBox[4]}')");
zMinus=$(python -c "print float('${sizeBox[2]}')");
zPlus=$(python -c "print float('${sizeBox[5]}')");

# 1.1.1) Writing the sizeBox coordinates without scientific notation
x=$(python -c "a=float($xPlus-$xMinus) 
if a<0: 
        a=-a
print('%.3f' %a)");
y=$(python -c "a=float($yPlus-$yMinus) 
if a<0: 
        a=-a
print('%.3f' %a)");
z=$(python -c "a=float($zPlus-$zMinus) 
if a<0: 
	a=-a
print('%.3f' %a)");

# 2) Identify the atom type (NEED YOUR INPUT)
# Look at your topology file and write your atom types here
# The physical element name cames after all type numbers
# For example: type 15 is O and type 13 is H
#	write like this:
#	nTypers=2; #2 different types
#	types=(15 13 O H);

nTypes=4;
types=(14 15 16 17 O H Cl Na);
#printf ${t4[0]};

# 3) Take the positions (change filename)
# Taking the position of the first atom
fAtom=$(grep -A 1 "ATOMS id type x y z" ./dump-production.lammpstrj | tail -n 1);

# Taking the others Atoms Positions from the first atom position
aPos=($(grep -A $nAtoms "$fAtom" ./dump-production.lammpstrj));

# 4) Writing the format

# 4.1) The head line
ninety="90";
python -c "print('{:6s}{:8.3f}{:8.3f}{:8.3f}{:6.2f}{:6.2f}{:6.2f}{:2s}{:2d}{:12d}'.format('CRYST1',float($x),float($y),float($z),float(90.00), float(90.00), float(90.00), ' P', int(1), int(1)))"

# 4.2) The positions and atom information lines

#----------FOR NOW IT IS NOT NECESSARY----------
# 4.2.1) Group info
# In your input file to LAMMPS, please use:
# dump_modify group-id sort id
#----------FOR NOW IT IS NOT NECESSARY----------


#4.2.1) Group info, atom info and positions together
for ((i=1; i<($nAtoms)*5; i+=5))
do
	for ((j=0; j<$nTypes; j++))
	do
		if ((${aPos[i]}==${types[j]}))
		then
			python -c "print('{:6s}{:5d} {:^4s}{:1s}{:3s} {:1s}{:4d}{:1s}   {:8.3f}{:8.3f}{:8.3f}{:6.2f}{:6.2f}          {:>2s}{:2s}'.format('ATOM', int(${aPos[i-1]}), '${types[j+nTypes]}', ' ', 'UNK', 'X', int(${aPos[i-1]}), ' ', float(${aPos[i+1]}), float(${aPos[i+2]}), float(${aPos[i+3]}), float(0.00), float(0.00), 'UNK', '  '))"

#			echo ATOM	${aPos[i-1]}	${types[j+nTypes]}	UNK X	${aPos[i-1]}	${aPos[i+1]}	${aPos[i+2]}	${aPos[i+3]}	0.00	0.00	UNK
		fi 
	done
done

#echo ${aPos[11]}






