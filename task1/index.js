const express = require('express');
const axios = require('axios');
const chalk = require('chalk');

const app = express();
const PORT = process.env.PORT || 3000;

// 中间件
app.use(express.json());

// 根路径
app.get('/', (req, res) => {
  console.log(chalk.green(`[${new Date().toLocaleString()}] GET / - Request received`));
  res.json({
    message: '🎉 Node.js & npm 开发者生态系统演示',
    version: '1.0.0',
    endpoints: {
      '/': '项目信息',
      '/health': '健康检查',
      '/api/quote': '获取名言引用',
      '/api/deps': '查看已安装依赖'
    }
  });
});

// 健康检查
app.get('/health', (req, res) => {
  console.log(chalk.blue(`[${new Date().toLocaleString()}] GET /health - Health check`));
  res.json({ status: 'healthy', timestamp: new Date().toISOString() });
});

// 使用第三方API获取名言
app.get('/api/quote', async (req, res) => {
  console.log(chalk.yellow(`[${new Date().toLocaleString()}] GET /api/quote - Fetching quote`));
  try {
    // 使用 axios 调用公开 API
    const response = await axios.get('https://api.quotable.io/random', {
      params: { maxLength: 100 }
    });
    res.json({
      quote: response.data.content,
      author: response.data.author
    });
  } catch (error) {
    console.error(chalk.red('Error fetching quote:'), error.message);
    res.status(500).json({ error: 'Failed to fetch quote' });
  }
});

// 查看安装的依赖
app.get('/api/deps', (req, res) => {
  const pkg = require('./package.json');
  res.json({
    project: pkg.name,
    version: pkg.version,
    dependencies: pkg.dependencies,
    nodeVersion: process.version,
    platform: process.platform
  });
});

app.listen(PORT, () => {
  console.log(chalk.green('='.repeat(50)));
  console.log(chalk.cyan('  🚀 Express 服务器已启动!'));
  console.log(chalk.cyan(`  端口: ${PORT}`));
  console.log(chalk.cyan(`  环境: ${process.env.NODE_ENV || 'development'}`));
  console.log(chalk.green('='.repeat(50)));
});
