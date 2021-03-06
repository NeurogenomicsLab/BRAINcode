###############################################
## Rscript for generating boxplot of expression vs. genotype for gene-SNP pairs (e.g. from the eQTL output)
## similar with _eQTL_boxplot.R, except that all plots saved into one file
## Author: Xianjun Dong
## Date: 2017-Jan-13
## Version: 0.0
## Usage: Rscript ~/neurogen/pipeline/RNAseq/modules/_eQTLlist_boxplot.R gene.snp.list path
###############################################
require(MatrixEQTL)

args<-commandArgs(TRUE)
GSfile=args[1]  # gene SNP table
path=ifelse(is.na(args[2]),"~/eRNAseq/HCILB_SNDA",args[2]) 
setwd(path); 

# setwd("~/neurogen/rnaseq_PD/results/eQTL/HCILB_SNDA/"); load("data.RData"); load("genes.RData"); G="ENSG00000117280.8"; S="rs823116:205720483:G:A_G:A"; genesnp = read.table("final.cis.eQTL.d1e6.p1e-2.xls", header=T, stringsAsFactors =F)
# setwd("~/eRNAseq/HCILB_SNDA");load("data.RData"); load("genes.RData"); G="chr17_44218414_44219042"; S="rs17649553:43994648:C:T_C:T"; genesnp = read.table("final.cis.eQTL.d1e6.p1e-2.xls", header=T, stringsAsFactors =F)

message("# load data...")
######################
load("data.RData") # snps etc.
genesnp = read.table("final.cis.eQTL.d1e6.p1e-2.xls", header=T, stringsAsFactors =F)
if(file.exists("genes.RData")) load("genes.RData") else{
  residuals = read.table("expression.postSVA.xls", check.names=F)
  genes = SlicedData$new();
  genes$CreateFromMatrix(as.matrix(residuals))
  save(genes, file="genes.RData")
}

# one file for all plots
pdf(paste(GSfile,"pdf",sep="."), width=6, height=4)

