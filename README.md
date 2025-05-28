# ADMIXTURE
I used to run this script using snakemake and I loved it. But since I moved to UW, I need to use CHTC (my worst nightmare). On this folder, you can find the def fiel to create the container, the submission file and the script. On the birhgt side, CHTC is pretty fast.

```
condor_submit admixture.sub
```

The annoying part now, it is that I used to have everything organzied to produce the input for plotting with Pong.

```
mkdir output
mv *.Q output/
mv *.P output/
mv log.* output/
zip -r output_admixture.zip output/
```
Now I transfer to my local machine, as Pong needs to be used locally. 

```
scp your_user@ap2001.chtc.wisc.edu:/home/arangoisaza/Leticia/1.ADMIXTURE/output_admixture.zip  ./
unzip output_admixture.zip
cd ouput
for f in log.*.out; do
    k=$(echo "$f" | sed -n 's/.*_K\([0-9]*\)\.RUN\([0-9]*\)\.out/\1/p')
    r=$(echo "$f" | sed -n 's/.*_K\([0-9]*\)\.RUN\([0-9]*\)\.out/\2/p')
    cv=$(grep "CV error" "$f" | awk '{print $NF}')
    echo "$k $r $cv"
done > CV.txt

grep -H '^Loglikelihood:' log.*.out | awk -F'[_.:]' '{print $3 "." $4, $NF}' > Loglikelihood.txt
```

