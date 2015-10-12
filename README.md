# MULAN-dev
This is very fresh version of MULAN repository. New updates will appear here first and then in stable repository MULAN.

1. fix path to your installed Kaldi toolkit in path.sh
2. make script runnable chmod +x run.sh
3. put your wav files in data/wav/ and execute run.sh:
it will produce filter bank features in dir data. 
Attribute scores will be saved in res/scores.txt in the next format:

utterance_id [ ''columns with attributes scores per each frame'']

Columns in res/scores.txt correspond to the next attributes: 
[ fricative glides nasal other silence stop voiced vowel ]
