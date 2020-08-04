## Derived from RunRSWMM,  Developed by Peter Steinberg of Herrera Env.

## Version 0: December 2016

library("viridis")
rm(list=ls())
## Edit this source line to reflect where you have saved RSWMM.r.
source("C:\\Users\\95218\\R\\RSWMM-master\\RSWMMMC.r")
calDataPath <-
    "C:\\Users\\95218\\OneDrive - City of Charlotte\\EPA SWMM Projects\\Base Model\\rswmm\\"
calDataCSV <- paste0(calDataPath, "flowtest.csv")
calDataObj <<- getCalDataFromCSV(CSVFile=calDataCSV)
parFile <- paste0(calDataPath, "testingData\\parRangesMC.csv")
parametersTable <- getParmeterBounds(parFile)
mc <- {}
## iType: 0 [sub],    1 [node],    2 [link], 3 [sys]
## vIndex
## sub:   0 [prcp],   1 [snowD],   2 [evap], 3 [fRate],  4 [qcfs], 5 [gwq],
##        6 [gwElev], 7 [soilMoi], 8 [TSS]
##
## node:  0 [dep],    1 [head],    2 [vol],  3 [latInf], 4 [totInf],
##        5 [flding], 6 [TSS]
##
## link:  0 [qcfs],   1 [dep],     2 [vel],  3 [vol],    4 [cap],  5 [tss]
##
## sys:   0 [temp],   1 [prcp],    2 [snow], 3 [fRate],  4 [qCfs], 5 [dwQ],
##        6 [gwQ],    7 [IIQ],     8 [dirQ], 9 [totQ],  10 [fld], 11 [outQ],
##       12 [str],   13 [evap],   14 [PET]
mc$functionCallToEvalForASWMMTimeSeries <-
    paste0('getSWMMTimeSeriesData(headObj=headObj, iType=0, ',
           'nameInOutputFile="sub5", vIndex=8)')
## Put the parameter bounds and intialization in the optimization options:
##   you shouldn't need to change these lines if you have imported them
##   using RSWMM formats/functions
mc$lower <- c(as.vector(parametersTable["Minimum"]))$Minimum
mc$upper <- c(as.vector(parametersTable["Maximum"]))$Maximum
mc$baseOutputName <-
    paste0(calDataPath, "testingData\\MCTest1\\")
mc$SWMMTemplateFile <- paste0(calDataPath,
                                    "baseModelFormat.inp")
mc$SWMMexe <- "C:\\Program Files (x86)\\EPA SWMM 5.1.013\\swmm5.exe"
mc$performanceStat <- "vestigal"
setwd(dirname(mc$SWMMTemplateFile))

## Run fun
out <- runMC(iters=10, controlList=mc, parT=parametersTable)

## plot results
out <- out+.001

options(scipen=5)

plot(out[,1], type="l", col=viridis(10)[4],
     ylim=c(0.001,10))
for (i in 2:dim(out)[2]) {
    lines(out[,i], col=viridis(10)[floor(runif(1,1,10))])
}
