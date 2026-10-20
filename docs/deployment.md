# 部署指南

本文覆盖本地开发、生产构建和单机部署。示例以 Linux 和 Nginx 为主，Windows 开发环境只需要前半部分。

## 1. 本地开发

### 1.1 初始化配置

```bash
cp .env.example .env
# 修改 MYSQL_ROOT_PASSWORD、REDIS_PASSWORD、JWT_SECRET
set -a && . ./.env && set +a
```

### 1.2 启动依赖

```bash
docker compose up -d
docker compose ps
```

首次启动会导入两个 SQL 文件；如果 `volumes/mysql` 已存在，Docker 不会再次执行初始化脚本。需要完全重置数据库时，请先确认数据可丢弃，再停止容器并删除 `volumes/mysql` 后重新启动。

### 1.3 启动服务

后端：

```bash
cd backend
mvn spring-boot:run
```

前端：

```bash
cd frontend
pnpm install
pnpm dev
```

### 常见问题

| 症状 | 原因与处理 |
| --- | --- |
| 后端启动时报 `Could not resolve placeholder 'DB_PASSWORD'` | 当前终端没有导入 `.env`，重新执行 `set -a && . ./.env && set +a` |
| `Access denied for user 'root'` | `DB_PASSWORD` 与 `MYSQL_ROOT_PASSWORD` 不一致，或 MySQL 数据卷使用了旧密码 |
| Redis `NOAUTH Authentication required` | `REDIS_PASSWORD` 未设置或与容器启动参数不一致 |
| 登录提示验证码错误 | 验证码默认 120 秒过期；刷新后重新输入算术结果 |
| 端口被占用 | 修改 `.env` 中的 `MYSQL_PORT`、`REDIS_PORT`，并同步修改后端连接端口 |
| 页面刷新后 404 | 确认 Nginx 对前端路由做了回退配置；本项目使用 hash 路由，通常不会触发该问题 |

## 2. 生产构建

### 2.1 后端

```bash
cd backend
mvn clean package -DskipTests
```

产物：`backend/target/youlai-boot.jar`。

```bash
export SPRING_PROFILES_ACTIVE=prod
export DB_HOST=127.0.0.1
export DB_PORT=3306
export DB_NAME=youlai_admin
export DB_USERNAME=scrm_app
export DB_PASSWORD='<strong-password>'
export REDIS_HOST=127.0.0.1
export REDIS_PORT=6379
export REDIS_DATABASE=11
export REDIS_PASSWORD='<strong-password>'
export JWT_SECRET='<at-least-32-random-characters>'
export FILE_STORAGE_PATH=/var/lib/scrm/uploads

java -jar target/youlai-boot.jar
```

生产环境建议使用 systemd、Supervisor 或容器编排托管进程，不要依赖交互式终端。

### 2.2 前端

```bash
cd frontend
pnpm install --frozen-lockfile
pnpm build
```

构建产物位于 `frontend/dist/`。将其部署到 Nginx 静态目录。生产环境 API 前缀为 `/prod-api`，需要在 Nginx 中反代到后端。

## 3. Nginx 单机示例

假设：

- 前端构建产物：`/var/www/scrm`
- 后端：`127.0.0.1:8000`
- 域名：`scrm.example.com`

```nginx
server {
    listen 443 ssl http2;
    server_name scrm.example.com;

    ssl_certificate     /etc/letsencrypt/live/scrm.example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/scrm.example.com/privkey.pem;

    root /var/www/scrm;
    index index.html;

    add_header X-Content-Type-Options nosniff always;
    add_header X-Frame-Options SAMEORIGIN always;
    add_header Referrer-Policy strict-origin-when-cross-origin always;
    add_header Content-Security-Policy "default-src 'self'; img-src 'self' data: blob:; style-src 'self' 'unsafe-inline'; script-src 'self'; connect-src 'self'" always;

    location / {
        try_files $uri $uri/ /index.html;
    }

    location /prod-api/ {
        proxy_pass http://127.0.0.1:8000/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_http_version 1.1;
        proxy_read_timeout 60s;
    }

    client_max_body_size 50m;
}
```

注意：

- `proxy_pass` 末尾的 `/` 会剥离 `/prod-api` 前缀，确保与后端实际路径对应。
- 前端构建时使用 `.env.production` 的 `VITE_API_BASE=/prod-api`。
- 若前后端跨域部署，需要在网关层统一 CORS，而不是在业务代码中开放 `*`。
- 若启用 WebSocket，应增加 `Upgrade` 与 `Connection` 转发头。

## 4. 数据库与缓存

### 数据库账号

应用不要直接使用 `root`。建议创建最小权限账号：

```sql
CREATE USER 'scrm_app'@'%' IDENTIFIED BY '<strong-password>';
GRANT SELECT, INSERT, UPDATE, DELETE ON youlai_admin.* TO 'scrm_app'@'%';
FLUSH PRIVILEGES;
```

需要执行迁移时使用独立的迁移账号；应用账号不授予 `DROP`、`ALTER` 等权限。

### 初始化脚本

- `backend/sql/mysql/youlai_admin.sql`：系统基础表、菜单与演示账号。
- `sql/scrm.sql`：SCRM 业务表、菜单和演示数据。

正式环境应将演示数据清空，只保留菜单、角色和必要的字典数据。请在测试库先验证脚本，再执行到生产库。

### 备份

```bash
mysqldump -u backup_user -p --single-transaction --routines --triggers youlai_admin \
  | gzip > scrm-$(date +%F-%H%M).sql.gz
```

至少保留数据库每日备份，并定期做恢复演练。Redis 中的验证码和会话可丢失，但若使用 Redis Token 模式，应评估会话重新登录的影响。

## 5. 上线检查清单

- [ ] 删除或禁用演示账号，修改全部初始密码。
- [ ] `JWT_SECRET` 使用随机值并通过密钥管理系统下发。
- [ ] 数据库、Redis 不暴露公网；安全组只允许应用主机访问。
- [ ] 强制 HTTPS，并配置 HSTS、CSP、X-Frame-Options 等响应头。
- [ ] 关闭 Knife4j/Actuator 或仅对可信网络开放。
- [ ] 对登录、导出、批量删除接口增加限流与审计。
- [ ] 配置文件、日志、构建产物中不出现真实密钥或客户数据。
- [ ] 配置备份、告警、磁盘容量监控和日志轮转。
- [ ] 对导入、上传文件做类型与大小校验，对象存储桶设置为私有读。
- [ ] 进行权限回归测试，重点验证部门隔离与数据范围。

## 6. 回滚

1. 保留上一版本后端 JAR 与前端静态目录（例如按时间戳发布目录）。
2. 数据库变更采用向前兼容的增量迁移，避免回滚时依赖逆向 SQL。
3. 先回滚应用，再判断是否需要恢复数据库。
4. 回滚后验证登录、客户列表、合同保存和工作台统计等关键路径。
