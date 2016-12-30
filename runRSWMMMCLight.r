## Derived from RunRSWMM,  Developed by Peter Steinberg of Herrera Env.

## Version 0: December 2016


rm(list=ls())
## Edit this source line to reflect where you have saved RSWMM.r.
source("C:\\Users\\95218\\Documents\\R\\RSWMM-master\\RSWMMMC.r")

parFile <- paste0(calDataPath, "testingData\\parRangesMC.csv")
parametersTable <- getParmeterBounds(parFile)
mc <- {}
mc$functionCallToEvalForASWMMTimeSeries <-
    paste0('getSWMMTimeSeriesData(headObj=headObj, iType=3, ',
           'nameInOutputFile="",vIndex=4)')

## Put the parameter bounds and intialization in the optimization options:
##   you shouldn't need to change these lines if you have imported them
##   using RSWMM formats/functions
mc$lower <- c(as.vector(parametersTable["Minimum"]))$Minimum
mc$upper <- c(as.vector(parametersTable["Maximum"]))$Maximum
mc$baseOutputName <-
    paste0(calDataPath, "testingData\\MCTest1\\")
mc$SWMMTemplateFile <- paste0(calDataPath,
                                    "baseModelFormat.inp")
mc$SWMMexe <- "C:\\Program Files (x86)\\EPA SWMM 5.1\\swmm5.exe"
mc$performanceStat <- "vestigal"
setwd(dirname(mc$SWMMTemplateFile))

out <- runMC(iters=3, controlList=mc, parT=parametersTable)


####
####

if(useOptim) {
    out <- optim(optimOpt$initial, fn=objectiveFunction, gr=NULL,
                 baseOutputName=optimOpt$baseOutputName,
                 SWMMTemplateFile=optimOpt$SWMMTemplateFile,
                 SWMMexe=optimOpt$SWMMexe,
                 functionCallToEvalForASWMMTimeSeries=
                     optimOpt$functionCallToEvalForASWMMTimeSeries,
                 performanceStat=optimOpt$performanceStat,
                 method=optimOpt$method,
                 lower=optimOpt$lower, upper=optimOpt$upper,
                 control=list(maxit=10, REPORT=12), hessian=FALSE)
}

#############################################################################
#########################End of Single Objective Calibration Section#########
#############################################################################


#############################################################################
######################### Start of Multiobjective Optimization ##############
#############################################################################
## If you are doing single objective optimization by setting useOptim to
##   TRUE, this section is ignored.

## Initialize the multiobjective optimization options object
mcoOpt <- {}
## Look at the documentation in RSWMM.R for the getSWMMTimeSeriesData
##   function to develop a function call that returns your time series
##   of interest from the SWMM binary file
## A few notes on this funtion:
##   you always have to pass in headobj=headobj.  This is so that you don't
##   reread the header on every iteration
## You select an iType, which determines whether you are looking for a node,
##   link, subcatchment, or system variable
## You provide a vIndex, which is the parameter you want to return
##   (e.g. depth)
## You provide the nameInOutputFile.  This will be the same as the node,
##   link, or subcatchment number in the input file.
## If you are getting a system variable's results, you can leave
##   nameInOutputFile as ""
## You should provide a function call in quotes that will subsequently be
##   evaled in the objective function
mcoOpt$functionCallToEvalForASWMMTimeSeries <- 'getSWMMTimeSeriesData(headObj=headObj,iType=3,nameInOutputFile="",vIndex=4)'
## Provide upper and lower bounds.  No need to edit these lines if you have
##   imported parameters using RSWMM functions/formats
mcoOpt$lower <- c(as.vector(parametersTable["Minimum"]))$Minimum
mcoOpt$upper <- c(as.vector(parametersTable["Maximum"]))$Maximum
## Provide path to SWMM.exe
mcoOpt$SWMMexe <- "C:\\Program Files (x86)\\EPA SWMM 5.0\\SWMM5.exe"
## Select one or more performance stats listed in RSWMM.R
mcoOpt$performanceStats <- c("sumOfSquaredError",
                             "linearCorrelationTimesMinus1")
## Provide a base output name for SWMM input/output files
mcoOpt$baseOutputName <- "O:\\departments\\Water Quality\\Users\\Peter\\programs\\RSWMM\\testingData\\OptTest1\\Opt Ex1 Post"
## Provide a path to your SWMM template file with replacement codes in it
mcoOpt$SWMMTemplateFile <- "O:\\departments\\Water Quality\\Users\\Peter\\programs\\RSWMM\\testingData\\Example1-Post.inp"
## Set the working directory in R to be the directory of the swmm template
##   so that LID reports
## Show up in the right place #this is a 1/24/2012 edit
setwd(dirname(mcoOpt$SWMMTemplateFile))

## This is the function call to NSGA2.  Change this if you want to further
##   control the process.  (See the documentation for mco package: NSGS2
##   function)
if(useMCO) {
    library(mco)
    out <- nsga2(objectiveFunction,
            idim=length(mcoOpt$lower),
            odim=length(mcoOpt$performanceStats),
            baseOutputName= mcoOpt$baseOutputName,
            SWMMTemplateFile=mcoOpt$SWMMTemplateFile,
            SWMMexe=mcoOpt$SWMMexe,
            functionCallToEvalForASWMMTimeSeries=mcoOpt$functionCallToEvalForASWMMTimeSeries,
            performanceStat=mcoOpt$performanceStats,
            generations=500,
            lower.bounds=as.real(mcoOpt$lower),
            upper.bounds=as.real(mcoOpt$upper),
            constraints=NULL)
}
#############################################################################
########################END of multiobjective optimization###################
#############################################################################
