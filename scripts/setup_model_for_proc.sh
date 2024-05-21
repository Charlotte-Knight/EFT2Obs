#!/usr/bin/env bash

#set -x

PROCESS=$1
PROC_CARD_PATH=${CARDS_DIR}/${PROCESS}/proc_card.dat

model_line=$(head -n 1 $PROC_CARD_PATH)
model_name=$(python3 -c "print('${model_line}'.split(' ')[2].split('-')[0])")

echo "Detected model: $model_name"
echo "Downloading UFO model"

echo "import model $model_name" | ${EFT2OBS_DIR}/${MG_DIR}/bin/mg5_aMC

if [[ -n $(grep "${model_name}-" $PROC_CARD_PATH) ]] ; then
  restrict_card_name=restrict_$(python3 -c "print('${model_line}'.split('-')[1])").dat
  echo "Detected restrict card: $restrict_card_name"
  if [[ -e ${EFT2OBS_DIR}/${MG_DIR}/models/${model_name}/$restrict_card_name ]] ; then
    echo "Restrict card already exists, will do nothing"
  else
    restrict_card_origin=${CARDS_DIR}/restrict_cards/${model_name}/${restrict_card_name}
    restrict_card_destination=${EFT2OBS_DIR}/${MG_DIR}/models/${model_name}
    echo "Copying restrict card from $restrict_card_origin to $restrict_card_destination"
    cp $restrict_card_origin $restrict_card_destination
  fi

  
fi
