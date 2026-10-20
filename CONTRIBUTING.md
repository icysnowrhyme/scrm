# 贡献指南

感谢你愿意改进这个项目。提交代码前，请先确认改动范围清晰、可以复现，并且不包含敏感信息。

## 开发流程

1. Fork 仓库并从 `main` 创建分支：`feat/xxx`、`fix/xxx`、`docs/xxx`。
2. 安装依赖并完成本地启动，确保改动能够被实际验证。
3. 提交前运行：

   ```bash
   cd frontend
   pnpm type-check
   pnpm build

   cd ../backend
   mvn -q -DskipTests package
   ```

4. 提交 Pull Request，说明背景、改动点、验证方式和潜在影响。

## 代码约定

### 前端

- 使用 Vue 3 Composition API、`<script setup lang="ts">` 和 TypeScript。
- 页面组件放在 `src/views/<domain>/`，API 封装放在 `src/api/`。
- 遵循现有 Element Plus 风格与命名习惯，优先复用项目组件。
- 不直接修改上游通用组件的行为来适配单个页面。
- 提交前通过 ESLint、Prettier 和类型检查。

### 后端

- 按 `controller → service → mapper` 分层，不在 Controller 中堆积业务逻辑。
- 写请求使用 `form` 对象并添加校验；查询使用 `query` 对象。
- 新增业务表必须包含逻辑删除字段，并同步处理菜单、权限码和 SQL 初始化脚本。
- 对外接口保持统一响应结构，分页接口使用 `PageResult`。
- 涉及金额、日期和状态枚举时，优先复用既有常量与转换逻辑。

## 数据与隐私

- 不得提交真实客户姓名、手机号、微信、邮箱、合同或财务数据。
- 演示数据必须是虚构内容；截图、日志和录屏需先脱敏。
- 不得提交数据库密码、JWT 密钥、云平台 AccessKey、私钥或带签名的 URL。
- 如果发现历史提交中存在凭据，请立即撤销对应凭据，并联系维护者处理。

## 提交信息

建议使用 Conventional Commits：

```text
feat(customer): add batch owner assignment
fix(report): handle empty sales ranking
docs(readme): clarify local startup steps
```

## 行为准则

参与本项目即表示同意尊重所有贡献者，不进行人身攻击、骚扰或歧视。技术讨论对事不对人。

## 安全问题

请不要在公开 Issue 中披露未修复的漏洞。报告流程见 [SECURITY.md](SECURITY.md)。
