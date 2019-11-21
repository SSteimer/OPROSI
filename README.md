# OPROSI
Software for analysing data recorded by an Online Particle-bound ROS Instrument (OPROSI)  

## Import of raw data: 
The folder ImportRawData contains the code for input of OPROSI raw data (PlotAllMark.m) as well as the associated example files (OPROSI signal data exported from LabVIEW in SignalFiles, HEPA filter data exported form LabVIEW in SignalFiles, Ctimes.m for manually selected periods of faulty data (e.g. pump issues, power outages) and Mtimes.m for periods of instrument maintainances).
Ctimes and Mtimes are datetime arrays where the start of each period is stored in column 1 and the end in the same line of column 2.  

Running PlotAllMark.m will:  
- import the raw OPROSI signal and the associated timestamp and as well as the status of the HEPA filter and associated timestamp from multiple raw files and stitch them together as one timeseries each  
- convert the LabVIEW timestamps to Matlab datetime format and correct for recording time delay  
- plot the imported data in a yyplot and mark time periods where the HEPA filter was on (red), the data was faulty (orange) and the instrument was down for maintainance (yellow)  
    
![ROSRawSignal](https://github.com/SSteimer/OPROSI/blob/master/ROSSignalRaw.png "ROS raw signal")

## Generating diurnal plots: 
The folder DiurnalPlot contains the code to generate diurnal plots of the ROS signal, converted to H2O2 equivalents [nmol/m3] as well as some cleaned up ROS example data (SignalAdjusted.mat).

![DiurnalPlot](https://github.com/SSteimer/OPROSI/blob/master/DiurnalPlot.png "Diurnal plot of the ROS signal [nmol/m3]")
