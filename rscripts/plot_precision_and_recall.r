library(ggplot2)
library(tidyr)
setwd("~/github/aligner_benchmark/rscripts")


cols <- c('character','character','character','character','character','character',
          'numeric')
d = read.csv("../test_file", head =T,sep = "\t", colClasses = cols)
d$mean = rep(0,dim(d)[1])
d$sd = rep(0,dim(d)[1])

for (i in 1:dim(d)[1]) {
  #print(i)
  d$mean[i] = mean(d[d$dataset == d$dataset[i] & d$algorithm == d$algorithm[i] & d$measurement == d$measurement[i] & d$level == d$level[i],]$value)
  d$sd[i] = sd(d[d$dataset == d$dataset[i] & d$algorithm == d$algorithm[i] & d$measurement == d$measurement[i] & d$level == d$level[i],]$value) 
}
l  = spread(d[,c("species","dataset","replicate","level","algorithm","measurement","mean")], measurement, mean)
#ggplot(d[d$algorithm %in% c("contextmap2","crac","cracnoambiguity","gsnap",
#          "hisat", "mapsplice2", "novoalign", "olego","olegotwopass","rum",                                                    
#          "soapsplice", "star", "staronepass", "subread",
#          "tophat2coveragesearch-bowtie2sensitive",
#          "tophat2coveragesearch",
#          "tophat2nocoveragesearch-bowtie2sensitive",
#          "tophat2nocoveragesearch-bowtie2sensitive-testNoMateDist"),]
ggplot(l[l$algorithm %in% c("contextmap2","cracnoambiguity","gsnap",
                            "hisat", "mapsplice2", "novoalign","olegotwopass","rum",                                                    
                            "soapsplice", "star", "subread",
                            "tophat2coveragesearch-bowtie2sensitive") &
           l$replicate == "r1" & l$level == "READ",]
       , aes(x =precision , y= recall, color=factor(algorithm)),stat="identity") + 
  coord_cartesian(ylim=c(-0.05,1.05),xlim = c(-0.05,1.05)) + 
  #geom_bar(stat="identity",position="dodge")  + 
  #geom_errorbar(aes(ymin = mean-sd, ymax = mean+sd), position="dodge") +
  geom_jitter( position = position_jitter(height = .008,width=.008),alpha=0.95,size=6) + 
  facet_grid(. ~ dataset) + scale_color_brewer(palette="Paired")  +  ggtitle("human read level")


ggplot(l[l$algorithm %in% c("contextmap2","cracnoambiguity","gsnap",
                            "hisat", "mapsplice2", "novoalign","olegotwopass","rum",                                                    
                            "soapsplice", "star", "subread",
                            "tophat2coveragesearch-bowtie2sensitive") &
           l$replicate == "r1" & l$level == "BASE",]
       , aes(x =precision , y= recall, color=factor(algorithm)),stat="identity") + 
  coord_cartesian(ylim=c(-0.05,1.05),xlim = c(-0.05,1.05)) + 
  #geom_bar(stat="identity",position="dodge")  + 
  #geom_errorbar(aes(ymin = mean-sd, ymax = mean+sd), position="dodge") +
  geom_jitter( position = position_jitter(height = .008,width=.008),alpha=0.95,size=6) + 
  facet_grid(. ~ dataset) + scale_color_brewer(palette="Paired")  +  ggtitle("human base level")


ggplot(l[l$algorithm %in% c("contextmap2","cracnoambiguity","gsnap",
                            "hisat", "mapsplice2", "novoalign","olegotwopass","rum",                                                    
                            "soapsplice", "star", "subread",
                            "tophat2coveragesearch-bowtie2sensitive") &
           l$replicate == "r1" & l$level == "BASE",]
       , aes(x =insertions_precision , y= insertions_recall, color=factor(algorithm)),stat="identity") + 
  coord_cartesian(ylim=c(-0.05,1.05),xlim = c(-0.05,1.05)) + 
  #geom_bar(stat="identity",position="dodge")  + 
  #geom_errorbar(aes(ymin = mean-sd, ymax = mean+sd), position="dodge") +
  geom_jitter( position = position_jitter(height = .008,width=.008),alpha=0.95,size=6) + 
  facet_grid(. ~ dataset) + scale_color_brewer(palette="Paired")  +  ggtitle("insertions - human base level")

