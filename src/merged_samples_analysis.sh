#################################
# coverage of genome by RNAseq 
#################################
# % of genome covered by RNAseq (>5rpm)
DONE
# Rscript to make plot of coverage vs. rpm
RPM=data.frame();
pdf("rpm_vs_coverage.merged.pdf", width=6, height=6)
for(i in list.files(pattern="*rpm_vs_coverage.txt")){
    samplename=gsub(".accepted_hits", "", gsub(".normalized.rpm_vs_coverage.txt","",i))
    df=read.table(i, header=F); rownames(df)=df[,1]; df=df[,-1,drop=F]; colnames(df)=samplename
    df[,1]=cumsum(df[,1])*100/3e9
    if(ncol(RPM)==0) {RPM=df;} else {RPM=cbind(RPM, df);}
    plot(df[,1], xlab="RPM", ylab="% of cummulative base pairs covered", xaxt='n',yaxt='n', type="l", main=samplename, log="y", ylim=c(.005,100))
    axis(side=1, at=c(0:10)*10+1, labels=rownames(RPM)[c(0:10)*10+1])
    axis(side = 2, at = (locs <- 100/c(1,10,100,1000)), labels = locs)
    axis(side = 2, at = (locs2 <- c(outer(1:10, c(0.1, 1, 10, 100), "/"))), labels = NA, tcl = -0.3)
}
# merge of all
plot(RPM[,1], xlab="RPM", ylab="% of cummulative base pairs covered", xaxt='n',yaxt='n', main="all together", type="n", log="y", ylim=c(.005,100))
#sapply(1:ncol(RPM), function(x) lines(RPM[,x], col=x))
sapply(colnames(RPM), function(x) lines(RPM[,x], col=as.integer(sub(".*_([1-4]).*","\\1", x))))
points(rep(nrow(RPM),ncol(RPM)), RPM[nrow(RPM),], col=as.integer(sub(".*_([1-4]).*","\\1", colnames(RPM))))
axis(side=1, at=c(0:10)*10+1, labels=rownames(RPM)[c(0:10)*10+1])
axis(side = 2, at = (locs <- 100/c(1,10,100,1000)), labels = locs)
axis(side = 2, at = (locs2 <- c(outer(1:10, c(0.1, 1, 10, 100), "/"))), labels = NA, tcl = -0.3)
legend("topleft", paste("batch", 1:4), col=1:4, lty=1, cex=.8, bty='n')

dev.off()

