#!/bin/bash

# show all of scratchpad except custome instances.

i3-msg '[floating] scratchpad show'

not_show_instances=(
    "translate"
    "AItrans"
    "ChatGPT"
)

for instance in ${not_show_instances[@]}; do
    echo "${instance}"
    i3-msg "[instance=\"${instance}\"] move scratchpad"
done

unset not_show_instances
