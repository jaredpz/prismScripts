function makeParcNative(parcDir, subID, lutFile, freesurferHome)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% USAGE
% INPUTS:
% parcDir = full filepath to the ParcellationResults directory
%			that is the output of the Wang et al 2015 individual parcellation
% subID = subject ID, which should be the name of a directory within parcDir			
% lutFile = full filepath to a .mat file containing the FreeSurfer color
% 			 lookup table to be used
% freesurferHome = full filepath to where Freesurfer is installed
%
% OUTPUTS:
% This will output four files, one full brain parcellation and one high
% confidence parcellation for each hemisphere (lh rh)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Make sure Freesurfer Dependency is set
addpath([freesurferHome filesep 'matlab']);
% Names for hemis + look-up table file
hemi = {'lh', 'rh'};
lut = load(lutFile);
% Set directory
cd([parcDir filesep subID])

for hh = 1:2;

	% read in the first confidence map
	% start with "NetworkConfidence_2" becase parcellation has medial wall
	% as first network and we're skipping that
	net1 = MRIread(['smooth' filesep 'NetworkConfidence_2_' hemi{hh} '_native_sm6_sm6dil2.mgh']);

	% make array to read rest of data into
	confMaps = zeros(size(net1.vol, 2), 19);
	confMaps(:,2) = transpose(net1.vol);

	% loop over remaing confidence maps and read into array
	for ii = 3:19;
		imgName = ['smooth' filesep 'NetworkConfidence_' num2str(ii) '_' hemi{hh} '_native_sm6_sm6dil2.mgh'];
        img = MRIread(imgName);
        confMaps(:,ii) = transpose(img.vol); % ii-1 because we are correcting the network numbering due to medial wall
	end


	[maxConf, idx] = max(confMaps, [], 2); %find max confidence and index of most confident network
	% change label indices with label values for FreeSurfer  
    label = changem(idx, lut.table(:,5), 1:19);
    % write parcellations
    parcName = [hemi{hh} '.' subID '_sm12_native_parc.annot'];
    write_annotation(parcName, 0:size(net1.vol, 2)-1, label, lut); %40961 = nVerts - 1;
    

end

