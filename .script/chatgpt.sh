#!/bin/bash

proxychains -q \
python3 -m revChatGPT.V3 \
--api_key "${ChatGPT_KEY}"
