VENDOR_ID=86261454
DATE=`date '+%Y%m%d' --date '2 day ago'`
ORIGINAL_FILE="S_D_${VENDOR_ID}_${DATE}.txt"
NEW_FILE="S_D_${VENDOR_ID}_${DATE}.tsv"
SLACK_CHANNEL="#whalebird"
SLACK_URL="https://hooks.slack.com/services/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"

# itunes storeからレポートファイル取得
java Autoingestion key.properties ${VENDOR_ID} Sales Daily Summary ${DATE}

# DLしたファイルをリネーム
gunzip ${ORIGINAL_FILE}.gz
mv ${ORIGINAL_FILE} ${NEW_FILE}

count=0
i=0

# TSVから各地域のDL数を合計
while read LINE; do
    # 1行目はタイトルなのでスキップ
    if [ "$i" -ne 0 ]
    then
        tsvList=($LINE)
        if [ ${tsvList[7]} -eq 1 ]
        then
            let count=${count}+${tsvList[8]}
        fi
    fi
    let i=${i}+1
done < ${NEW_FILE}
rm ${NEW_FILE}
echo $count

# Slackに通知
payload='payload={"channel": "'${SLACK_CHANNEL}'", "username": "iPhone reports", "text": "'${DATE}'のダウンロード数は:'$count'", "icon_emoji": ":ghost:"}'
curlScript="curl -X POST --data '"$payload"' ${SLACK_URL}"
eval ${curlScript}
