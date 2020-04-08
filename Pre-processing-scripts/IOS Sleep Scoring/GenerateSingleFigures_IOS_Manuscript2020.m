function [figHandle] = GenerateSingleFigures_IOS_Manuscript2020(procDataFileID,RestingBaselines,baselineType,saveFigs,imagingType,hemoType)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%________________________________________________________________________________________________________________________
%
% Purpose: Create a summary figure for a single n minute IOS trial
%________________________________________________________________________________________________________________________

% load file and gather information
load(procDataFileID)
[animalID,fileDate,fileID] = GetFileInfo_IOS_Manuscript2020(procDataFileID);
strDay = ConvertDate_IOS_Manuscript2020(fileDate);
% setup butterworth filter coefficients for a 1 Hz and 10 Hz lowpass based on the sampling rate
[z1,p1,k1] = butter(4,10/(ProcData.notes.dsFs/2),'low');
[sos1,g1] = zp2sos(z1,p1,k1);
[z2,p2,k2] = butter(4,1/(ProcData.notes.dsFs/2),'low');
[sos2,g2] = zp2sos(z2,p2,k2);
% whisker angle
filteredWhiskerAngle = filtfilt(sos1,g1,ProcData.data.whiskerAngle);
binWhiskers = ProcData.data.binWhiskerAngle;
% force sensor
filtForceSensor = filtfilt(sos1,g1,ProcData.data.forceSensor);
binForce = ProcData.data.binForceSensor;
% emg
EMG = ProcData.data.EMG.emg;
% heart rate
heartRate = ProcData.data.heartRate;
% solenoids
LPadSol = ProcData.data.solenoids.LPadSol;
RPadSol = ProcData.data.solenoids.RPadSol;
AudSol = ProcData.data.solenoids.AudSol;
% CBV data
if strcmp(imagingType,'bilateral') == true
    if strcmp(hemoType,'reflectance') == true
        LH_CBV = ProcData.data.CBV.adjLH;
        normLH_CBV = (LH_CBV - RestingBaselines.(baselineType).CBV.adjLH.(strDay))./(RestingBaselines.(baselineType).CBV.adjLH.(strDay));
        filtLH_CBV = (filtfilt(sos2,g2,normLH_CBV))*100;
                RH_CBV = ProcData.data.CBV.adjRH;
        normRH_CBV = (RH_CBV - RestingBaselines.(baselineType).CBV.adjRH.(strDay))./(RestingBaselines.(baselineType).CBV.adjRH.(strDay));
        filtRH_CBV = (filtfilt(sos2,g2,normRH_CBV))*100;
    elseif strcmp(hemoType,'HbT') == true
        LH_HbT = ProcData.data.HbT.adjLH;
        filtLH_HbT = filtfilt(sos2,g2,LH_HbT);
        RH_HbT = ProcData.data.HbT.adjRH;
        filtRH_HbT = filtfilt(sos2,g2,RH_HbT);
    end
elseif strcmp(imagingType,'single') == true
    if strcmp(hemoType,'reflectance') == true
        barrels_CBV = ProcData.data.CBV.adjBarrels;
        normBarrels_CBV = (barrels_CBV - RestingBaselines.(baselineType).CBV.adjBarrels.(strDay))./(RestingBaselines.(baselineType).CBV.adjBarrels.(strDay));
        filtBarrels_CBV = (filtfilt(sos2,g2,normBarrels_CBV))*100;
    elseif strcmp(hemoType,'HbT') == true
        barrels_HbT = ProcData.data.Hbt.adjBarrels;
        filtBarrels_HbT = filtfilt(sos2,g2,barrels_HbT);
    end
end
% cortical and hippocampal spectrograms
specDataFile = [animalID '_' fileID '_SpecDataA.mat'];
load(specDataFile, '-mat');
cortical_LHnormS = SpecData.cortical_LH.normS.*100;
cortical_RHnormS = SpecData.cortical_RH.normS.*100;
hippocampusNormS = SpecData.hippocampus.normS.*100;
T = SpecData.cortical_LH.T;
F = SpecData.cortical_LH.F;
% Yvals for behavior Indices
if strcmp(imagingType,'bilateral') == true
    if strcmp(hemoType,'reflectance') == true
        if max(filtLH_CBV) >= max(filtRH_CBV)
            whisking_Yvals = 1.10*max(filtLH_CBV)*ones(size(binWhiskers));
            force_Yvals = 1.20*max(filtLH_CBV)*ones(size(binForce));
            LPad_Yvals = 1.30*max(filtLH_CBV)*ones(size(LPadSol));
            RPad_Yvals = 1.30*max(filtLH_CBV)*ones(size(RPadSol));
            Aud_Yvals = 1.30*max(filtLH_CBV)*ones(size(AudSol));
        else
            whisking_Yvals = 1.10*max(filtRH_CBV)*ones(size(binWhiskers));
            force_Yvals = 1.20*max(filtRH_CBV)*ones(size(binForce));
            LPad_Yvals = 1.30*max(filtRH_CBV)*ones(size(LPadSol));
            RPad_Yvals = 1.30*max(filtRH_CBV)*ones(size(RPadSol));
            Aud_Yvals = 1.30*max(filtRH_CBV)*ones(size(AudSol));
        end
    elseif strcmp(hemoType,'HbT') == true
        if max(filtLH_HbT) >= max(filtRH_HbT)
            whisking_Yvals = 1.10*max(filtLH_HbT)*ones(size(binWhiskers));
            force_Yvals = 1.20*max(filtLH_HbT)*ones(size(binForce));
            LPad_Yvals = 1.30*max(filtLH_HbT)*ones(size(LPadSol));
            RPad_Yvals = 1.30*max(filtLH_HbT)*ones(size(RPadSol));
            Aud_Yvals = 1.30*max(filtLH_HbT)*ones(size(AudSol));
        else
            whisking_Yvals = 1.10*max(filtRH_HbT)*ones(size(binWhiskers));
            force_Yvals = 1.20*max(filtRH_HbT)*ones(size(binForce));
            LPad_Yvals = 1.30*max(filtRH_HbT)*ones(size(LPadSol));
            RPad_Yvals = 1.30*max(filtRH_HbT)*ones(size(RPadSol));
            Aud_Yvals = 1.30*max(filtRH_HbT)*ones(size(AudSol));
        end
    end
