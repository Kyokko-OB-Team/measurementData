#!/bin/bash

function Usage() {
  cat <<_EOT_
Usage:
  graph-make.sh <measurementDataFile> <GraphDate>

Description:
  温湿度のデータから1日分のグラフ画像を作成するツール

measurementDataFile:
  温湿度データのファイルを指定してください。

GraphDate:
  グラフを作成したい日付を指定して下しあ。
  format: YYYY/MM/DD

_EOT_
  exit 0
}

# 引数チェック
if [ $# -ne 2 ]; then
  echo 引数エラー
  Usage
fi

readonly DATAFILE=$1
readonly GRAPHDAY=$2

# 入力ファイルチェック
if [ -f DATAFILE ]; then
  echo ファイルが無効です
  exit 0
fi
echo 入力ファイルOK

DATA=`cat $DATAFILE | sed -e 's/: /,/g' | sed -e 's/ /,/g' | sed -e 's/[\{\|\}\|"\]//g' | awk -v data="$GRAPHDAY" -F "," ' $2 == data { print $3","$5","$7 } ' `
echo -e "$DATA" > tmp

# degbu log
#echo -e "$DATA"

# グラフファイル名作成
GRAPH_FILENAME=`echo $GRAPHDAY | sed -e 's/\///g'`

# degbu log
#echo -e "$GRAPH_FILENAME"

# gnuplotスクリプト
gnuplot <<- EOF
# 入力データの時間のフォーマット設定
set timefmt "%H:%M:%S"

# 入力データの区切り記号の設定
set datafile separator ","

# グラフタイトル
set title "${GRAPHDAY}"

# x軸
# 軸を時間に設定
set xdata time

# フォーマット設定
set format x "%H"

# ラベル設定
set xlabel "time"

# y軸
# レンジ設定(0～40)
set yrange [0:40]

# ラベル設定
set ylabel "temp"

# メモリを片側表示に設定
set ytics nomirror

# y2軸
# ラベル設定
set y2label "humidi"

# レンジ設定(0～100)
set y2range [0:100]

# メモリを片側表示に設定
set y2tics nomirror

# メモリの数を設定
set my2tics 10

# グラフの出力設定(png)
set terminal png

# 出力ファイルの名前設定
set output "graph-${GRAPH_FILENAME}.png"

# グラフの作成(グラフ1の指定、グラフ2の指定)
# グラフ1: 入力ファイル、使うデータ、出力グラフ、グラフのプロット方法
# グラフ2: 入力ファイル、使うデータ、出力グラフ、グラフのプロット方法
plot "./tmp" using 1:2 axis x1y1 with line title "temp", "./tmp" using 1:3 axis x1y2 with line title "humidi"

EOF

# 一時ファイルの削除
rm -f tmp

exit 0
