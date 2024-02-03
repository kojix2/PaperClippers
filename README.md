## PaperClippers

ChatGPTを利用して、自動で論文を翻訳したい

## 基本方針

1. [Zotero](https://www.zotero.org/) を使ってウェブページのスナップショットを取る
2. Rubyの [Nokogiri](https://github.com/sparklemotion/nokogiri) を使って論文を分割して保存する
3. ChatGPTのAPI版で翻訳する

## 利用するツール

- [Firefox](https://www.mozilla.org/firefox/) - ブラウザ
- [Zotero](https://www.zotero.org/) - 文献管理ソフト
- [Ruby](https://www.ruby-lang.org) - 動的プログラミング言語
- [chatgpt-cli](https://github.com/kojix2/chatgpt-cli) - Crystal製のオレオレコマンドラインツール

## 論文からテキストを抽出する

まずは論文からテキストを抽出します。PDFではなくHTMLからスクレイピングをします。（スクレイピングには「XPath」を使います）**しかし、論文が掲載されている多くのウェブサイトは簡単にはスクレイピングをさせてくれません。403 Forbidden になってしまいます。** そこで、まず「Zotero」を使ってスナップショットをローカルに保存し、そのローカルのHTMLファイルに対してスクレイピングを行います。

### ① Zoteroに論文を保存する

文献管理ツールZoteroに論文を保存します。私はFirefox拡張を利用しています。保存された論文右クリックして「スナップショットを閲覧する」を選択すると、ローカルに保存されたHTMLをブラウザで開くことができます。

`/home/kojix2/Zotero/storage/HOGEFUGA/S1234567890123456789.html`

このファイルパスをあとで使用します。

### ② FirefoxでXPathを確認する

Token数の制限に対処するために、論文を各セクションごとに分割してファイルに保存します。まず、HTMLで各セクションがどのように表現されているのか調べます。

Firefoxの画面で、論文本文中の「調査」をクリックします。インスペクタを開き、HTMLのソースコードを確認します。例えばCell紙の場合は、以下のようにセクションが並んでいることがわかります。

![image.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/144608/7e3292da-364d-d709-0558-8439a643db6e.png)

右クリックで、「コピー」＞「XPath」を選択します。すると、XPathがクリップボードにコピーされます。

```
//*[@id="sec1"]
```

このXPathに対応する本文を抽出し、適切に改行をするような小さなコマンドラインツールをRubyで書きました。

### ③ファイルの抽出

```
kirinuki [options]

Example: ruby kirinuki.rb -f 'path/to/your.html' -p '//*[@id="sec数"]' -r '1..12'
    -f, --file HTML_PATH             HTML file path
    -x, --xpath XPATH                XPath
    -r, --range RANGE                Range
    -o, --output OUTPUT_DIR          Output directory
```

Exampleを参考にして、先程作ったツールを実行します。「数」のところが、rangeのイテレータの各要素に置き換わる仕組みになっています。`range` は `eval` で評価されるので、いろいろな応用ができます。セキュリティの観点から `eval` はなるべく使わない方がいいと言われていますが、今回はローカルのファイルを変換するだけなので問題ないでしょう。

## ChatGPTを使って翻訳する

ここでは、自作の[chatgpt-cli](https://github.com/kojix2/chatgpt-cli) を使います。それなりに便利なツールですが、万人に向けて作られていないので使いたい人だけ使ってね、という感じですね。ここでは基本の機能のみを使います。他のChatGPT向けコマンドラインツールでも同じことができるはずです。

まずは、翻訳用のプロンプトのテンプレートを作ります。

```txt:prompt.txt
次の論文のアブストラクトを読んでください。

# ここにアブストやサマリーをコピペする

読み終わったら、以下のセクションを翻訳してください。わかりやすく平易な文章でお願いします。
翻訳された文章だけ回答してください。
---

```

上のテンプレートはかなり改善の余地があるでしょう。たとえば、専門用語では英文をカッコで併記させたりするといいかもしれません。

これで、`cat prompt.txt idsec1.txt` とすると、プロンプト、翻訳対象の英文、の順番で出力されます。これを標準入力から `chatgpt-cli` に投げます。

```
cat prompt.txt idsec1.txt | chatgpt -M gpt-4 > idsec1_ja.txt
```

さらに、連番をまわすシェルスクリプトを書きます。

```sh
for i in {1..12}; do cat "prompt.txt" "idsec$i.txt" | chatgpt -M gpt-4 > "idsec${i}_ja.txt"; done
```

あとはひたすら待っていれば翻訳されたテキストファイルが生成されます。
この工程はかなり時間がかかりますので、気長に待ちましょう。

## 終わりに

早ければ数ヶ月、遅くても１年後には、論文全体がChatGPTのトークンに乗るようになるでしょう。なので、ここに書いてあるような論文を分割して、トークン数に乗せる仕組みは早晩いらなくなるでしょう。けれども、現時点ではトークン数に限界があるので、こんな感じで工夫をする必要があります。

いずれ便利なツールができて、ボタン一個で簡単に翻訳できるようになるといいですね。
