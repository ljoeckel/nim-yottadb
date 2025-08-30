echo "program $1"
echo "iterations=$2"
for i in {1..1000000}
do
   echo "Running test $1. Iteration $i"
   $1
done