ggplot(l[l$algorithm %in% c("contextmap2","cracnoambiguity","gsnap",
                            "hisat", "mapsplice2", "novoalign","olegotwopass","rum",                                                    
                            "soapsplice", "star", "subread",
                            "tophat2coveragesearch-bowtie2sensitive") &
           l$replicate == "r1" & l$level == "BASE",]
       , aes(x =deletions_precision , y= deletions_recall, color=factor(algorithm)),stat="identity") + 
  coord_cartesian(ylim=c(-0.05,1.05),xlim = c(-0.05,1.05)) + 
  #geom_bar(stat="identity",position="dodge")  + 
  #geom_errorbar(aes(ymin = mean-sd, ymax = mean+sd), position="dodge") +
  geom_jitter( position = position_jitter(height = .008,width=.008),alpha=0.95,size=6) + 
  facet_grid(. ~ dataset) + scale_color_brewer(palette="Paired")  +  ggtitle("deletions - human base level")


ggplot(l[l$algorithm %in% c("contextmap2","cracnoambiguity","gsnap",
                            "hisat", "mapsplice2", "novoalign","olegotwopass","rum",                                                    
                            "soapsplice", "star", "subread",
                            "tophat2coveragesearch-bowtie2sensitive") &
           l$replicate == "r1" & l$level == "JUNC",]
       , aes(x =precision , y= recall, color=factor(algorithm)),stat="identity") + 
  coord_cartesian(ylim=c(-0.05,1.05),xlim = c(-0.05,1.05)) + 
  #geom_bar(stat="identity",position="dodge")  + 
  #geom_errorbar(aes(ymin = mean-sd, ymax = mean+sd), position="dodge") +
  geom_jitter( position = position_jitter(height = .008,width=.008),alpha=0.95,size=6) + 
  facet_grid(. ~ dataset) + scale_color_brewer(palette="Paired")  +  ggtitle("human junction level")
  
df <- data.frame(x = 1:10,
                   y = 1:10,
                   ymin = (1:10) - runif(10),
                   ymax = (1:10) + runif(10),
                   xmin = (1:10) - runif(10),
                   xmax = (1:10) + runif(10))

ggplot(data = df,aes(x = x,y = y)) + 
  geom_point() + 
  geom_errorbar(aes(ymin = ymin,ymax = ymax)) + 
  geom_errorbarh(aes(xmin = xmin,xmax = xmax))

cols <- c('character','character','character','character','character', 'numeric','numeric','integer','character',
          'numeric','numeric', 'character')
d = read.csv("results_IVT.txt",header = T,sep = "\t",na.strings = "NaN",colClasses = cols)
d$DataSet[d$DataSet == "Spikeins"] = "Simulated"

