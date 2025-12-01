#!/bin/bash

# 使用例:
#   ./init-terraform.sh modules/vpc modules/ec2 environments/dev
#   ./init-terraform.sh -i directories.txt
#   ./init-terraform.sh --input-file dirs.list

set -e

# 色の定義
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

show_help() {
    cat << EOF
使用方法: $0 [OPTIONS] [<directory1> [directory2] [directory3] ...]

Terraformの初期構成（main.tf, variables.tf, outputs.tf）を作成します。

OPTIONS:
    -h, --help              このヘルプを表示
    -i, --input-file FILE   ディレクトリリストをファイルから読み込む
    -f, --force             既存ファイルを上書き
    -n, --no-gitignore      .gitignoreを作成しない
    -p, --provider PROVIDER プロバイダーを指定 (デフォルト: aws)
    -r, --region REGION     AWSリージョンを指定 (デフォルト: ap-northeast-1)

ディレクトリの指定方法:
    1. コマンドライン引数として直接指定
       例: $0 modules/vpc modules/ec2

    2. ファイルから読み込み (-i オプション)
       例: $0 -i directories.txt

       ファイル形式:
       - 1行に1ディレクトリを記述
       - # で始まる行はコメント
       - 空行は無視される

ファイル例 (directories.txt):
    # VPCモジュール
    modules/vpc
    modules/subnet

    # EC2モジュール
    modules/ec2
    modules/alb

    # 環境別
    environments/dev
    environments/prod

EOF
}

# デフォルト設定
FORCE=false
CREATE_GITIGNORE=true
PROVIDER="aws"
REGION="ap-northeast-1"
INPUT_FILE=""
DIRECTORIES=()

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -i|--input-file)
            INPUT_FILE="$2"
            shift 2
            ;;
        -f|--force)
            FORCE=true
            shift
            ;;
        -n|--no-gitignore)
            CREATE_GITIGNORE=false
            shift
            ;;
        -p|--provider)
            PROVIDER="$2"
            shift 2
            ;;
        -r|--region)
            REGION="$2"
            shift 2
            ;;
        -*)
            echo -e "${RED}エラー: 不明なオプション: $1${NC}"
            show_help
            exit 1
            ;;
        *)
            DIRECTORIES+=("$1")
            shift
            ;;
    esac
done

read_directories_from_file() {
    local file=$1
    local line_num=0

    if [ ! -f "$file" ]; then
        echo -e "${RED}エラー: ファイルが見つかりません: $file${NC}"
        exit 1
    fi

    if [ ! -r "$file" ]; then
        echo -e "${RED}エラー: ファイルを読み込めません: $file${NC}"
        exit 1
    fi

    echo -e "${BLUE}📄 ファイルからディレクトリを読み込み中: $file${NC}"

    while IFS= read -r line || [ -n "$line" ]; do
        line_num=$((line_num + 1))

        line=$(echo "$line" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')

        if [ -z "$line" ]; then
            continue
        fi

        if [[ "$line" =~ ^# ]]; then
            continue
        fi

        if [[ "$line" =~ [[:space:]] ]]; then
            echo -e "${YELLOW}  ⚠ 警告 (行 $line_num): スペースを含むパスはスキップします: $line${NC}"
            continue
        fi

        DIRECTORIES+=("$line")
        echo -e "${GREEN}  ✓ 追加: $line${NC}"
    done < "$file"

    echo ""
}

if [ -n "$INPUT_FILE" ]; then
    read_directories_from_file "$INPUT_FILE"
fi

if [ ${#DIRECTORIES[@]} -eq 0 ]; then
    echo -e "${RED}エラー: ディレクトリが指定されていません${NC}"
    echo ""
    show_help
    exit 1
fi

create_file() {
    local filepath=$1
    local content=$2
    local filename=$(basename "$filepath")

    if [ -f "$filepath" ] && [ "$FORCE" = false ]; then
        echo -e "${YELLOW}  ⊗ $filename はすでに存在します (スキップ)${NC}"
        return 1
    fi

    echo "$content" > "$filepath"
    echo -e "${GREEN}  ✓ $filename を作成しました${NC}"
    return 0
}

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Terraform初期構成作成スクリプト${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

echo -e "${BLUE}📊 処理対象: ${#DIRECTORIES[@]} 個のディレクトリ${NC}"
echo ""

FIRST_DIR="${DIRECTORIES[0]}"
IS_ROOT=false
if [[ ! "$FIRST_DIR" =~ / ]]; then
    IS_ROOT=true
fi

for dir in "${DIRECTORIES[@]}"; do
    echo -e "${BLUE}📁 ディレクトリ: $dir${NC}"

    if [ -d "$dir" ]; then
        echo -e "${YELLOW}  ⚠ ディレクトリはすでに存在します${NC}"
    else
        mkdir -p "$dir"
        echo -e "${GREEN}  ✓ ディレクトリを作成しました${NC}"
    fi

    current_is_root=false
    if [ "$IS_ROOT" = true ] && [ "$dir" = "$FIRST_DIR" ]; then
        current_is_root=true
    fi

    # create_file "$dir/main.tf" "$(generate_main_tf "$dir" $current_is_root)"
    create_file "$dir/main.tf"

    # create_file "$dir/variables.tf" "$(generate_variables_tf $current_is_root)"
    create_file "$dir/variables.tf"

    # create_file "$dir/outputs.tf" "$(generate_outputs_tf)"
    create_file "$dir/outputs.tf"

    echo ""
done

if [ "$CREATE_GITIGNORE" = true ]; then
    GITIGNORE_DIR="."
    if [ "$IS_ROOT" = true ]; then
        GITIGNORE_DIR=$(dirname "$FIRST_DIR")
        if [ "$GITIGNORE_DIR" = "." ]; then
            GITIGNORE_DIR="."
        fi
    fi

    if [ ! -f "$GITIGNORE_DIR/.gitignore" ] || [ "$FORCE" = true ]; then
        echo -e "${BLUE}📄 .gitignore${NC}"
        create_file "$GITIGNORE_DIR/.gitignore" "$(generate_gitignore)"
        echo ""
    fi
fi

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}✓ 初期構成の作成が完了しました！${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${BLUE}📈 サマリー:${NC}"
echo -e "  処理済みディレクトリ: ${GREEN}${#DIRECTORIES[@]}${NC} 個"
echo ""
echo -e "${BLUE}次のステップ:${NC}"
echo "1. 各ディレクトリの main.tf にリソースを記述"
echo "2. variables.tf に必要な変数を追加"
echo "3. outputs.tf に出力したい値を追加"
echo "4. terraform init を実行"
echo ""
