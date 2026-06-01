# PCA
I use this script when handling Whole-Genome data which is big and hard to handle locally. Here, I assume my big VCF files (by chromosome) are in the cluster and later I will be able to have a single pruned plink file that is more manageable to work locally. 

On this script I pruned with this parameters (50 5 0.4) which work good for whole-genome data, you can include here or in the later steps any filter you want (HWE, MAF, etc...)

```
condor_submit 1.VCFtoPLINK.sub
```
Once this runs

```
condor_submit 2.MergePlink.sub
```
Now you can trasnger the files data.bed, data.bim and data.fam to your local machine, run PCA and plot it. 

```
plink --bfile data --allow-no-sex --pca 10 --out pca

```
I attach here my Rscript for plotting:
```
setwd("your_directory")
library(data.table)
library(RColorBrewer)
library(tidyverse)


PCA <- read_table2("pca.eigenvec", col_names = FALSE)
names(PCA)[2] <- "ind"
names(PCA)[1] <- "populations"
names(PCA)[3:ncol(PCA)] <- paste0("PC", 1:(ncol(PCA)-2))

eigenval <- scan("pca.eigenval")

pve <- data.frame(PC = 1:10, pve = eigenval/sum(eigenval)*100)
#I paste the vvalues manually to ggplot for each PC

pve

#this is the order you want or your popualtions to appear in the legedn of the plot
f = factor(c("Yoruba","French","Han","Quechua","Karitiana","Surui","Huilliche-Chiloe","Lafkenche","Pehuenche"))

PCA1=PCA[order(match(PCA$populations, f)),]
PCA$populations <- factor(PCA$populations, levels = c(f))

PCA1$populations<- factor(PCA1$populations, levels = f)



aa=ggplot(PCA1, aes(PC1,PC2, color=populations))+
  geom_point() +
  theme_classic() +
  xlab("PC1 (21.48%)") + ylab("PC2 (10.06%)")+
  scale_colour_manual(name = "Population", labels = f,values =c("#E78AC3","#FC8D62","#8DA0CB","#A6D854","#B3B3B3","purple","#66C2A5","#FFD92F","#E5C494")) 


aa


#If you also want to include shapes, you can do it like this:



aa=ggplot(pca1, aes(PC1,PC2, color=populations, shape=populations))+
  geom_point(size=5,alpha=0.9) +
  theme_classic() +
  xlab("PC1 (21.48%)") + ylab("PC2 (10.06%")+
  scale_colour_manual(name = "Population", labels = f,values =c("#FC8D62","#8DA0CB","#A6D854","#36454F","purple","#66C2A5","#FFD92F","#E5C494")) +
  scale_shape_manual(name = "Population", labels = f,values =c(19,19,19,8,1,16,1,19)) +
  theme(
    axis.title = element_text(size = 14, face = "bold"),
    axis.text = element_text(size = 12),
    legend.title = element_text(size = 14, face = "bold"),
    legend.text = element_text(size = 12)
  )



aa

```


