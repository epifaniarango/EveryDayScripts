# ADMIXTURE
For this script your already need the pruned data! The prunning setup is on the [PCA branch](https://github.com/epifaniarango/EveryDayScripts/tree/PCA). You also have available here the definition file to create the container. To select how many Ks and RUNs, run this script in your terminal. 
```
for k in {2..10}; do for r in {0..10}; do echo "$k $r"; done; done > admixture_jobs.txt
```
Be awere that you need to modify BOTH the file admixture.sub and admixture_independet_jobs.sh with the name off your plink files before running the script.
```
condor_submit admixture.sub
```
Once it is over you can trasnfer the output files locally eithr with scp or globus. PONG can only be used locally and you can install it with conda.
```
mkdir output
mv *.Q output/
mv *.P output/
mv log.* output/
zip -r output_admixture.zip output/
```

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

for f in log.*.out; do
    k=$(echo "$f" | sed -n 's/.*_K\([0-9]*\)\.RUN\([0-9]*\)\.out/\1/p')
    r=$(echo "$f" | sed -n 's/.*_K\([0-9]*\)\.RUN\([0-9]*\)\.out/\2/p')
    ll=$(grep '^Loglikelihood:' "$f" | awk '{print $2}')
    echo "$k $r $ll"
done > Loglikelihood.txt



for i in DataPruned_K*.Run*.Q; do
    k=$(echo "$i" | sed -n 's/.*_K\([0-9]*\)\.Run[0-9]*\.Q/\1/p')
    r=$(echo "$i" | sed -n 's/.*\.Run\([0-9]*\)\.Q/\1/p')
    newname="k${k}r${r}"
    echo -e "${newname}\t${k}\t$(pwd)/$i"
done > pong_filemap
```

Rscript:
```
#Create files por population labels and order of pops

setwd("/Users/ragsdalelab/Documents/Leticia/Analysis/1.ADMIXTURE/")

fam=read.table("Data4ADMIXTURE.fam", header = F)



write.table(fam$V1, "ind2pop.txt", row.names = F,col.names = F, quote = F)
            
order=unique(fam$V1)
write.table(order,"order_pops.txt", row.names = F,col.names = F, quote = F)

#then modify manually your desired order

library(data.table)
library(ggplot2)
            
cv =fread("output/CV.txt", col.names = c("K", "Run", "cv_error"))
cv_plot <- ggplot(cv, aes(group=K, x=K, y=cv_error)) + 
geom_boxplot() +
 theme(legend.position="none") +
 labs(x="K", y="Cross-validation error",
  caption = paste("min CV-error =", cv[which(cv$cv_error == min(cv$cv_error)),]$cv_error, "in K =", cv[which(cv$cv_error == min(cv$cv_error)),]$K)) +
 scale_x_continuous("K", labels = as.character(min(cv$K):max(cv$K)), breaks = min(cv$K):max(cv$K))+
 ggtitle("Cross Validation Error - Autosomes")+
 theme_classic() 
 cv_plot
 ggsave(plot = cv_plot, filename = "CV_error.pdf", width = 10, height = 4)
```

On the terminal:
```
pong --filemap pong_filemap -i ind2pop.txt -n order_pops.txt
```
Here you can also inclue a list of colors to match your asthetics. 


