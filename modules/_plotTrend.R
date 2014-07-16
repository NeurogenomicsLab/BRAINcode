###########################################
# Rscript to plot the expression of specific gene(s) along the stages/categories
# Usage: Rscript $PIPELINE_PATH/_plotTrend.R genes.fpkm.allSamples.uniq.xls SNCA
# Author: Xianjun Dong
# Version: 0.0
# Date: 2014-Jul-15
###########################################

args<-commandArgs(TRUE)

FPKMfile=args[1]  # either filename or stdin
outputfile=args[2]

fpkm=read.table(file(FPKMfile), header=T);  # table with header (1st row) and ID (1st column)
# change from wide to long format
library('reshape2')
df=melt(fpkm, measure.vars=grep("FPKM", colnames(fpkm)))
df$variable=gsub("FPKM.(.*)_.*_(.*)_.*", "\\1_\\2", df$variable)

# plot
library('ggplot2')
p <- ggplot(df, aes(colour=tracking_id, y=value, x=variable))
p +  geom_boxplot() +
     ylab("FPKM") +
     theme(legend.justification=c(0,1),
           legend.position=c(0,1),
           legend.title=element_blank(),
           axis.title.x=element_blank(),
           legend.background = element_rect(fill="transparent"),
           legend.key = element_blank()
        )
ggsave(file=outputfile)




##fpkm=read.table("genes.fpkm.allSamples.uniq.xls", header=T)
#fpkm=cbind(id=paste(fpkm$tracking_id, fpkm$gene_id, fpkm$gene_short_name, sep="__"), fpkm[, grep("FPKM", colnames(fpkm))])
##rownames(fpkm)=fpkm[,1]; fpkm=fpkm[,-1]
#
## change from wide to long format
#library('reshape2')
#fpkml=melt(fpkm)
#df=fpkml[grep(pattern,fpkml$id), ]
#df$variable=gsub("FPKM.(.*)_.*_(.*)_.*", "\\1_\\2", df$variable)
#
## plot
#library('ggplot2')
#p <- ggplot(df, aes(colour=id, y=value, x=variable))
#p +  geom_boxplot() +
#     theme(legend.justification=c(0,1),
#           legend.position=c(0,1),
#           legend.title=element_blank(),
#           legend.background = element_rect(fill="transparent")
#        )
#
##p + geom_point() + geom_errorbar(aes(ymax = resp + se, ymin=resp - se), width=0.2)
##p + geom_line(aes(group=group)) + geom_errorbar(limits, width=0.2)

