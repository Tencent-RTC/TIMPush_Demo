#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

const mode = process.argv[2];
const root = path.resolve(__dirname, '..');
const packageJsonPath = path.join(root, 'package.json');
const localSourcePath = path.join(root, 'TIMPush');
const dependencyName = '@tencentcloud/react-native-push';
const packageVersion = process.env.TIMPUSH_PACKAGE_VERSION || '^1.3.0';

if (!['package', 'source'].includes(mode)) {
  console.error('Usage: node scripts/timpush-dependency.js <package|source>');
  process.exit(1);
}

if (mode === 'source' && !fs.existsSync(path.join(localSourcePath, 'package.json'))) {
  console.error('TIMPush source folder is missing. Expected: TIMPush/package.json');
  process.exit(1);
}

const packageJson = JSON.parse(fs.readFileSync(packageJsonPath, 'utf8'));
packageJson.dependencies = packageJson.dependencies || {};
packageJson.dependencies[dependencyName] = mode === 'source' ? 'file:./TIMPush' : packageVersion;

fs.writeFileSync(packageJsonPath, `${JSON.stringify(packageJson, null, 2)}\n`);
console.log(`${dependencyName} => ${packageJson.dependencies[dependencyName]}`);
