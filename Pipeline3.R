removeOut<-function(dat,f1)
{
        t<-dat[,1]
        m<-dat[,2]
        P<-1/f1
        fold<-(t-t[1])%%(P) / P
        fold<-c(fold,fold+1)
        m<-rep(m,2)
        m2<-m[order(fold)]
        fold2<-fold[order(fold)]
        ss<-smooth.spline(fold2,m2,spar=0.8)
        smooth<-predict(ss,fold2)$y
        res<-m2-smooth
        med_mag = median(res)
        mad = median(abs(res-med_mag))
        sigmamad=1.4826*mad
        rm<-c(which(abs(res)>4*sigmamad))
        rm1<-rm[which(rm %in% (length(t)-trunc(length(t)/2)):(length(t)+trunc(length(t)/2)))]
        rm2<-which(fold %in% fold2[rm1])
        curvestmp<-dat
        if(length(rm2)>0)
        {
               for(j in 1:length(rm2))
               {
                        rm2[j]<-ifelse(rm2[j]>length(t),rm2[j]-length(t),rm2[j])
               }
               rm2<-rm2[order(rm2)]
               curvestmp<-curvestmp[-rm2,]
        }
        #cat(length(rm2),"\n")
        return(curvestmp)
}

args = commandArgs(trailingOnly=TRUE)
setwd(args[2])
require('adabag')
load("Boost1b295T.Rdata")
source('newfeatures.R')
setwd(args[1])
files<-list.files()
l1<-length(files)
for(i in 1:l1){
      setwd(args[1])
      curvestmp<-read.table(as.character(files[i]),header=T)
      merr<-curvestmp[,3]
      meanerr<-mean(merr)
      sderr<-sd(merr)
      #Remove Observation with error > 5sd
      lim1<-meanerr-5*sderr
      lim2<-meanerr+5*sderr
      p<-which(merr>=lim1 & merr<=lim2)
      p1<-c(1:dim(curvestmp)[1])[-p]
      curvestmp1<-curvestmp
      if(length(p1)>0)
                curvestmp1<-curvestmp[-p1,]
      setwd(args[2])
      namefile<-paste("Aux.txt",sep="")
      write.table(curvestmp1,file=namefile,sep=" ",row.names=F)
      system('sh Pipeline.sh')
      python<-paste('python',' ',args[2],'/Pipeline.py',' ',args[2],'/Aux.txt',sep='')
      system(python)
      system('rm gls_results.dat')
      feat1<-read.table("Aux3.dat")
      y1<-read.table("Aux2.txt")[,2]
      f1<-feat1[3]
      z<-1
      #Remove Outliers of the Smoothed Light Curves
      while (z>0)
      {
        n<-dim(curvestmp1)[1]
        curvestmp1<-removeOut(curvestmp1,as.numeric(f1))
        write.table(curvestmp1,file=namefile,sep=" ",row.names=F)
        if(n==dim(curvestmp1)[1] || z==5) break;
        z<-z+1
        system('sh Pipeline.sh')
        system(python)
        system('rm gls_results.dat')
        feat1<-read.table("Aux3.dat")
        f1<-feat1[3]
        print(f1)
      }
      A<-feat1[5:8]
      Per1<-as.numeric(1/f1[1])
      Per2<-as.numeric(2/f1[1])
      t<-curvestmp1[,1]
      m<-curvestmp1[,2]
      merr<-curvestmp1[,3]
      mod1<-(t-t[1])%%(Per1)/Per1
      mod2<-(t-t[1])%%(Per2)/Per2
      nf<-newfeatures(t,m,y1,mod1,mod2)
      nf1<-nf[c(2,4,5)]
      feat2<-as.numeric(feat1[c(3,4,5,6:8,11:13)])
      namefile<-as.character(files[i])
      data<-c(feat2,nf1)
      names(data)=c('f1','P1','s','A.1.1.','A.1.2.','A.1.3.','PH.1.2.','PH.1.3.','PH.1.4.','p2p_s2p','p2p_spfom','R1')
      #scaledcenter=c(2.08903299,0.667636758,0.407773145,0.861941432,0.804323522,0.555676838,-1.03569846,0.530600377,-0.167982989,1.04190993,0.566092041,0.733884692,0.933313694)
      #scaledscale=c(1.14528766,0.184756785,0.563318801,5.59068576,5.75589971,3.96061599,1.67108291,1.84534392,1.61932546,0.171030714,0.384441658,0.355556473,1.04285747)
      scaledcenter=c(2.20419791,0.58316835,0.22256868,1.14797854,1.08785499,0.69604576,-0.73829800,0.36068416,-0.04780175,0.61531421,0.86620003,1.07678649)
      scaledscale=c(1.3867306,0.1849104,0.5888737,6.6643389,7.0476145,4.6081509,1.7441640,1.8253404,1.7122191,0.3267595,0.3381003,1.1971613)
      data1<-scale(matrix(data,1,12),center=scaledcenter,scale=scaledscale)
      names(data1)=c('f1','P1','s','A.1.1.','A.1.2.','A.1.3.','PH.1.2.','PH.1.3.','PH.1.4.','p2p_s2p','p2p_spfom','R1')
      data1<-data1[c(4:9,1:3,10:12)]
      test1<-rbind(c(0,data1),c(1,data1))
      test1[1]<-as.factor(test1[1])
      prob_boost1<-predict(boost1,test1)$prob
      prob_rrl<-prob_boost1[1,2]
      isrrab<-ifelse(prob_rrl>0.548,'RRab','Other')
      final<-c(namefile,data,prob_rrl,isrrab)
      names(final)[c(1,14)]<-c('namefile','prob_rrl','isrrab')
      write(t(final),file=paste('Final5.txt',sep=''),append=TRUE,ncolumns=15)
      system('rm Aux*')
}