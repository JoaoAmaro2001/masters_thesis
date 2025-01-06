%[IDX,C,sumd,D] = kmeans(clustdata,clus_num,'replicates',10,'emptyaction','drop');
[IDX,C,sumd,D] = kmeans(clustdata,clus_num,'replicates',100,'emptyaction','drop','MaxIter',10000);