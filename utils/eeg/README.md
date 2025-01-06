# Functions to use on EEG data

Most were taken from Mike X Cohen's scripts. I am forever grateful for his teachings.

## EEGLAB or Fieldtrip

Click [here](https://eeglab.org/others/EEGLAB_and_Fieldtrip.html) for a discussion.

## Conversion from toolboxes to custom

EEG data must be converted into the ``data`` struct which is the main input accepted by these custom functions. Use utility functions to convert from other toolboxes' data formats (such as the EEG struct from EEGLAB and cfg struct from Fieldtrip) into the custom data struct.  


### From EEGLAB

- EEG.data will be called ```EEG_data```
- ERP.data will be called ```ERP_data```