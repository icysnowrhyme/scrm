# API 说明

本文覆盖通用 SCRM 的认证方式、统一响应格式和核心业务接口。服务启动后可访问：

- Knife4j：<http://localhost:8000/doc.html>
- OpenAPI JSON：<http://localhost:8000/v3/api-docs>

## 1. 基础约定

### 地址与协议

- 开发环境：前端 Vite 将 `/dev-api` 代理到 `http://localhost:8000`
- 接口前缀：`/api/v1`
- 数据格式：`application/json`
- 鉴权头：`Authorization: Bearer <accessToken>`

### 统一响应

```json
{
  "code": "00000",
  "msg": "成功",
  "data": {}
}
```

分页响应的 `data` 结构：

```json
{
  "code": "00000",
  "msg": "成功",
  "data": {
    "list": [],
    "total": 0
  }
}
```

### 分页参数

| 参数 | 类型 | 默认值 | 说明 |
| --- | --- | --- | --- |
| `pageNum` | integer | `1` | 页码 |
| `pageSize` | integer | `10` | 每页条数 |

### 数据类型约定

- `bigint` ID 序列化为字符串，前端应避免直接参与数值计算。
- 金额字段为 `decimal`，响应通常为数值或字符串，展示前请显式转换为 `Number`。
- 日期使用 `yyyy-MM-dd`；日期时间使用 ISO 格式。
- 逻辑删除字段不会返回给业务页面。

### 常用错误码

| 错误码 | 含义 |
| --- | --- |
| `00000` | 成功 |
| `A0210` | 用户名或密码错误 |
| `A0230` | 访问令牌无效或已过期 |
| `A0240` | 验证码错误 |
| `A0301` | 访问未授权 |
| `A0410` | 请求必填参数为空 |
| `B0001` | 系统执行出错 |
| `C0300` | 数据库服务出错 |

前端 Axios 拦截器会在令牌失效时清理会话并跳转登录页。

## 2. 认证接口

### 获取验证码

```http
GET /api/v1/auth/captcha
```

响应示例：

```json
{
  "code": "00000",
  "msg": "成功",
  "data": {
    "captchaId": "b6b6...",
    "captchaBase64": "data:image/png;base64,..."
  }
}
```

验证码保存在 Redis，默认有效期 120 秒。

### 登录

```http
POST /api/v1/auth/login
Content-Type: application/json
```

请求体：

```json
{
  "username": "admin",
  "password": "123456",
  "captchaId": "b6b6...",
  "captchaCode": "9"
}
```

响应示例：

```json
{
  "code": "00000",
  "msg": "成功",
  "data": {
    "tokenType": "Bearer",
    "accessToken": "xxx.yyy.zzz",
    "refreshToken": "xxx.yyy.zzz",
    "expiresIn": 7200
  }
}
```

### 刷新令牌

```http
POST /api/v1/auth/refresh-token?refreshToken=<refreshToken>
```

### 退出登录

```http
DELETE /api/v1/auth/logout
Authorization: Bearer <accessToken>
```

## 3. 客户接口

基础路径：`/api/v1/scrm/customers`

| 方法 | 路径 | 权限码 | 说明 |
| --- | --- | --- | --- |
| GET | `/` | `scrm:customer:list` | 客户分页列表 |
| GET | `/pool` | `scrm:customer:list` | 公海客户分页列表 |
| GET | `/options` | 已登录 | 客户下拉选项 |
| GET | `/{id}` | `scrm:customer:list` | 客户详情（含标签、最近跟进等） |
| POST | `/` | `scrm:customer:create` | 新增客户 |
| PUT | `/{id}` | `scrm:customer:update` | 修改客户 |
| DELETE | `/{ids}` | `scrm:customer:delete` | 批量删除，多个 ID 用逗号分隔 |
| PUT | `/assign` | `scrm:customer:assign` | 批量分配负责人 |
| PUT | `/{id}/claim` | `scrm:customer:claim` | 领取公海客户 |

查询参数（客户列表/公海）：

| 参数 | 说明 |
| --- | --- |
| `keyword` | 姓名、公司、手机号模糊匹配 |
| `level` | 客户等级 A/B/C/D |
| `status` | 客户状态 |
| `source` | 客户来源 |
| `ownerId` | 负责人 ID |
| `tagId` | 标签 ID |
| `startDate` / `endDate` | 创建日期范围 |
| `pageNum` / `pageSize` | 分页 |

新增/修改客户请求示例：

```json
{
  "name": "张晨",
  "shortName": "张先生",
  "phone": "13800000000",
  "wechat": "zhangchen",
  "email": "zhangchen@example.com",
  "gender": 1,
  "company": "示例科技有限公司",
  "position": "采购经理",
  "industry": "企业服务",
  "level": "A",
  "source": 1,
  "status": 2,
  "ownerId": "5",
  "address": "上海市浦东新区",
  "remark": "对年度套餐感兴趣",
  "nextFollowTime": "2026-10-25T10:00:00",
  "tagIds": ["1", "2"]
}
```

批量分配：

```json
{
  "ids": "12,13,14",
  "ownerId": "5"
}
```

`ownerId` 为空表示移入公海。

## 4. 跟进记录

基础路径：`/api/v1/scrm/follow-ups`

