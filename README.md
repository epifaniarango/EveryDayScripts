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

for f in log.*.out; do
    k=$(echo "$f" | sed -n 's/.*_K\([0-9]*\)\.RUN\([0-9]*\)\.out/\1/p')
    r=$(echo "$f" | sed -n 's/.*_K\([0-9]*\)\.RUN\([0-9]*\)\.out/\2/p')
    ll=$(grep '^Loglikelihood:' "$f" | awk '{print $2}')
    echo "$k $r $ll"
done > Loglikelihood.txt



for i in Data4ADMIXTUREpruned_K*.Run*.Q; do
    k=$(echo "$i" | sed -n 's/.*_K\([0-9]*\)\.Run[0-9]*\.Q/\1/p')
    prefix=${i%.Q}
    echo -e "$prefix\t$k\t$(pwd)/$i"
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