echo -n "rpm" > ../results/coverage/rpm_vs_coverage.allsamples.txt;
for i in */accepted_hits.normalized.rpm_vs_coverage.txt; do echo -ne "\t"${i/\/*/} >> ../results/coverage/rpm_vs_coverage.allsamples.txt; done
echo '' >> ../results/coverage/rpm_vs_coverage.allsamples.txt
paste */accepted_hits.normalized.rpm_vs_coverage.txt | grep -v "#" | awk '{printf("%s", $1);i=2; while(i<=NF) {printf("\t%s",$i);i=i+2;} printf("\n");}' >> ../results/coverage/rpm_vs_coverage.allsamples.txt

pdf("~/neurogen/rnaseq_PD/results/coverage/rpm_vs_coverage.pdf", width=6, height=6)
RPM=read.table("/PHShome/xd010/neurogen/rnaseq_PD/results/coverage/rpm_vs_coverage.allsamples.txt", header=T);
rownames(RPM)=RPM[,1]; RPM=RPM[,-1, drop=F]
plot(RPM[,1], xlab="RPM", ylab="% of cummulative base pairs covered", xaxt='n',yaxt='n', main="all together", type="n", log="y", ylim=c(.005,100))
#sapply(1:ncol(RPM), function(x) lines(cumsum(RPM[,x])*100/3e9, col=x))
#legend("topleft", paste(colnames(RPM), "(",format(apply(RPM, 2, sum)*100/3e9,digits=3), ")"), col=1:ncol(RPM), lty=1, cex=.5, bty='n')
sapply(colnames(RPM), function(x) lines(cumsum(RPM[,x])*100/3e9, col=as.integer(sub(".*_([1-4])","\\1", x))))
legend("topleft", paste(colnames(RPM), "(",format(apply(RPM, 2, sum)*100/3e9,digits=3), ")"), col=1:ncol(RPM), lty=1, cex=.5, bty='n')
points(rep(nrow(RPM),ncol(RPM)), apply(RPM, 2, sum)*100/3e9, col=1:ncol(RPM))
axis(side=1, at=c(0:10)*10+1, labels=rownames(RPM)[c(0:10)*10+1])
axis(side = 2, at = (locs <- 100/c(1,10,100,1000)), labels = locs)
axis(side = 2, at = (locs2 <- c(outer(1:10, c(0.1, 1, 10, 100), "/"))), labels = NA, tcl = -0.3)
dev.off()

#################################
# combined bigwig, using unionBedGraphs in bedtools
#################################
mkdir ~/neurogen/rnaseq_PD/results/merged
cd ~/neurogen/rnaseq_PD/results/merged
> .paraFile;
# save the following code block to paraFile

## version 1: mean of all samples

# multi-mapper
#unionBedGraphs -i `ls ../../run_output/HC*_MCPY_[234]/*normalized.bedGraph` | awk '{OFS="\t"; s=0; for(i=4;i<=NF;i++) s=s+$i; s=s/(NF-3); print $1,$2,$3,s}' > HC_MCPY.mean.multi.normalized.bedGraph && bedGraphToBigWig HC_MCPY.mean.multi.normalized.bedGraph /data/neurogen/referenceGenome/Homo_sapiens/UCSC/hg19/Annotation/Genes/ChromInfo.txt HC_MCPY.mean.multi.normalized.bw
#unionBedGraphs -i `ls ../../run_output/PD*_SNDA_[234]/*normalized.bedGraph` | awk '{OFS="\t"; s=0; for(i=4;i<=NF;i++) s=s+$i; s=s/(NF-3); print $1,$2,$3,s}' > PD_SNDA.mean.multi.normalized.bedGraph && bedGraphToBigWig PD_SNDA.mean.multi.normalized.bedGraph /data/neurogen/referenceGenome/Homo_sapiens/UCSC/hg19/Annotation/Genes/ChromInfo.txt PD_SNDA.mean.multi.normalized.bw
#unionBedGraphs -i `ls ../../run_output/HC*_SNDA_[234]/*normalized.bedGraph` | awk '{OFS="\t"; s=0; for(i=4;i<=NF;i++) s=s+$i; s=s/(NF-3); print $1,$2,$3,s}' > HC_SNDA.mean.multi.normalized.bedGraph && bedGraphToBigWig HC_SNDA.mean.multi.normalized.bedGraph /data/neurogen/referenceGenome/Homo_sapiens/UCSC/hg19/Annotation/Genes/ChromInfo.txt HC_SNDA.mean.multi.normalized.bw
#unionBedGraphs -i `ls ../../run_output/ILB*_SNDA_[234]/*normalized.bedGraph` | awk '{OFS="\t"; s=0; for(i=4;i<=NF;i++) s=s+$i; s=s/(NF-3); print $1,$2,$3,s}' > ILB_SNDA.mean.multi.normalized.bedGraph && bedGraphToBigWig ILB_SNDA.mean.multi.normalized.bedGraph /data/neurogen/referenceGenome/Homo_sapiens/UCSC/hg19/Annotation/Genes/ChromInfo.txt ILB_SNDA.mean.multi.normalized.bw

# uniq-mapper
unionBedGraphs -i `ls ../../run_output/HC*_MCPY_[234]/uniq/*normalized.bedGraph` | awk '{OFS="\t"; s=0; for(i=4;i<=NF;i++) s=s+$i; s=s/(NF-3); print $1,$2,$3,s}' > HC_MCPY.mean.uniq.normalized.bedGraph && bedGraphToBigWig HC_MCPY.mean.uniq.normalized.bedGraph /data/neurogen/referenceGenome/Homo_sapiens/UCSC/hg19/Annotation/Genes/ChromInfo.txt HC_MCPY.mean.uniq.normalized.bw
unionBedGraphs -i `ls ../../run_output/PD*_SNDA_[234]/uniq/*normalized.bedGraph` | awk '{OFS="\t"; s=0; for(i=4;i<=NF;i++) s=s+$i; s=s/(NF-3); print $1,$2,$3,s}' > PD_SNDA.mean.uniq.normalized.bedGraph && bedGraphToBigWig PD_SNDA.mean.uniq.normalized.bedGraph /data/neurogen/referenceGenome/Homo_sapiens/UCSC/hg19/Annotation/Genes/ChromInfo.txt PD_SNDA.mean.uniq.normalized.bw
unionBedGraphs -i `ls ../../run_output/HC*_SNDA_[234]/uniq/*normalized.bedGraph` | awk '{OFS="\t"; s=0; for(i=4;i<=NF;i++) s=s+$i; s=s/(NF-3); print $1,$2,$3,s}' > HC_SNDA.mean.uniq.normalized.bedGraph && bedGraphToBigWig HC_SNDA.mean.uniq.normalized.bedGraph /data/neurogen/referenceGenome/Homo_sapiens/UCSC/hg19/Annotation/Genes/ChromInfo.txt HC_SNDA.mean.uniq.normalized.bw
unionBedGraphs -i `ls ../../run_output/ILB*_SNDA_[234]/uniq/*normalized.bedGraph` | awk '{OFS="\t"; s=0; for(i=4;i<=NF;i++) s=s+$i; s=s/(NF-3); print $1,$2,$3,s}' > ILB_SNDA.mean.uniq.normalized.bedGraph && bedGraphToBigWig ILB_SNDA.mean.uniq.normalized.bedGraph /data/neurogen/referenceGenome/Homo_sapiens/UCSC/hg19/Annotation/Genes/ChromInfo.txt ILB_SNDA.mean.uniq.normalized.bw

# version 2: median of all samples

unionBedGraphs -i `ls ../../run_output/HC*_MCPY_[234]/uniq/*normalized.bedGraph` | awk 'function median(v) {c=asort(v,j);  if (c % 2) return j[(c+1)/2]; else return (j[c/2+1]+j[c/2])/2.0; } {OFS="\t"; n=1; for(i=4;i<=NF;i++) S[n++]=$i; print $1,$2,$3, median(S)}' > HC_MCPY.median.uniq.normalized.bedGraph && bedGraphToBigWig HC_MCPY.median.uniq.normalized.bedGraph /data/neurogen/referenceGenome/Homo_sapiens/UCSC/hg19/Annotation/Genes/ChromInfo.txt HC_MCPY.median.uniq.normalized.bw
unionBedGraphs -i `ls ../../run_output/PD*_SNDA_[234]/uniq/*normalized.bedGraph` | awk 'function median(v) {c=asort(v,j);  if (c % 2) return j[(c+1)/2]; else return (j[c/2+1]+j[c/2])/2.0; } {OFS="\t"; n=1; for(i=4;i<=NF;i++) S[n++]=$i; print $1,$2,$3, median(S)}' > PD_SNDA.median.uniq.normalized.bedGraph && bedGraphToBigWig PD_SNDA.median.uniq.normalized.bedGraph /data/neurogen/referenceGenome/Homo_sapiens/UCSC/hg19/Annotation/Genes/ChromInfo.txt PD_SNDA.median.uniq.normalized.bw
unionBedGraphs -i `ls ../../run_output/HC*_SNDA_[234]/uniq/*normalized.bedGraph` | awk 'function median(v) {c=asort(v,j);  if (c % 2) return j[(c+1)/2]; else return (j[c/2+1]+j[c/2])/2.0; } {OFS="\t"; n=1; for(i=4;i<=NF;i++) S[n++]=$i; print $1,$2,$3, median(S)}' > HC_SNDA.median.uniq.normalized.bedGraph && bedGraphToBigWig HC_SNDA.median.uniq.normalized.bedGraph /data/neurogen/referenceGenome/Homo_sapiens/UCSC/hg19/Annotation/Genes/ChromInfo.txt HC_SNDA.median.uniq.normalized.bw
unionBedGraphs -i `ls ../../run_output/ILB*_SNDA_[234]/uniq/*normalized.bedGraph` | awk 'function median(v) {c=asort(v,j);  if (c % 2) return j[(c+1)/2]; else return (j[c/2+1]+j[c/2])/2.0; } {OFS="\t"; n=1; for(i=4;i<=NF;i++) S[n++]=$i; print $1,$2,$3, median(S)}' > ILB_SNDA.median.uniq.normalized.bedGraph && bedGraphToBigWig ILB_SNDA.median.uniq.normalized.bedGraph /data/neurogen/referenceGenome/Homo_sapiens/UCSC/hg19/Annotation/Genes/ChromInfo.txt ILB_SNDA.median.uniq.normalized.bw

# version 3: trimmed mean (10%)

unionBedGraphs -i `ls ../../run_output/HC*_MCPY_[234]/uniq/*normalized.bedGraph` | awk 'function trimmedMean(v, p) {c=asort(v,j); a=int(c*p); s=0; for(i=a+1;i<=(c-a);i++) s+=j[i];return s/(c-2*a);} {OFS="\t"; n=1; for(i=4;i<=NF;i++) S[n++]=$i; print $1,$2,$3, trimmedMean(S, 0.1)}' > HC_MCPY.trimmedmean.uniq.normalized.bedGraph && bedGraphToBigWig HC_MCPY.trimmedmean.uniq.normalized.bedGraph /data/neurogen/referenceGenome/Homo_sapiens/UCSC/hg19/Annotation/Genes/ChromInfo.txt HC_MCPY.trimmedmean.uniq.normalized.bw
unionBedGraphs -i `ls ../../run_output/PD*_SNDA_[234]/uniq/*normalized.bedGraph` | awk 'function trimmedMean(v, p) {c=asort(v,j); a=int(c*p); s=0; for(i=a+1;i<=(c-a);i++) s+=j[i];return s/(c-2*a);} {OFS="\t"; n=1; for(i=4;i<=NF;i++) S[n++]=$i; print $1,$2,$3, trimmedMean(S, 0.1)}' > PD_SNDA.trimmedmean.uniq.normalized.bedGraph && bedGraphToBigWig PD_SNDA.trimmedmean.uniq.normalized.bedGraph /data/neurogen/referenceGenome/Homo_sapiens/UCSC/hg19/Annotation/Genes/ChromInfo.txt PD_SNDA.trimmedmean.uniq.normalized.bw
unionBedGraphs -i `ls ../../run_output/HC*_SNDA_[234]/uniq/*normalized.bedGraph` | awk 'function trimmedMean(v, p) {c=asort(v,j); a=int(c*p); s=0; for(i=a+1;i<=(c-a);i++) s+=j[i];return s/(c-2*a);} {OFS="\t"; n=1; for(i=4;i<=NF;i++) S[n++]=$i; print $1,$2,$3, trimmedMean(S, 0.1)}' > HC_SNDA.trimmedmean.uniq.normalized.bedGraph && bedGraphToBigWig HC_SNDA.trimmedmean.uniq.normalized.bedGraph /data/neurogen/referenceGenome/Homo_sapiens/UCSC/hg19/Annotation/Genes/ChromInfo.txt HC_SNDA.trimmedmean.uniq.normalized.bw
unionBedGraphs -i `ls ../../run_output/ILB*_SNDA_[234]/uniq/*normalized.bedGraph` | awk 'function trimmedMean(v, p) {c=asort(v,j); a=int(c*p); s=0; for(i=a+1;i<=(c-a);i++) s+=j[i];return s/(c-2*a);} {OFS="\t"; n=1; for(i=4;i<=NF;i++) S[n++]=$i; print $1,$2,$3, trimmedMean(S, 0.1)}' > ILB_SNDA.trimmedmean.uniq.normalized.bedGraph && bedGraphToBigWig ILB_SNDA.trimmedmean.uniq.normalized.bedGraph /data/neurogen/referenceGenome/Homo_sapiens/UCSC/hg19/Annotation/Genes/ChromInfo.txt ILB_SNDA.trimmedmean.uniq.normalized.bw

ParaFly -c .paraFile -CPU 8

for i in *uniq*bedGraph; do echo $i; awk 'BEGIN{max=100; UNIT=0.01; OFS="\t";}{if($0~/^#/) {print; next;} i=int($4/UNIT);if(i>max) i=max; rpm[i]+=($3-$2);}END{for(x=max;x>=0;x--) print x*UNIT, rpm[x]?rpm[x]:0;}' $i >${i/bedGraph/rpm_vs_coverage.txt} &  done

for i in *txt; do echo $i; awk '{s=s+$2}END{print s*100/3095693983}' $i; done
 
unionBedGraphs -i `ls *_merged.normalized.bedGraph` | awk '{OFS="\t"; s=0; for(i=4;i<=NF;i++) s=s+$i; s=s/(NF-3); print $1,$2,$3,s}' > ALL.merged.normalized.bedGraph
awk 'BEGIN{max=100; UNIT=0.1; OFS="\t";}{if($0~/^#/) {print; next;} i=int($4/UNIT);if(i>max) i=max; rpm[i]+=($3-$2);}END{for(x=max;x>=0;x--) print x*UNIT, rpm[x];}' ALL.merged.normalized.bedGraph > ALL.merged.normalized.rpm_vs_coverage.txt
