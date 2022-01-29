#!/bin/sh

downloadDecklink() {
    local _ver=11.7
    local _arch=Windows
    local _referid=0bf03941825e45e98ce26c09bcf68cf0
    local _downloadid=f7ac397e58db442d9f502f9bd49e1162
    local _siteurl="https://www.blackmagicdesign.com/api/register/us/download/${_downloadid}"
    local _useragent='User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:81.0) Gecko/20100101 Firefox/81.0'
    local _reqjson="{ \
        \"platform\": \"Windows\", \
        \"country\": \"us\", \
        \"firstname\": \"Deck\", \
        \"lastname\": \"Link\", \
        \"email\": \"mail@example.org\", \
        \"phone\": \"202-555-0194\", \
        \"state\": \"New York\", \
        \"city\": \"MABS\", \
        \"hasAgreedToTerms\": true, \
        \"product\": \"Desktop Video ${_ver} SDK\" \
    }"
    local _filename="Blackmagic_DeckLink_SDK_${_ver}.zip"

    local _srcurl="$(curl -s -H "$_useragent" -H 'Content-Type: application/json;charset=UTF-8' \
        -H "Referer: https://www.blackmagicdesign.com/support/download/${_referid}/Linux" \
        --data-ascii "$_reqjson" --compressed "$_siteurl")"

    local _root=$(pwd)

    create_build_dir
    curl -gqb '' -C - --retry 3 --retry-delay 3 -H 'Upgrade-Insecure-Requests: 1' -o "${_filename}" --compressed "${_srcurl}"

    do_extract "$_filename"
    cd_safe Win/include
    # add newline at the end of file if it's missing, otherwise widl whines about it
    sed -i -e '$a\' *.idl
    widl -I"$MINGW_PREFIX/$MINGW_CHOST/include" -h -u DeckLinkAPI.idl
    sed -n '2,24 s/^\*\*//p' DeckLinkAPI.idl > DeckLinkAPI.LICENSE
    cp DeckLinkAPI{.h,_i.c,Version.h} "$_root"/include/
    cp DeckLinkAPI.LICENSE "$_root"/'SDK License.txt'
    cd_safe "$_root"
}

downloadDecklink
