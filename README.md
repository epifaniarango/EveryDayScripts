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
```

