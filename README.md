# MULAN-LRE
This version of MULAN repository for extracting attribute features from raw audio files from SRE08 dataset. 
These articulatory attribute features (manner and place) are high-level speech descriptive features.
...

1. fix path to your installed Kaldi toolkit in `path.sh`
2. be sure that all your bash files are runnable, fixing: `chmod +x your_file.sh`
3. change input folder `data_dir` in `run.sh` - root folder with audio files, `steps/data_prep.sh` script will search all files with extension `pcm` in all subfolders
4. change output folder `out_dir` in `run.sh`, audio lists, fbank features and result attribute scores will be saved there

Manner attribute scores will be saved in `$out_dir/res/manner/scores.txt` and place attributes in `$out_dir/res/place/scores.txt` in the next format:

utterance_id [ `columns with attributes scores per each frame`]

Columns in `scores.txt` correspond to the next type of attributes (you can find in `data/dict/`): 

manner: [ fricative glides nasal other silence stop voiced vowel ]

place: [ coronal dental glottal high labial low mid other palatal silence velar ]