GS=read.table(GSfile, header = F, stringsAsFactors = F)
apply(GS, 1, function(gs) {
  G=gs[1]; S=gs[2];
  message(paste0("# making eQTL plot for ",S," and ",G," ..."))
  ######################
  RS=sub("([^:]*):.*","\\1", S) ## the part before the first ":" in the SNP ID
  REF = strsplit(sub(".*_(.*)","\\1", S),":")[[1]][1]  ## get the REF allele
  ALT = strsplit(sub(".*_(.*)","\\1", S),":")[[1]][2]  ## get the ALT allele
  
  par(mfrow=c(1,3), mar=c(4,4,2,1), oma = c(0, 0, 2, 0))
  genesnp0=subset(genesnp, gene==G & SNP==S)
  p=signif(genesnp0$p.value, 3);
  beta=signif(genesnp0$beta, 3);
  
  df=data.frame(expression=as.numeric(genes$FindRow(G)$row), SNP=as.numeric(snps$FindRow(S)$row), row.names = colnames(snps$FindRow(S)$row))
  ## write data to txt file
  write.table(df, file=paste("pair",G,S,"xls",sep="."), col.names = NA,quote=F, sep="\t")
  
  df$SNP1=factor(df$SNP, levels=2:0)  ## in the current All.Matrix.txt, the number is number of REF allele (since we use REF in the --recode-allele) -- Ganqiang
  if(is.na(p) || length(p)==0) { # in case SNP:eQTL pair is not in the final.cis.eQTL.d1e6.p1e-2.xls file (e.g. those not or less significant pairs)
      # test=aov(expression~SNP1, df)  # anova: modelANOVA
      # p=signif(summary(test)[[1]][["Pr(>F)"]][[1]],3)  
      # change to use lm(): 12/11/2018
      test = lm(expression~SNP, df)  # t-test: modelLINEAR
      p=signif(summary(test)$coefficients[2,"Pr(>|t|)"],3)
      beta=signif(summary(test)$coefficients[2,"Estimate"],2)
  }
  bp=boxplot(expression~SNP1, data=df, ylab="Normalized Expression log10(RPKM)", xaxt='n', main="",  col='lightgreen', outpch=NA)
  stripchart(expression~SNP1, data=df, vertical = TRUE, method = "jitter", pch = 1, col = "darkred", cex=1, add = TRUE) 
  title(main=paste0("additive (p=", p,", beta=",-beta,")"), cex.main=1, line=0.5)
  mtext(c("Homo Ref","Het","Homo Alt"), cex=0.7,side=1,line=.5,at=1:3)
  mtext(paste0(c(REF,REF,ALT),c(REF,ALT,ALT)),  cex=0.7,side=1,line=1.5,at=1:3)
  mtext(paste0("N = ", bp$n),  cex=0.7,side=1,line=2.5,at=1:3)
  
  # with/without REF
  df$SNP2=ifelse(as.numeric(as.character(df$SNP))==0,0,1)  ## 0: without REF; 1:with REF
  if(length(unique(df$SNP2))>1 & min(table(df$SNP2))>1) { #grouping factor must have exactly 2 levels  AND at least 2 values in each group
    # p0=signif(t.test(expression~factor(df$SNP2, levels=1:0), df)$p.value,3) # anova
    test = lm(expression~factor(df$SNP2, levels=1:0), df)  # t-test: modelLINEAR
    p2=signif(summary(test)$coefficients[2,"Pr(>|t|)"],3)
    beta2=signif(summary(test)$coefficients[2,"Estimate"],2)
    bp=boxplot(expression~factor(df$SNP2, levels=1:0), data=df, ylab="Normalized Expression log10(RPKM)", xaxt='n', main="", col='lightblue', outpch=NA)
    stripchart(expression~factor(df$SNP2, levels=1:0), data=df, vertical = TRUE, method = "jitter", pch = 1, col = "darkred", cex=1, add = TRUE)
    title(main=paste0("dominant (p=", p2,", beta=",beta2,")"), cex.main=1, line=0.5)
    mtext(c("with REF","without REF"), cex=0.7,side=1,line=0.5,at=1:2)
    mtext(c(paste0(c(REF,REF),c(REF,ALT),collapse = "/"), paste0(ALT,ALT)),  cex=0.7,side=1,line=1.5,at=1:2)
    mtext(paste0("N = ", bp$n), cex=0.7,side=1,line=2.5,at=1:2)
  }
  
  # with/without ALT
  df$SNP3=ifelse(as.numeric(as.character(df$SNP))==2,0,1)  ## 0: without ALT; 1:with ALT
  if(length(unique(df$SNP3))>1 & min(table(df$SNP3))>1) {  #grouping factor must have exactly 2 levels AND at least 2 values in each group
    #df$SNP3=factor(df$SNP3, levels=0:1)
    #p0=signif(t.test(expression~SNP3, df)$p.value,3)
    test = lm(expression~factor(df$SNP3, levels=0:1), df)  # t-test: modelLINEAR
    p3=signif(summary(test)$coefficients[2,"Pr(>|t|)"],3)
    beta3=signif(summary(test)$coefficients[2,"Estimate"],2)
    bp=boxplot(expression~factor(df$SNP3, levels=0:1), data=df, ylab="Normalized Expression log10(RPKM)", xaxt='n', main="", col='lightblue', outpch=NA)
    stripchart(expression~factor(df$SNP3, levels=0:1), data=df, vertical = TRUE, method = "jitter", pch = 1, col = "darkred", cex=1, add = TRUE)
    title(main=paste0("dominant (p=", p3,", beta=",beta3,")"), cex.main=1, line=0.5)
    mtext(c("without ALT","with ALT"), cex=0.7,side=1,line=0.5,at=1:2)
    mtext(c(paste0(REF,REF), paste0(c(REF,ALT),c(ALT,ALT),collapse = "/")),  cex=0.7,side=1,line=1.5,at=1:2)
    mtext(paste0("N = ", bp$n), cex=0.7,side=1,line=2.5,at=1:2)
  }
  
  mtext(paste("cis-eQTL for",G,"and",S), outer = TRUE, cex = 1.2)     
  
  ## without jitter and outliers (optional)
  ##############################

  par(mfrow=c(1,3), mar=c(4,4,2,1), oma = c(0, 0, 2, 0))
  bp=boxplot(expression~SNP1, data=df, ylab="Normalized Expression log10(RPKM)", xaxt='n', main="",  col='lightgreen', outline = F, outpch=NA)
  title(main=paste0("additive (p=", p,", beta=",-beta,")"), cex.main=1, line=0.5)
  mtext(c("Homo Ref","Het","Homo Alt"), cex=0.7,side=1,line=.5,at=1:3)
  mtext(paste0(c(REF,REF,ALT),c(REF,ALT,ALT)),  cex=0.7,side=1,line=1.5,at=1:3)
  mtext(paste0("N = ", bp$n),  cex=0.7,side=1,line=2.5,at=1:3)
  
  # with/without REF
  if(length(unique(df$SNP2))>1 & min(table(df$SNP2))>1) { #grouping factor must have exactly 2 levels  AND at least 2 values in each group
      bp=boxplot(expression~factor(df$SNP2, levels=1:0), data=df, ylab="Normalized Expression log10(RPKM)", xaxt='n', main="", col='lightblue', outline = F, outpch=NA)
      title(main=paste0("dominant (p=", p2,", beta=",beta2,")"), cex.main=1, line=0.5)
      mtext(c("with REF","without REF"), cex=0.7,side=1,line=0.5,at=1:2)
      mtext(c(paste0(c(REF,REF),c(REF,ALT),collapse = "/"), paste0(ALT,ALT)),  cex=0.7,side=1,line=1.5,at=1:2)
      mtext(paste0("N = ", bp$n), cex=0.7,side=1,line=2.5,at=1:2)
  }
  
  # with/without ALT
  df$SNP3=ifelse(as.numeric(as.character(df$SNP))==2,0,1)  ## 0: without ALT; 1:with ALT
  if(length(unique(df$SNP3))>1 & min(table(df$SNP3))>1) {  #grouping factor must have exactly 2 levels AND at least 2 values in each group
      bp=boxplot(expression~factor(df$SNP3, levels=0:1), data=df, ylab="Normalized Expression log10(RPKM)", xaxt='n', main="", col='lightblue', outline = F, outpch=NA)
      title(main=paste0("dominant (p=", p3,", beta=",beta3,")"), cex.main=1, line=0.5)
      mtext(c("without ALT","with ALT"), cex=0.7,side=1,line=0.5,at=1:2)
      mtext(c(paste0(REF,REF), paste0(c(REF,ALT),c(ALT,ALT),collapse = "/")),  cex=0.7,side=1,line=1.5,at=1:2)
      mtext(paste0("N = ", bp$n), cex=0.7,side=1,line=2.5,at=1:2)
  }
  
  mtext(paste("cis-eQTL for",G,"and",S), outer = TRUE, cex = 1.2)     
  
})

dev.off() 