#!/bin/bash

echo "Start ChatGPT Translate..."

proxychains -q \
python3 -m revChatGPT.V3 \
--api_key "${ChatGPT_KEY}" \
--base_prompt='下面我让你来充当翻译家，你的目标是把英中互译。请翻译时不要带翻译腔，而是要翻译得自然、流畅和地道，使用优美和高雅的表达方式，并且以列表的形式告诉我英文句子中的所有成分以及构成，以子列表的形式给出从句里面的成分。'
