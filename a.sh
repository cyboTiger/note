#!/bin/bash

PHONEBOOK_ENTRIES="bash_phonebook_entries"


if [ "$#" -lt 1 ]; then
    exit 1

elif [ "$1" = "new" ]; then
    # YOUR CODE HERE #
    name="${@: 2:$#-2}"
    number="${@: -1}"
    echo $name $number >> $PHONEBOOK_ENTRIES

elif [ "$1" = "list" ]; then
    if [ ! -e $PHONEBOOK_ENTRIES ] || [ ! -s $PHONEBOOK_ENTRIES ]; then
        echo "phonebook is empty"
    else
        # YOUR CODE HERE #
        cat $PHONEBOOK_ENTRIES | while IFS= read -r line; do
            name="${line% *}"    # 最后一个空格之前的所有内容
            number="${line##* }"    # 最后一个空格之后的内容
            echo $name $number
        done
    fi

elif [ "$1" = "lookup" ]; then
    # YOUR CODE HERE #
    cat $PHONEBOOK_ENTRIES | while IFS= read -r line; do
        name="${line% *}"    # 最后一个空格之前的所有内容
        number="${line##* }"    # 最后一个空格之后的内容
        if [ "$name" = "${@: 2}" ]; then
            echo $number
        fi
    done

elif [ "$1" = "remove" ]; then
    # YOUR CODE HERE #
    sed -i "/${@: 2}/d" $PHONEBOOK_ENTRIES
    cat $PHONEBOOK_ENTRIES | while IFS= read -r line; do
        name="${line% *}"    # 最后一个空格之前的所有内容
        number="${line##* }"    # 最后一个空格之后的内容
        if [ $name = "${@: 2}" ]; then
            sed 
        fi
    done

elif [ "$1" = "clear" ]; then
    # YOUR CODE HERE #
    > $PHONEBOOK_ENTRIES

else
    echo 'available command:'
    echo '  new [name] [number]'
    echo '  list'
    echo '  lookup [name]'
    echo '  remove [name]'
    echo '  clear'
fi