| 方法 | 路径 | 权限码 | 说明 |
| --- | --- | --- | --- |
| GET | `/` | `scrm:follow-up:list` | 跟进分页列表 |
| GET | `/customer/{customerId}` | `scrm:follow-up:list` | 某客户的跟进记录 |
| POST | `/` | `scrm:follow-up:create` | 新增跟进 |
| PUT | `/{id}` | `scrm:follow-up:update` | 修改跟进 |
| DELETE | `/{ids}` | `scrm:follow-up:delete` | 批量删除 |

新增请求示例：

```json
{
  "customerId": "12",
  "type": 1,
  "content": "电话沟通年度采购计划，客户希望月底前收到报价。",
  "result": "有明确意向",
  "nextFollowTime": "2026-10-24T14:00:00"
}
```

跟进查询支持 `customerId`、`type`、`creatorId`、`startDate`、`endDate`、`scopeOwnerId` 等条件。

## 5. 商机与合同

### 商机

基础路径：`/api/v1/scrm/opportunities`

| 方法 | 路径 | 权限码 | 说明 |
| --- | --- | --- | --- |
| GET | `/` | `scrm:opportunity:list` | 商机分页 |
| GET | `/{id}` | `scrm:opportunity:list` | 商机详情 |
| GET | `/customer/{customerId}` | 已登录 | 客户商机 |
| POST | `/` | `scrm:opportunity:create` | 新增商机 |
| PUT | `/{id}` | `scrm:opportunity:update` | 修改商机 |
| DELETE | `/{ids}` | `scrm:opportunity:delete` | 批量删除 |

请求示例：

```json
{
  "customerId": "12",
  "name": "2026 年度 SCRM 采购",
  "amount": 128000,
  "stage": 3,
  "probability": 65,
  "expectedCloseDate": "2026-11-30",
  "ownerId": "5",
  "remark": "已完成方案报价"
}
```

### 合同

基础路径：`/api/v1/scrm/contracts`

| 方法 | 路径 | 权限码 | 说明 |
| --- | --- | --- | --- |
| GET | `/` | `scrm:contract:list` | 合同分页 |
| GET | `/{id}` | `scrm:contract:list` | 合同详情 |
| GET | `/customer/{customerId}` | 已登录 | 客户合同 |
| POST | `/` | `scrm:contract:create` | 新增合同 |
| PUT | `/{id}` | `scrm:contract:update` | 修改合同 |
| DELETE | `/{ids}` | `scrm:contract:delete` | 批量删除 |

请求示例：

```json
{
  "contractNo": "HT2026-0012",
  "customerId": "12",
  "opportunityId": "8",
  "name": "年度 SCRM 服务合同",
  "amount": 128000,
  "signDate": "2026-10-20",
  "startDate": "2026-11-01",
  "endDate": "2027-10-31",
  "status": 2,
  "ownerId": "5",
  "remark": "分两期付款"
}
```

## 6. 标签与营销活动

### 客户标签

基础路径：`/api/v1/scrm/tags`

| 方法 | 路径 | 权限码 | 说明 |
| --- | --- | --- | --- |
| GET | `/` | `scrm:tag:list` | 标签列表 |
| POST | `/` | `scrm:tag:create` | 新增 |
| PUT | `/{id}` | `scrm:tag:update` | 修改 |
| DELETE | `/{ids}` | `scrm:tag:delete` | 批量删除 |

### 营销活动

基础路径：`/api/v1/scrm/campaigns`

| 方法 | 路径 | 权限码 | 说明 |
| --- | --- | --- | --- |
| GET | `/` | `scrm:campaign:list` | 活动分页 |
| GET | `/{id}` | `scrm:campaign:list` | 活动详情 |
| POST | `/` | `scrm:campaign:create` | 新增活动 |
| PUT | `/{id}` | `scrm:campaign:update` | 修改活动 |
| DELETE | `/{ids}` | `scrm:campaign:delete` | 批量删除 |

```json
{
  "name": "2026 秋季客户增长峰会",
  "type": 2,
  "channel": "线下会议",
  "budget": 80000,
  "startDate": "2026-11-10",
  "endDate": "2026-11-10",
  "status": 1,
  "targetCount": 200,
  "leadCount": 0,
  "ownerId": "5",
  "remark": "重点邀约制造业客户"
}
```

## 7. 工作台

```http
GET /api/v1/scrm/dashboard
```

响应字段概览：

| 字段 | 说明 |
| --- | --- |
| `customerTotal` / `customerNew` | 客户总数、近期新增 |
| `poolCount` | 公海客户数 |
| `followUpCount` | 跟进次数 |
| `opportunityAmount` | 商机金额 |
| `contractAmount` | 合同金额 |
| `winRate` | 赢单率 |
| `customerTrend` / `followTrend` | 趋势序列 |
| `sourceStats` | 客户来源分布 |
| `stageStats` | 商机阶段分布 |
| `recentFollowUps` / `todoFollowUps` | 最近跟进、待跟进 |
| `todoCustomers` | 待跟进客户 |
| `salesRanking` | 销售排行 |

## 8. 前端调用约定

```ts
import request from "@/utils/request";

export function getCustomers(params: CustomerQuery) {
  return request<unknown, PageResult<CustomerItem>>({
    url: "/api/v1/scrm/customers",
    method: "get",
    params,
  });
}
```

- 业务代码统一从 `@/api/scrm` 导入 API 方法；
- 页面不直接拼接完整域名，开发与生产域名由 Vite 环境变量和反向代理处理；
- 所有写操作需要刷新相关列表或工作台数据，避免展示过期统计。