elseif strcmp(imagingType,'single') == true
    if strcmp(hemoType,'reflectance') == true
        whisking_Yvals = 1.10*max(filtBarrels_CBV)*ones(size(binWhiskers));
        force_Yvals = 1.20*max(filtBarrels_CBV)*ones(size(binForce));
        LPad_Yvals = 1.30*max(filtBarrels_CBV)*ones(size(LPadSol));
        RPad_Yvals = 1.30*max(filtBarrels_CBV)*ones(size(RPadSol));
        Aud_Yvals = 1.30*max(filtBarrels_CBV)*ones(size(AudSol));
    elseif strcmp(hemoType,'HbT') == true
        whisking_Yvals = 1.10*max(filtBarrels_HbT)*ones(size(binWhiskers));
        force_Yvals = 1.20*max(filtBarrels_HbT)*ones(size(binForce));
        LPad_Yvals = 1.30*max(filtBarrels_HbT)*ones(size(LPadSol));
        RPad_Yvals = 1.30*max(filtBarrels_HbT)*ones(size(RPadSol));
        Aud_Yvals = 1.30*max(filtBarrels_HbT)*ones(size(AudSol));
    end
end
whiskInds = binWhiskers.*whisking_Yvals;
forceInds = binForce.*force_Yvals;
for x = 1:length(whiskInds)
        % set whisk indeces
    if whiskInds(1,x) == 0
        whiskInds(1,x) = NaN;
    end
        % set force indeces
    if forceInds(1,x) == 0
        forceInds(1,x) = NaN;
    end
end
% Figure
figHandle = figure;
% force sensor and EMG
ax1 = subplot(6,1,1);
fileID2 = strrep(fileID,'_',' ');
plot((1:length(filtForceSensor))/ProcData.notes.dsFs,filtForceSensor,'color',colors_Manuscript2020('sapphire'),'LineWidth',1)
title([animalID ' IOS behavioral characterization and CBV dynamics for ' fileID2])
ylabel('Force Sensor (Volts)')
xlim([0,ProcData.notes.trialDuration_sec])
yyaxis right
plot((1:length(EMG))/ProcData.notes.dsFs,EMG,'color',colors_Manuscript2020('deep carrot orange'),'LineWidth',1)
ylabel('EMG (Volts^2)')
xlim([0,ProcData.notes.trialDuration_sec])
set(gca,'TickLength',[0,0])
set(gca,'Xticklabel',[])
set(gca,'box','off')
axis tight
% Whisker angle and heart rate
ax2 = subplot(6,1,2);
plot((1:length(filteredWhiskerAngle))/ProcData.notes.dsFs,-filteredWhiskerAngle,'color',colors_Manuscript2020('blue-green'),'LineWidth',1)
ylabel('Angle (deg)')
xlim([0,ProcData.notes.trialDuration_sec])
ylim([-20,60])
yyaxis right
plot((1:length(heartRate)),heartRate,'color',colors_Manuscript2020('dark sea green'),'LineWidth',1)
ylabel('Heart Rate (Hz)')
ylim([6,15])
set(gca,'TickLength',[0,0])
set(gca,'Xticklabel',[])
set(gca,'box','off')
axis tight
% CBV and behavioral indeces
ax3 = subplot(6,1,3);
if strcmp(imagingType,'bilateral') == true
    if strcmp(hemoType,'reflectance') == true
        plot((1:length(filtLH_CBV))/ProcData.notes.CBVCamSamplingRate,filtLH_CBV,'color',colors_Manuscript2020('dark candy apple red'),'LineWidth',1)
        hold on
        plot((1:length(filtRH_CBV))/ProcData.notes.CBVCamSamplingRate,filtRH_CBV,'color',colors_Manuscript2020('rich black'),'LineWidth',1)
        ylabel('\DeltaR/R (%)')
    elseif strcmp(hemoType,'HbT') == true
        plot((1:length(filtLH_HbT))/ProcData.notes.CBVCamSamplingRate,filtLH_HbT,'color',colors_Manuscript2020('dark candy apple red'),'LineWidth',1)
        hold on
        plot((1:length(filtRH_HbT))/ProcData.notes.CBVCamSamplingRate,filtRH_HbT,'color',colors_Manuscript2020('rich black'),'LineWidth',1)
        ylabel('\DeltaHbT')
    end
