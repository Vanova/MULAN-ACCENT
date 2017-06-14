# MULAN-LRE
This version of MULAN repository for extracting attribute features from raw audio files from SRE08 dataset. 
These articulatory attribute features (manner and place) are high-level speech descriptive features.
...

## Citation

If you publish any results using this code, refere with this citation:
```bibteh
@inproceedings{DBLP:conf/slt/KukanovHSL16,
  author    = {Ivan Kukanov and Ville Hautam{\"{a}}ki and
               Sabato Marco Siniscalchi and Kehuang Li},
  title     = {Deep learning with maximal figure-of-merit cost to advance multi-label
               speech attribute detection},
  booktitle = {2016 {IEEE} Spoken Language Technology Workshop, {SLT} 2016, San Diego,
               CA, USA, December 13-16, 2016},
  pages     = {489--495},
  year      = {2016},
  doi       = {10.1109/SLT.2016.7846308}
}

```

1. fix path to your installed Kaldi toolkit in `path.sh`
2. be sure that all your bash files are runnable, fixing: run from the project folder `chmod -R +x ./`
3. change input folder `data_dir` in `run.sh` - root folder with audio files, `steps/data_prep.sh` script will search all files with extension `pcm` in all subfolders
4. change output folder `out_dir` in `run.sh`, audio lists, fbank features and result attribute scores will be saved there

Manner attribute scores will be saved in `$out_dir/res/manner/scores.txt` and place attributes in `$out_dir/res/place/scores.txt` in the next format:

utterance_id [ `columns with attributes scores per each frame`]

Columns in `scores.txt` correspond to the next type of attributes (you can find in `data/dict/`): 

manner: [ fricative glides nasal other silence stop voiced vowel ]

place: [ coronal dental glottal high labial low mid other palatal silence velar ]