# With gene models fig6
ggplot(d[d$NumOfSpliceforms %in% c(0) &
           #d$Aligner == "none" &
           d$GeneModels == "true",]) +
  geom_rect(aes(xmax=0.67,xmin=0,ymax=1,ymin=0),fill = rgb(1,.91,.91)) +
  geom_rect(aes(xmax=1,xmin=0.67,ymax=0.25,ymin=0),fill = rgb(1,.91,.91)) +
  
  facet_grid(. ~ DataSet) +
  geom_vline(xintercept=seq(0.00, 1.00, by=0.25),color="gray86",size=.5) +
  geom_hline(yintercept=seq(0.00, 1.00, by=0.25),color="gray86",size=.5)+
  geom_vline(xintercept=seq(0.00, 1.00, by=1/8),color="gray86",size=.1) +
  geom_hline(yintercept=seq(0.00, 1.00, by=1/8),color="gray86",size=.1)+
  theme_bw(base_size = 18)+
  #theme_bw()  +
  facet_grid(. ~ DataSet) +
  #scale_fill_manual(values = alpha(rgb(1,.9,.9), c(.003,.003)))+
  
  geom_jitter(aes(x=Precision , y=Recall, color=factor(Algorithm),shape=factor(Aligner)), position = position_jitter(height = .008,width=.008),alpha=0.95,size=6) +
  
  scale_shape_manual(values=c(17,15,3),name="Aligner: ")+
  scale_color_manual(values=c("blue","red","black","darkgreen","orange","purple","turquoise1","yellow"), name="Algorithm: ") +
  #scale_size_manual(labels=c("1-10X","10-100X","100X and more"),values=c(3,5,7),breaks=c(0,1,2),name="X coverage") +
  theme(legend.position = "bottom") + ggtitle("With gene models")+ scale_y_continuous(limits=c(-0.01, 1.01)) + scale_x_continuous(limits=c(-0.1, 1.01)) +
  guides(shape = guide_legend(override.aes = list(size=6)),color= guide_legend(override.aes = list(size=6)))+ theme(text = element_text(size=15))

#PolyA
k = d[d$NumOfSpliceforms %in% c(0) &
        #d$Aligner == "none" &
        d$GeneModels == "true",]

gat = spread(k[k$DataSet == "PolyA" ,c("Algorithm","Aligner","Recall")],Aligner, Recall)
colnames(gat) = c("Recall","STAR","Tophat2")
write.table(gat, "IVT_PolyA_With_Anno.txt",sep="\t",row.names = FALSE, col.names = TRUE, append = FALSE)
gat = spread(k[k$DataSet == "PolyA" ,c("Algorithm","Aligner","Precision")],Aligner, Precision)
colnames(gat) = c("Precision","STAR","Tophat2")
write.table(gat, "IVT_PolyA_With_Anno.txt",sep="\t",row.names = FALSE, col.names = TRUE, append = TRUE)

#Ribo
gat = spread(k[k$DataSet == "Ribo" ,c("Algorithm","Aligner","Recall")],Aligner, Recall)
colnames(gat) = c("Recall","STAR","Tophat2")
write.table(gat, "IVT_Ribo_With_Anno.txt",sep="\t",row.names = FALSE, col.names = TRUE, append = FALSE)
gat = spread(k[k$DataSet == "Ribo" ,c("Algorithm","Aligner","Precision")],Aligner, Precision)
colnames(gat) = c("Precision","STAR","Tophat2")
write.table(gat, "IVT_Ribo_With_Anno.txt",sep="\t",row.names = FALSE, col.names = TRUE, append = TRUE)

#Simulated
gat = spread(k[k$DataSet == "Simulated" ,c("Algorithm","Aligner","Recall")],Aligner, Recall)
colnames(gat) = c("Recall","STAR","Tophat2","Simulated")
write.table(gat, "IVT_Simulated_With_Anno.txt",sep="\t",row.names = FALSE, col.names = TRUE, append = FALSE)
gat = spread(k[k$DataSet == "Simulated" ,c("Algorithm","Aligner","Precision")],Aligner, Precision)
colnames(gat) = c("Precision","STAR","Tophat2","Simulated")
write.table(gat, "IVT_Simulated_With_Anno.txt",sep="\t",row.names = FALSE, col.names = TRUE, append = TRUE)