elseif strcmp(imagingType,'single') == true
    if strcmp(hemoType,'reflectance') == true
        plot((1:length(filtBarrels_CBV))/ProcData.notes.CBVCamSamplingRate,filtBarrels_CBV,'color',colors_Manuscript2020('dark candy apple red'),'LineWidth',1)
        hold on
        ylabel('\DeltaR/R (%)')
    elseif strcmp(hemoType,'HbT') == true
        plot((1:length(filtBarrels_HbT))/ProcData.notes.CBVCamSamplingRate,filtBarrels_HbT,'color',colors_Manuscript2020('dark candy apple red'),'LineWidth',1)
        hold on
        ylabel('\DeltaHbT')
    end
end
scatter((1:length(binForce))/ProcData.notes.dsFs,forceInds,'.','MarkerEdgeColor',colors_Manuscript2020('sapphire'));
scatter((1:length(binWhiskers))/ProcData.notes.dsFs,whiskInds,'.','MarkerEdgeColor',colors_Manuscript2020('blue-green'));
scatter(LPadSol,LPad_Yvals,'v','MarkerEdgeColor','k','MarkerFaceColor','c');
scatter(RPadSol,RPad_Yvals,'v','MarkerEdgeColor','k','MarkerFaceColor','m');
scatter(AudSol,Aud_Yvals,'v','MarkerEdgeColor','k','MarkerFaceColor','g');
xlim([0,ProcData.notes.trialDuration_sec])
set(gca,'TickLength',[0,0])
set(gca,'Xticklabel',[])
set(gca,'box','off')
axis tight
% Left cortical electrode spectrogram
ax4 = subplot(6,1,4);
semilog_imagesc_Manuscript2020(T,F,cortical_LHnormS,'y')
axis xy
c4 = colorbar;
ylabel(c4,'\DeltaP/P (%)')
caxis([-100,100])
ylabel('Frequency (Hz)')
set(gca,'Yticklabel','10^1')
xlim([0,ProcData.notes.trialDuration_sec])
set(gca,'TickLength',[0,0])
set(gca,'Xticklabel',[])
set(gca,'box','off')
yyaxis right
ylabel('Left cortical LFP')
set(gca,'Yticklabel', [])
% Right cortical electrode spectrogram
ax5 = subplot(6,1,5);
semilog_imagesc_Manuscript2020(T,F,cortical_RHnormS,'y')
axis xy
c5 = colorbar;
ylabel(c5,'\DeltaP/P (%)')
caxis([-100,100])
ylabel('Frequency (Hz)')
set(gca,'Yticklabel','10^1')
xlim([0,ProcData.notes.trialDuration_sec])
set(gca,'TickLength',[0,0])
set(gca,'Xticklabel',[])
set(gca,'box','off')
yyaxis right
ylabel('Right cortical LFP')
set(gca,'Yticklabel',[])
% Hippocampal electrode spectrogram
ax6 = subplot(6,1,6);
semilog_imagesc_Manuscript2020(T,F,hippocampusNormS,'y')
c6 = colorbar;
ylabel(c6,'\DeltaP/P (%)')
caxis([-100,100])
xlabel('Time (sec)')
ylabel('Frequency (Hz)')
xlim([0,ProcData.notes.trialDuration_sec])
set(gca,'TickLength',[0,0])
set(gca,'box','off')
yyaxis right
ylabel('Hippocampal LFP')
set(gca,'Yticklabel',[])
% Axes properties
linkaxes([ax1,ax2,ax3,ax4,ax5,ax6],'x')
ax1Pos = get(ax1,'position');
ax4Pos = get(ax4,'position');
ax5Pos = get(ax5,'position');
ax6Pos = get(ax6,'position');
ax4Pos(3:4) = ax1Pos(3:4);
ax5Pos(3:4) = ax1Pos(3:4);
ax6Pos(3:4) = ax1Pos(3:4);
set(ax4,'position',ax4Pos);
set(ax5,'position',ax5Pos);
set(ax6,'position',ax6Pos);
% save the file to directory.
if strcmp(saveFigs,'y') == true
    [pathstr,~,~] = fileparts(cd);
    dirpath = [pathstr '/Figures/Single Trial Figures/'];
    if ~exist(dirpath,'dir')
        mkdir(dirpath);
    end
    savefig(figHandle,[dirpath animalID '_' fileID '_SingleTrialFig']);
end

end
