const chalk = require('chalk');
const axios = require('axios');

async function main() {
  console.log(chalk.bold.cyan('\n=== NPM 生态工具演示 CLI ===\n'));

  // 1. Node.js 版本信息
  console.log(chalk.green('📦 Node.js 环境信息:'));
  console.log(chalk.white(`   版本: ${chalk.yellow(process.version)}`));
  console.log(chalk.white(`   平台: ${chalk.yellow(process.platform)}`));
  console.log(chalk.white(`   架构: ${chalk.yellow(process.arch)}`));

  // 2. 包信息
  const pkg = require('./package.json');
  console.log(chalk.green('\n📋 项目信息:'));
  console.log(chalk.white(`   项目名: ${chalk.yellow(pkg.name)}`));
  console.log(chalk.white(`   版本: ${chalk.yellow(pkg.version)}`));

  const deps = Object.keys(pkg.dependencies || {});
  console.log(chalk.green(`\n📦 已安装依赖 (${deps.length}个):`));
  deps.forEach((dep, index) => {
    console.log(chalk.white(`   ${index + 1}. ${chalk.magenta(dep)} ${chalk.gray(pkg.dependencies[dep])}`));
  });

  // 3. 网络请求演示
  console.log(chalk.green('\n🌐 使用 axios 发起 HTTP 请求...'));
  try {
    const response = await axios.get('https://httpbin.org/get', {
      params: { hello: 'world' }
    });
    console.log(chalk.white(`   状态码: ${chalk.green(response.status)}`));
    console.log(chalk.white(`   请求URL: ${chalk.gray(response.data.url)}`));
  } catch (error) {
    console.log(chalk.red(`   ❌ 网络请求失败: ${error.message}`));
  }

  console.log(chalk.bold.cyan('\n=== 演示完成 ===\n'));
}

main().catch(console.error);

main().catch(console.error);