# figS13
ggplot(d[d$NumOfSpliceforms %in% c(0) &
           #d$Aligner == "none" &
           d$GeneModels == "false",]) +
  geom_rect(aes(xmax=0.67,xmin=0,ymax=1,ymin=0),fill = rgb(1,.91,.91)) +
  geom_rect(aes(xmax=1,xmin=0.67,ymax=0.25,ymin=0),fill = rgb(1,.91,.91)) +
  
  facet_grid(. ~ DataSet) +
  geom_vline(xintercept=seq(0.00, 1.00, by=0.25),color="gray86",size=.5) +
  geom_hline(yintercept=seq(0.00, 1.00, by=0.25),color="gray86",size=.5)+
  geom_vline(xintercept=seq(0.00, 1.00, by=1/8),color="gray86",size=.1) +
  geom_hline(yintercept=seq(0.00, 1.00, by=1/8),color="gray86",size=.1)+
  theme_bw(base_size = 18)+
  #theme_bw()  +
  facet_grid(. ~ DataSet) +
  #scale_fill_manual(values = alpha(rgb(1,.9,.9), c(.003,.003)))+
  
  geom_jitter(aes(x=Precision , y=Recall, color=factor(Algorithm),shape=factor(Aligner)), position = position_jitter(height = .008,width=.008),alpha=0.95,size=6) +
  scale_shape_manual(values=c(16,17,15,3),name="Aligner: ")+
  #scale_shape_manual(labels=c("0-10X","10-100X","100X and more"),values=c(15,16,16,16,16,17,17,17,17,18,18,18,18),breaks=c(1,2,6,11),name="Splice Event")+
  scale_color_manual(values=c("grey","blue","red","black","orange","purple","darkgreen","turquoise1","yellow","tan4","chartreuse"), name="Algorithm: ") +
  #scale_size_manual(labels=c("1-10X","10-100X","100X and more"),values=c(3,5,7),breaks=c(0,1,2),name="X coverage") +
  theme(legend.position = "bottom") + ggtitle("Without gene models")+ scale_y_continuous(limits=c(-0.01, 1.01)) + scale_x_continuous(limits=c(-0.1, 1.01)) +
  guides(shape = guide_legend(override.aes = list(size=6)),color= guide_legend(override.aes = list(size=6)))+ theme(text = element_text(size=15))

k = d[d$NumOfSpliceforms %in% c(0) &
        #d$Aligner == "none" &
        d$GeneModels == "false",]

#PolyA
gat = spread(k[k$DataSet == "PolyA" ,c("Algorithm","Aligner","Recall")],Aligner, Recall)
colnames(gat) = c("Recall","none","STAR","Tophat2")
write.table(gat, "IVT_PolyA_Without_Anno.txt",sep="\t",row.names = FALSE, col.names = TRUE, append = FALSE)
gat = spread(k[k$DataSet == "PolyA" ,c("Algorithm","Aligner","Precision")],Aligner, Precision)
colnames(gat) = c("Precision","none","STAR","Tophat2")
write.table(gat, "IVT_PolyA_Without_Anno.txt",sep="\t",row.names = FALSE, col.names = TRUE, append = TRUE)

#Ribo
gat = spread(k[k$DataSet == "Ribo" ,c("Algorithm","Aligner","Recall")],Aligner, Recall)
colnames(gat) = c("Recall","none","STAR","Tophat2")
write.table(gat, "IVT_Ribo_Without_Anno.txt",sep="\t",row.names = FALSE, col.names = TRUE, append = FALSE)
gat = spread(k[k$DataSet == "Ribo" ,c("Algorithm","Aligner","Precision")],Aligner, Precision)
colnames(gat) = c("Precision","none","STAR","Tophat2")
write.table(gat, "IVT_Ribo_Without_Anno.txt",sep="\t",row.names = FALSE, col.names = TRUE, append = TRUE)

#Simulated
gat = spread(k[k$DataSet == "Simulated" ,c("Algorithm","Aligner","Recall")],Aligner, Recall)
colnames(gat) = c("Recall","none","STAR","Tophat2","Truth")
write.table(gat, "IVT_Simulated_Without_Anno.txt",sep="\t",row.names = FALSE, col.names = TRUE, append = FALSE)
gat = spread(k[k$DataSet == "Simulated" ,c("Algorithm","Aligner","Precision")],Aligner, Precision)
colnames(gat) = c("Precision","none","STAR","Tophat2","Truth")
write.table(gat, "IVT_Simulated_Without_Anno.txt",sep="\t",row.names = FALSE, col.names = TRUE, append = TRUE)