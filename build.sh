#!/bin/bash

# ビルドスクリプト
echo "Building health check function..."

cd src/functions/healthCheck

# 依存関係のインストール
echo "Installing dependencies..."
npm install

# TypeScript のビルド
echo "Building TypeScript..."
npm run build

# Lambda デプロイパッケージの作成
echo "Creating deployment package..."
mkdir -p ../../../terraform/lambda_packages

# dist, node_modules, package.json を zip化
cd dist
zip -r ../../../../terraform/lambda_packages/health_check.zip . ../node_modules ../package.json

echo "✓ Build completed: terraform/lambda_packages/health_check.zip"